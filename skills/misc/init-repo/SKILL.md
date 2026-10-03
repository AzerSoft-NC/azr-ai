---
name: init-repo
description: Initialise or standardise a repo's documentation layout (gitignore, README, CHANGELOG, docs, CONTEXT). Invoke explicitly with /init-repo.
disable-model-invocation: true
---

# Init Repo

Initialise or **standardise** a repository: fill what is missing, merge `.gitignore`, never replace substantive content.

All documentation produced by this skill is in **English**. Do not run `git init`.

## Steps

### 1. Survey the repository

Explore the root and stack markers.

**Stack detection** (multiple possible):

| Overlay | Markers |
|---------|---------|
| Java | `pom.xml`, `build.gradle`, `build.gradle.kts` |
| Node | `package.json` |

For each artefact below, classify: **absent**, **placeholder**, or **substantive**. Rules: [PLACEHOLDER-RULES.md](./PLACEHOLDER-RULES.md).

Artefacts: `.gitignore`, `README.md`, `CHANGELOG.md`, `CONTEXT.md`, `docs/architecture.md`, `context/adr/`, `context/rg/`.

Extract the project name from `pom.xml` (`artifactId`), `package.json` (`name`), or the root folder name.

**Completion:** every artefact classified; stacks listed; project name identified.

### 2. Merge `.gitignore`

Always merge-safe — never delete an existing line.

1. Load [gitignore-core](./templates/gitignore-core)
2. For each detected stack, load the matching overlay:
   - Java → [gitignore-java](./templates/gitignore-java)
   - Node → [gitignore-node](./templates/gitignore-node)
3. If `.gitignore` absent → write core + applicable overlays, with commented sections
4. If `.gitignore` exists → add **only** template lines not already present (line compare; ignore blank comments)

**Completion:** every applicable template line is present; no user lines removed.

### 3. Create directories

Create if missing:

- `docs/`
- `context/adr/` (with `.gitkeep` if the repo is git and the folder would be empty)
- `context/rg/` (same)

Do not touch a directory that already exists.

**Completion:** all three paths exist.

### 4. Scaffold files

For each file that is **absent** or **placeholder** only — leave **substantive** content untouched.

#### `README.md`

| Stack | Template |
|-------|----------|
| Java (alone or with Node) | [README-java.md](./templates/README-java.md) — fill name, prerequisites, and commands from `pom.xml`; if Node is also detected, add a **Frontend** section from `package.json` |
| Node only (no Java) | [README-node.md](./templates/README-node.md) — fill from `package.json` scripts |
| No recognised stack | [README-minimal.md](./templates/README-minimal.md) |

Write templates in **English** (translate placeholders such as `{nom}` → project name).

#### `CHANGELOG.md`

Write [CHANGELOG.md](./templates/CHANGELOG.md) as-is (English).

#### `CONTEXT.md`

Write [CONTEXT.md](./templates/CONTEXT.md) — replace `{nom}` / one-line description (infer from README or project name; no glossary terms yet).

#### `docs/architecture.md`

Write [architecture-hub.md](./templates/architecture-hub.md), then light autofill:

- **Stack**: key versions/deps from `pom.xml` / `package.json` (facts only)
- **Structure**: `src/` tree or equivalent (max 2 levels, `text` fence)
- **Also read**: links to `CONTEXT.md`, `CHANGELOG.md`, and other files already under `docs/`

Do not invent consumers, integrations, or mermaid diagrams at this step.

**Completion:** every absent/placeholder artefact written; every substantive artefact unchanged.

### 5. Report

Show a summary table:

| Artefact | Action |
|----------|--------|
| … | created / merged / scaffolded / skipped (substantive) |

List `.gitignore` lines added if merged.

**Completion:** user can see what changed and what was left alone.

### 6. Offer `teach-me` (full architecture pass)

Ask explicitly:

> Full architecture pass via `teach-me`? (hub `docs/architecture.md` + cited doc `context/rg/architecture.md`)

- **If yes**: load and follow `teach-me` with target `"architecture"`. Deep deliverable → `context/rg/architecture.md`. Then enrich hub `docs/architecture.md` (factual sections + **Also read** link to the rg doc).
- **If no**: stop. Remind that `/teach-me architecture` remains available later.

Do not start `teach-me` without agreement.

**Completion:** gate asked; if accepted, `teach-me` run to its own completion.

## Forbidden

- `git init` or any destructive git command
- Overwriting a substantive file
- Deleting or reordering existing `.gitignore` lines
- Guessing consumers, integrations, or glossary terms not proven by the code
- Starting `teach-me` without user agreement
