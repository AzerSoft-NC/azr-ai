#!/usr/bin/env bash
# Copy catalog + vendored skills and rules into ~/.cursor/.
# Safe under sudo: installs into the invoking user's home, not /root.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"

SUPERPOWERS_URL="https://github.com/obra/superpowers.git"
SUPERPOWERS_REF="8ca22dba9a94f28898bbce59f2537ff4d87c747d"  # v6.4.2

SKILLSPECTOR_URL="https://github.com/NVIDIA/skillspector.git"
SKILLSPECTOR_REF="3c8e4b958fda9602e0044885f766be0e49f03585"  # v2.12.0-584

if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
  TARGET_HOME="$(getent passwd "$SUDO_USER" | cut -d: -f6)"
  TARGET_USER="$SUDO_USER"
else
  TARGET_HOME="${HOME}"
  TARGET_USER="$(id -un)"
fi

SKILLS_DIR="$TARGET_HOME/.cursor/skills"
RULES_DIR="$TARGET_HOME/.cursor/rules"
VENDOR_DIR="$TARGET_HOME/.cursor/vendor"
MANIFEST="$SKILLS_DIR/.azr-installed"
RULES_MANIFEST="$RULES_DIR/.azr-installed"
mkdir -p "$SKILLS_DIR" "$RULES_DIR" "$VENDOR_DIR"

echo "Installing into $TARGET_HOME/.cursor (user=$TARGET_USER)"
echo "Source: $ROOT"
echo

declare -a INSTALLED=()
declare -a RULES_INSTALLED=()

prepend_target_local_bin() {
  local bin="$TARGET_HOME/.local/bin"
  [[ -d "$bin" ]] || return 0
  case ":${PATH}:" in
    *":${bin}:"*) ;;
    *) PATH="${bin}:${PATH}"; export PATH ;;
  esac
}

run_as_target() {
  if [[ "$(id -un)" == "root" && "${TARGET_USER}" != "root" ]]; then
    if command -v runuser >/dev/null 2>&1; then
      runuser -u "$TARGET_USER" -- "$@"
    else
      sudo -u "$TARGET_USER" -- "$@"
    fi
  else
    "$@"
  fi
}

install_dir() {
  local name="$1" src="$2" dest_root="$3" dest
  dest="$dest_root/$name"
  if [[ -e "$dest" || -L "$dest" ]]; then
    rm -rf "$dest"
  fi
  cp -a "$src" "$dest"
}

install_skill() {
  local name="$1" src="$2" label="${3:-}"
  install_dir "$name" "$src" "$SKILLS_DIR"
  INSTALLED+=("$name")
  echo "skill $name${label:+ $label}"
}

install_rule() {
  local rule_file="$1"
  local src="$2"
  local dest="$RULES_DIR/$rule_file"
  rm -f "$dest"
  cp -a "$src" "$dest"
  RULES_INSTALLED+=("$rule_file")
  echo "rule $rule_file"
}

prune_from_manifest() {
  local manifest="$1" dest_root="$2"
  shift 2
  local current=("$@")
  [[ -f "$manifest" ]] || return 0
  local old
  while IFS= read -r old || [[ -n "$old" ]]; do
    [[ -z "$old" ]] && continue
    local found=0 entry
    for entry in "${current[@]}"; do
      [[ "$entry" == "$old" ]] && found=1 && break
    done
    if [[ "$found" -eq 0 && ( -e "$dest_root/$old" || -L "$dest_root/$old" ) ]]; then
      rm -rf "$dest_root/$old" 2>/dev/null || rm -f "$dest_root/$old"
      echo "pruned $old"
    fi
  done < "$manifest"
}

