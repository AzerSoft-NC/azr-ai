# Agent Skills & Rules

> **Author:** kako  
> **Last updated:** October 2026  
> **Purpose:** Versioned catalog of Cursor skills and always-on rules — source of truth under `ai/`, installed globally via `install-skills.sh`.

Portable agent skill definitions and rules. Skills make agent behavior **predictable and repeatable**: same process every run, not necessarily the same output.

**Language:** English is the default for all skills, rules, and templates in this catalog.

## Install (Cursor personal)

From the workspace root:

```bash
ai/install-skills.sh
```

Copies catalog skills (categories `engineering`, `productivity`, `misc` only — never `deprecated/`), pinned vendored skills, and always-on rules into `~/.cursor/`. Re-run after editing the catalog or after bumping a vendor pin in `install-skills.sh`.

| Tool | Personal | Project |
|------|----------|---------|
| Cursor | `~/.cursor/skills/` + `~/.cursor/rules/` | `.cursor/skills/` + `.cursor/rules/` |

**Router:** the always-on rule [skill-router.mdc](./rules/skill-router.mdc) is installed by the script — nothing to paste into Cursor User Rules. [global-config/user-CURSOR.md](./global-config/user-CURSOR.md) is a pointer only.

**Agent docs:** plans → `context/plans/`, design specs → `context/specs/`, handoffs → `context/handoffs/` (see [skill-router.mdc](./rules/skill-router.mdc)).

---

## Reference

Skills split on **who can invoke them**. **User-invoked** skills fire only when you type them (e.g. `/commit`). **Model-invoked** skills can be invoked by you _or_ reached automatically when the task fits.

### [Engineering](skills/engineering/README.md)

**User-invoked**

- **[commit](./skills/engineering/commit/SKILL.md)** — Draft commit message (hybrid format) and commit after approval. `/commit`.

**Model-invoked**

- **[contract-first](./skills/engineering/contract-first/SKILL.md)** — One authoritative contract per API or event boundary (OpenAPI, AsyncAPI, JSON Schema); consumer-first workflow and verification.

### [Productivity](skills/productivity/README.md)

**User-invoked**

- **[handoff](./skills/productivity/handoff/SKILL.md)** — Compact the conversation into a handoff document (`context/handoffs/`).

**Model-invoked**

- **[caveman](./skills/productivity/caveman/SKILL.md)** — Ultra-compressed communication (levels: lite, full, ultra, wenyan-*).
- **[grill-me](./skills/productivity/grill-me/SKILL.md)** — Domain model, glossary, ADRs, and architecture forks; layered workspace + project glossaries; design heuristics (deep-modules, interface-design, refactoring).
- **[less-trouble](./skills/productivity/less-trouble/SKILL.md)** — Capture resolved env bugs into `docs/troubleshoot/TROUBLESHOOT.md`.
- **[teach-me](./skills/productivity/teach-me/SKILL.md)** — Reverse-engineer legacy code; cited docs under `context/rg/`.
- **[map-architecture](./skills/productivity/map-architecture/SKILL.md)** — Maintain curated `context/architecture-graph.json` (CI, infra, platform, apps).

### [Misc](skills/misc/README.md)

- **[init-repo](./skills/misc/init-repo/SKILL.md)** — Standardise repo docs (user-invoked `/init-repo`).

### Rules (always-on)

| Rule | Role |
|------|------|
| [skill-router.mdc](./rules/skill-router.mdc) | Philosophy, skill map, knowledge capture |
| [no-read-secrets.mdc](./rules/no-read-secrets.mdc) | Block secret **files** + never echo secret **values** |
| [architecture-forks.mdc](./rules/architecture-forks.mdc) | Architecture trade-offs → load `grill-me` |
| [caveman-default.mdc](./rules/caveman-default.mdc) | Caveman **full** on by default |
| [architecture-graph.mdc](./rules/architecture-graph.mdc) | Read curated `context/architecture-graph.json` before broad workspace exploration |
| [clean-code.mdc](./rules/clean-code.mdc) | Clean code within the requested change only |

---

## Vendored upstream skills

Process skills that upstream does better than this catalog come from [superpowers](https://github.com/obra/superpowers) (MIT). Pre-install skill review comes from [SkillSpector](https://github.com/NVIDIA/SkillSpector) (`skill-inspector` + optional `skillspector` CLI via `uv`).

`install-skills.sh` clones vendors under `~/.cursor/vendor/` at **pinned commits** (`SUPERPOWERS_REF`, `SKILLSPECTOR_REF` in the script). A bump is a catalog PR: re-read the upstream diff and scan skills with `skill-inspector` before changing the pin.

The installer copies vendored skills into `~/.cursor/skills/` and applies **house path overrides** on the installed copies of `writing-plans` and `brainstorming` so plans and specs land under `context/plans/` and `context/specs/` (see workspace ADR 0011).

**Skills only, no plugin.** superpowers ships a `sessionStart` hook that injects `using-superpowers` into every conversation. That pre-empts `caveman-default.mdc` and short-circuits `architecture-forks.mdc` → `grill-me`. The plugin is **not** registered and `using-superpowers` is **not** installed.

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
| Ask whether a skill is safe to install | `skill-inspector` |

### Not installed

`everything-claude-code` was evaluated and rejected (see workspace [ADR 0002](../context/adr/0002-agent-skills-vendoring.md)). CAFAT-only skills from the upstream `ai-skills` catalog (`flux-amq`, `revue-java`, `new-app`, …) are intentionally omitted from this repo.

Retired / personal-only leftovers (do not reinstall): `commit-with-ai`, `write-a-skill`, `writing-great-skills`, agents `caveman-*` family, `find-skills`. Superseded by vendored upstream: `diagnose`, `tdd`, `new-skill`. Commit format lives only in the `commit` skill (no always-on commit-messages rule).
