---
name: commit
description: Draft a commit message and run git commit after user approval. Invoke explicitly with /commit.
argument-hint: "[type]"
disable-model-invocation: true
---

# Commit

Draft a commit message from the working tree, show it for approval, then commit.

## Message format

```
<type> : <subject>

<why sentence>

## <Section>
- <change>
- <change>
```

- **type** — lowercase from [types.md](types.md) (`feat`, `fix`, `docs`, …)
- **subject** — short generic title (no trailing period)
- **why sentence** — one sentence on why this change matters
- **sections** — markdown `##` headings with bullet lists of what changed; call out breaking contract or cross-project impact in a section when needed

No scope / no `(JIRA)` parentheses on the title line.

**Example:**

```
feat : reduce delete ops to SyncDTO id transform

Reduces delete work so sync stays reliable.

## Sync
- Feed SyncDTO with tuple id only
- Drop unused fields from the path
```

## Invocation hints

Parse optional arguments from the user's message:

- **type** — one of the allowed commit types (see [types.md](types.md))

Hints pre-fill; the agent still drafts subject and body from the diff. Approval is always required before `git commit`.

## Workflow

Copy this checklist and track progress:

```
- [ ] 1. Gather context
- [ ] 2. Stage and validate
- [ ] 3. Check documentation
- [ ] 4. Resolve type
- [ ] 5. Draft message
- [ ] 6. Approve
- [ ] 7. Commit
```

### 1. Gather context

Run in parallel:

```bash
git status
git diff
git diff --cached
git log --oneline -10
```

Completion: you have the full change set and recent commit style.

### 2. Stage and validate

Branch on step 1's `git diff --cached` output:

- **Staged changes exist** → skip `git add -A`. Commit only what is already staged.
- **No staged changes** → run `git add -A` silently.

Then:

- **Empty index** → stop. Report "nothing to commit" — do not draft or commit.
- **Secrets** → if staged files look like credentials (`.env`, `credentials.json`, keys, tokens), warn the user and do not commit until they confirm.

Completion: staged changes exist and are safe to commit.

### 3. Check documentation

**Scope:** staged index only — same boundary as the commit.

**Skip** when staged changes are documentation-only (see [types.md](types.md) `docs` signals) and no executable code or config changed.

**Otherwise**, discover docs the project already maintains:

- `CONTEXT.md` (glossary)
- ADRs under `context/adr/` (or legacy `docs/adr/` if that is what the project uses)
- README, CHANGELOG, OpenAPI/spec files, or other doc paths already in the repo

Review the **staged diff** for signals that docs should move too:

| Staged diff signal | Verify |
|--------------------|--------|
| New or renamed domain terms, enums, status codes | `CONTEXT.md` updated or not needed |
| Hard-to-reverse design (new layer, contract break, persistence model) | ADR exists or not warranted |
| Public API, config, CLI, or integration surface changed | README, API docs, or runbooks reflect it |
| Breaking change for other projects | Project docs state it — not only the commit body |

For each gap: name the file and what is missing. Do not create new top-level docs without asking.

**Outcomes:**

- **Aligned** → proceed.
- **Gap** → stop before drafting. Present gaps; user updates docs and re-runs `/commit`, or explicitly waives (`proceed without doc update`).
- **No project doc layout** → note once; proceed.

Completion: every detected gap is fixed, waived by the user, or ruled out as not applicable.

### 4. Resolve type

Use hint if provided; otherwise infer from the **staged diff** using [types.md](types.md). User can override at approval.

Completion: type is set.

### 5. Draft message

**Title line** — lowercase type, spaces around `:`, concise subject, no trailing period:

```
<type> : <subject>
```

**Body** — after a blank line:

1. One sentence: why this change matters.
2. One or more `##` sections with bullet lists (grouped by area, not a raw file dump).
3. If the commit introduces breaking contract or implementation changes for other projects, state it in a dedicated section.

Completion: full message drafted in the required format.

### 6. Approve

Present the complete message, a summary of staged files, and doc-check outcome (aligned / waived / not applicable). Wait for explicit approval.

- **Approved** → proceed to commit.
- **Edits requested** → revise and re-present.
- **Rejected** → stop without committing. Staged changes remain staged.

Completion: user explicitly approved the message.

### 7. Commit

```bash
git commit -m "$(cat <<'EOF'
<type> : <subject>

<why sentence>

## <Section>
- <change>
- <change>
EOF
)"
git status
```

**Git safety:**

- Never update git config.
- Never skip hooks (`--no-verify`, `--no-gpg-sign`).
- Never amend unless the user explicitly requests it and amend rules are satisfied.
- Never push unless the user explicitly asks.
- If the commit hook fails or auto-modifies files, fix the issue and create a **new** commit — never amend a failed commit.

Completion: commit succeeded; `git status` confirms clean or expected state.

## Approval prompt template

Present drafts using this shape:

```markdown
## Proposed commit

**Staged:** <file count> files — <one-line summary>
**Docs:** aligned | waived — <one-line note if waived or N/A>

<type> : <subject>

<why sentence>

## <Section>
- <change>
- <change>

---
Approve this message? Edit anything before I commit.
```