ensure_vendor_repo() {
  local name="$1"
  local url="$2"
  local ref="${3:-}"
  local dest="$VENDOR_DIR/$name"
  mkdir -p "$VENDOR_DIR"
  if [[ ! -d "$dest/.git" ]]; then
    git clone --quiet "$url" "$dest"
  fi
  if [[ -n "$ref" ]]; then
    git -C "$dest" fetch --quiet origin
    if ! git -C "$dest" cat-file -e "${ref}^{commit}" 2>/dev/null; then
      echo "ERROR: vendor $name: pinned ref $ref not found upstream; update the pin in install-skills.sh" >&2
      return 1
    fi
    git -C "$dest" checkout --quiet --detach "$ref"
  else
    if ! git -C "$dest" symbolic-ref -q HEAD >/dev/null; then
      git -C "$dest" checkout --quiet "$(git -C "$dest" rev-parse --abbrev-ref origin/HEAD | cut -d/ -f2-)"
    fi
    git -C "$dest" pull --ff-only --quiet
  fi
  echo "vendor $name $(git -C "$dest" rev-parse --short HEAD) $(git -C "$dest" describe --tags --always)"
}

patch_writing_plans_location() {
  local skill="$SKILLS_DIR/writing-plans/SKILL.md"
  if [[ ! -f "$skill" ]]; then
    echo "WARN: writing-plans SKILL.md missing; skip plan-location patch" >&2
    return 0
  fi
  if grep -q 'context/plans/YYYY-MM-DD-<feature-name>\.md' "$skill"; then
    echo "patch writing-plans plan location (already applied)"
    return 0
  fi
  local tmp
  tmp="$(mktemp)"
  sed \
    -e 's|docs/superpowers/plans/YYYY-MM-DD-<feature-name>\.md|context/plans/YYYY-MM-DD-<feature-name>.md|g' \
    -e 's|docs/superpowers/plans/<filename>\.md|context/plans/<filename>.md|g' \
    -e 's|docs/superpowers/plans/|context/plans/|g' \
    "$skill" >"$tmp"
  mv "$tmp" "$skill"
  echo "patch writing-plans plan location → context/plans/"
}

patch_brainstorming_spec_location() {
  local skill="$SKILLS_DIR/brainstorming/SKILL.md"
  if [[ ! -f "$skill" ]]; then
    echo "WARN: brainstorming SKILL.md missing; skip spec-location patch" >&2
    return 0
  fi
  if grep -q 'context/specs/YYYY-MM-DD-<topic>-design\.md' "$skill"; then
    echo "patch brainstorming spec location (already applied)"
    return 0
  fi
  local tmp
  tmp="$(mktemp)"
  sed \
    -e 's|docs/superpowers/specs/YYYY-MM-DD-<topic>-design\.md|context/specs/YYYY-MM-DD-<topic>-design.md|g' \
    -e 's|docs/superpowers/specs/|context/specs/|g' \
    "$skill" >"$tmp"
  mv "$tmp" "$skill"
  echo "patch brainstorming spec location → context/specs/"
}

install_skillspector_skill() {
  local SKILLSPECTOR="$VENDOR_DIR/skillspector"
  local SKILL_INSPECTOR="$SKILLSPECTOR/skills/skill-inspector"
  ensure_vendor_repo skillspector "$SKILLSPECTOR_URL" "$SKILLSPECTOR_REF"
  if [[ -d "$SKILL_INSPECTOR" && -f "$SKILL_INSPECTOR/SKILL.md" ]]; then
    install_skill "skill-inspector" "$SKILL_INSPECTOR" "(vendor)"
  else
    echo "WARN: skillspector clone missing skills/skill-inspector/SKILL.md" >&2
  fi
}

install_skillspector_cli() {
  local SKILLSPECTOR="$VENDOR_DIR/skillspector"
  prepend_target_local_bin
  local uv_bin=""
  if [[ -x "$TARGET_HOME/.local/bin/uv" ]]; then
    uv_bin="$TARGET_HOME/.local/bin/uv"
  elif command -v uv >/dev/null 2>&1; then
    uv_bin="$(command -v uv)"
  fi
  if [[ -z "$uv_bin" ]]; then
    echo "WARN: uv not found; skip skillspector CLI. Install uv (https://docs.astral.sh/uv/), then re-run." >&2
    return 0
  fi
  if run_as_target env UV_SYSTEM_CERTS=1 "$uv_bin" tool install --force --python 3.12 "$SKILLSPECTOR"; then
    prepend_target_local_bin
    echo "cli skillspector ($(command -v skillspector 2>/dev/null || echo "$TARGET_HOME/.local/bin/skillspector"))"
  else
    echo "WARN: uv tool install skillspector failed; skill-inspector will use manual fallback" >&2
  fi
}

