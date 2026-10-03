#!/usr/bin/env bash
# Copy catalog + vendored superpowers skills and rules into ~/.cursor/.
# Safe under sudo: installs into the invoking user's home, not /root.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"

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

for category in engineering productivity misc; do
  for d in "$ROOT/skills/$category"/*/; do
    [[ -d "$d" ]] || continue
    name="$(basename "$d")"
    install_skill "$name" "$(cd "$d" && pwd)" "(catalog)"
  done
done

SUPERPOWERS="$VENDOR_DIR/superpowers"
if [[ -d "$SUPERPOWERS/.git" ]]; then
  git -C "$SUPERPOWERS" pull --ff-only --quiet
else
  git clone --quiet https://github.com/obra/superpowers.git "$SUPERPOWERS"
fi
echo "vendor superpowers $(git -C "$SUPERPOWERS" describe --tags --always)"

for d in "$SUPERPOWERS"/skills/*/; do
  name="$(basename "$d")"
  # using-superpowers is the hook payload: it mandates skill invocation before any
  # response and pre-empts caveman-default and architecture-forks. Not installed.
  [[ "$name" == "using-superpowers" ]] && continue
  install_skill "$name" "$d" "(vendor)"
done

for f in no-read-secrets.mdc architecture-forks.mdc caveman-default.mdc architecture-graph.mdc; do
  install_rule "$f" "$ROOT/rules/$f"
done

prune_from_manifest "$MANIFEST" "$SKILLS_DIR" "${INSTALLED[@]}"
# Leftovers from the symlink era or dropped catalog entries (never re-install these).
for retired in domain-modeling diagnose tdd new-skill using-superpowers; do
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
