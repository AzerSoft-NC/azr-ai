# Agent Skills & Rules

> **Author:** kako  
> **Last updated:** September 2026  
> **Purpose:** Versioned catalog of Cursor skills and always-on rules — source of truth under `ai/`, installed globally via `install-skills.sh`.

Portable agent skill definitions and rules. Skills make agent behavior **predictable and repeatable**: same process every run, not necessarily the same output.

**Language:** English is the default for all skills, rules, and templates in this catalog.

## Install (Cursor personal)

From the workspace root:

```bash
ai/install-skills.sh
```

Copies catalog skills (categories `engineering`, `productivity`, `misc` only — never `deprecated/`), vendored superpowers skills, and always-on rules into `~/.cursor/`. Re-run after editing the catalog or after `git pull` in `~/.cursor/vendor/superpowers`.

| Tool | Personal | Project |
|------|----------|---------|
| Cursor | `~/.cursor/skills/` + `~/.cursor/rules/` | `.cursor/skills/` + `.cursor/rules/` |

Router template: [global-config/user-CURSOR.md](./global-config/user-CURSOR.md) (paste into Cursor User Rules).

---

## Reference

Skills split on **who can invoke them**. **User-invoked** skills fire only when you type them (e.g. `/commit`). **Model-invoked** skills can be invoked by you _or_ reached automatically when the task fits.

### [Engineering](skills/engineering/README.md)

**User-invoked**

- **[commit](./skills/engineering/commit/SKILL.md)** — Draft commit message (hybrid format) and commit after approval. `/commit`.

**Model-invoked** — none (engineering holds only user-invoked `commit`).

### [Productivity](skills/productivity/README.md)

**User-invoked**

- **[handoff](./skills/productivity/handoff/SKILL.md)** — Compact the conversation into a handoff document.

**Model-invoked**

- **[caveman](./skills/productivity/caveman/SKILL.md)** — Ultra-compressed communication (levels: lite, full, ultra, wenyan-*).
- **[grill-me](./skills/productivity/grill-me/SKILL.md)** — Domain model, glossary, ADRs, and architecture forks; includes design heuristics (deep-modules, interface-design, refactoring).
- **[less-trouble](./skills/productivity/less-trouble/SKILL.md)** — Capture resolved env bugs into `docs/troubleshoot/TROUBLESHOOT.md`.
- **[teach-me](./skills/productivity/teach-me/SKILL.md)** — Reverse-engineer legacy code; cited docs under `context/rg/`.
- **[map-architecture](./skills/productivity/map-architecture/SKILL.md)** — Maintain curated `context/architecture-graph.json` (CI, infra, platform, apps).

### [Misc](skills/misc/README.md)

- **[init-repo](./skills/misc/init-repo/SKILL.md)** — see above (user-invoked).

### Rules (always-on)

| Rule | Role |
|------|------|
| [no-read-secrets.mdc](./rules/no-read-secrets.mdc) | Block secret **files** + never echo secret **values** |
| [architecture-forks.mdc](./rules/architecture-forks.mdc) | Architecture trade-offs → load `grill-me` |
| [caveman-default.mdc](./rules/caveman-default.mdc) | Caveman **full** on by default |
| [architecture-graph.mdc](./rules/architecture-graph.mdc) | Read curated `context/architecture-graph.json` before broad workspace exploration |

---

## Vendored upstream skills

Process skills that upstream does better than this catalog come from [superpowers](https://github.com/obra/superpowers) (MIT). `install-skills.sh` clones or updates `~/.cursor/vendor/superpowers` and **copies** its skills alongside ours. Pull upstream when you want a newer superpowers, then re-run the installer. Nothing is edited locally — reshape behavior through `rules/` instead, so the diff against upstream stays empty.

**Skills only, no plugin.** superpowers ships `.cursor-plugin/plugin.json` and a `sessionStart` hook that injects its `using-superpowers` skill into every conversation, demanding skill invocation before any response including clarifying questions, and brainstorming before plan mode. That pre-empts `caveman-default.mdc` and short-circuits `architecture-forks.mdc` → `grill-me`. The plugin is therefore **not** registered and `using-superpowers` is **not** installed. Its useful kernel is restated in one paragraph under Core Philosophy in [global-config/user-CURSOR.md](./global-config/user-CURSOR.md).

| Need | Vendored skill |
|------|----------------|
| Bug, test failure, unexpected behavior | `systematic-debugging` |
| Feature or fix, test-first | `test-driven-development` |
| Write or edit a skill | `writing-skills` |
| Turn an idea into a design | `brainstorming` |
| Write / execute an implementation plan | `writing-plans`, `executing-plans`, `subagent-driven-development` |
| Code review, given or received | `requesting-code-review`, `receiving-code-review` |
| Claim work is done | `verification-before-completion` |
| Isolation, parallelism, branch close | `using-git-worktrees`, `dispatching-parallel-agents`, `finishing-a-development-branch` |

### Not installed

`everything-claude-code` was evaluated and rejected: half its skills are TypeScript/React/Node/ClickHouse pattern packs against a Jakarta EE + DB2 stack, its plumbing is Claude-only with no Cursor plugin, and `tdd-workflow` mandates a coverage floor this catalog refuses to invent. Two of its ideas stay on the shelf — `memory-persistence` and `strategic-compact` — as nothing here covers session continuity. Full trade-off in [ADR 0002](../context/adr/0002-agent-skills-vendoring.md).

Retired / personal-only leftovers (do not reinstall): `commit-with-ai`, `write-a-skill`, `writing-great-skills`, agents `caveman-*` family, `find-skills`. Superseded by vendored upstream: `diagnose`, `tdd`, `new-skill`. Commit format lives only in the `commit` skill (no always-on commit-messages rule).