for category in engineering productivity misc; do
  for d in "$ROOT/skills/$category"/*/; do
    [[ -d "$d" ]] || continue
    name="$(basename "$d")"
    install_skill "$name" "$(cd "$d" && pwd)" "(catalog)"
  done
done

SUPERPOWERS="$VENDOR_DIR/superpowers"
ensure_vendor_repo superpowers "$SUPERPOWERS_URL" "$SUPERPOWERS_REF"

for d in "$SUPERPOWERS"/skills/*/; do
  name="$(basename "$d")"
  # using-superpowers is the hook payload: it mandates skill invocation before any
  # response and pre-empts caveman-default and architecture-forks. Not installed.
  [[ "$name" == "using-superpowers" ]] && continue
  install_skill "$name" "$d" "(vendor)"
done

patch_writing_plans_location
patch_brainstorming_spec_location

install_skillspector_skill
install_skillspector_cli

for f in no-read-secrets.mdc architecture-forks.mdc caveman-default.mdc architecture-graph.mdc skill-router.mdc clean-code.mdc; do
  install_rule "$f" "$ROOT/rules/$f"
done

prune_from_manifest "$MANIFEST" "$SKILLS_DIR" "${INSTALLED[@]}"
# Leftovers from the symlink era or dropped catalog entries (never re-install these).
for retired in domain-modeling diagnose tdd new-skill using-superpowers flux-amq revue-java new-app new-rule build-context context-map angular-developer; do
  if [[ -e "$SKILLS_DIR/$retired" || -L "$SKILLS_DIR/$retired" ]]; then
    rm -rf "$SKILLS_DIR/$retired"
    echo "removed retired $retired"
  fi
done
printf '%s\n' "${INSTALLED[@]}" > "$MANIFEST"

prune_from_manifest "$RULES_MANIFEST" "$RULES_DIR" "${RULES_INSTALLED[@]}"
printf '%s\n' "${RULES_INSTALLED[@]}" > "$RULES_MANIFEST"

if [[ "$(id -un)" == "root" && "$TARGET_USER" != "root" ]]; then
  for name in "${INSTALLED[@]}"; do
    chown -R "$TARGET_USER:$TARGET_USER" "$SKILLS_DIR/$name" 2>/dev/null || true
  done
  for f in "${RULES_INSTALLED[@]}"; do
    chown "$TARGET_USER:$TARGET_USER" "$RULES_DIR/$f" 2>/dev/null || true
  done
  chown "$TARGET_USER:$TARGET_USER" "$MANIFEST" "$RULES_MANIFEST" 2>/dev/null || true
  chown "$TARGET_USER:$TARGET_USER" "$SKILLS_DIR" "$RULES_DIR" 2>/dev/null || true
  chown -R "$TARGET_USER:$TARGET_USER" "$VENDOR_DIR" 2>/dev/null || true
fi

echo
echo "=== verify ==="
broken=0
for name in "${INSTALLED[@]}"; do
  if [[ ! -f "$SKILLS_DIR/$name/SKILL.md" ]]; then
    echo "MISSING SKILL.md: $name"
    broken=1
  else
    echo "OK: skill $name"
  fi
done
for f in "${RULES_INSTALLED[@]}"; do
  if [[ ! -f "$RULES_DIR/$f" ]]; then
    echo "MISSING: $f"
    broken=1
  else
    echo "OK: rule $f"
  fi
done
[[ "$broken" -eq 0 ]]
echo "Installed ${#INSTALLED[@]} skills, ${#RULES_INSTALLED[@]} rules"
