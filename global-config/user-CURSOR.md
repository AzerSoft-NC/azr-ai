# User-Level Cursor Config (Template)

**Literal template name:** `user-CURSOR.md`. Cursor does not load this filename automatically.

### How to install

1. **User Rules** — Cursor Settings → Rules → User Rules: paste the sections below (or use the Cursor dialog to add/update this router).
2. **Project `AGENTS.md`** — Optional repo-wide adaptation.
3. **Always-on rules** — Copied from this catalog's `rules/` into `~/.cursor/rules/` by `install-skills.sh`.

Skills install to `~/.cursor/skills/<name>/` via [install-skills.sh](../install-skills.sh), which copies catalog skills (`engineering`, `productivity`, `misc` only) and the vendored superpowers clone in `~/.cursor/vendor/`. Re-run after catalog edits.

This file is a **router**: philosophy, skill map, and knowledge rules — not a copy of skill bodies.

---

## Core Philosophy

1. **Skill-first** — Prefer named skills over ad-hoc process for complex work. Check for a
   matching skill **before acting** — before clarifying questions, before exploring the
   codebase, before the first edit. When one matches, name it in one line and follow it. When
   several match, process skills set the approach and implementation skills carry it out.
   "Simple question", "I need context first" and "the skill is overkill" are not reasons to
   skip the check. Announcing a skill stays subject to `caveman-default`: one line, no preamble.
2. **Plan before big changes** — Use Plan mode (or grill a plan) when architecture or irreversible choices are in play. **Architecture forks → `grill-me` by default** (see `rules/architecture-forks.mdc`).
3. **Test-first for features** — Reach for TDD when building or fixing with tests.
4. **Diagnose before guessing** — Hard bugs and regressions get a disciplined diagnosis loop, not scattershot edits.
5. **Security-aware** — Never paste secrets; redact logs; do not weaken auth or secret handling without explicit review.

---

## Skill Router

Skills are expected under `~/.cursor/skills/` (or project `.cursor/skills/`). Some are authored in this catalog, the rest are vendored from [superpowers](https://github.com/obra/superpowers) — same directory, no distinction at call time.

| Trigger | Skill | Notes |
|---------|-------|-------|
| Commit / "commit this" | `commit` | User-invoked (`/commit`) — hybrid message format |
| Pin domain language, glossary, architectural decision, or architecture fork | `grill-me` | **Default** for forks — one question at a time; updates `CONTEXT.md` / `context/adr/` |
| End session / hand work to another agent | `handoff` | User-invoked |
| Terse / token-efficient replies | `caveman` | Levels: lite, full, ultra, wenyan-* (default on via rule) |
| Document a resolved env/tooling fix | `less-trouble` | Writes `docs/troubleshoot/TROUBLESHOOT.md`; HITL repro template |
| Reverse-engineer legacy / undocumented code | `teach-me` | Cited docs under `context/rg/` |
| Initialise / standardise repo docs | `init-repo` | User-invoked (`/init-repo`) |
| Any bug, test failure, unexpected behavior | `systematic-debugging` | Root cause before fixes; symptom fixes are failure |
| Feature or fix with tests first | `test-driven-development` | Red → green → refactor; watch the test fail |
| Create or improve a skill | `writing-skills` | Skill authoring as TDD on process docs |
| Turn an idea into a design, before implementing | `brainstorming` | Design dialogue — not a substitute for `grill-me` on forks |
| Write, then run, an implementation plan | `writing-plans`, `executing-plans`, `subagent-driven-development` | Inline vs one subagent per task |
| Ask for or respond to a code review | `requesting-code-review`, `receiving-code-review` | Verify before implementing feedback |
| About to claim work is done | `verification-before-completion` | Evidence before assertions |
| Isolation, parallel work, closing a branch | `using-git-worktrees`, `dispatching-parallel-agents`, `finishing-a-development-branch` | |

If a task fits a skill above, load and follow that skill. Do not reinvent its process inline.

**`grill-me` vs `brainstorming`:** an architecture fork with real trade-offs goes to `grill-me` — one question at a time, and the outcome lands in `CONTEXT.md` or an ADR. Open-ended feature shaping goes to `brainstorming`, which produces a design document. When both fit, `grill-me` wins; `architecture-forks.mdc` makes that non-optional.

---

## Knowledge Capture

| Kind of knowledge | Where it goes |
|-------------------|---------------|
| Glossary / ubiquitous language | Project `CONTEXT.md` (via `grill-me`) |
| Hard-to-reverse architectural decisions | Project ADRs under `context/adr/` (3-gate rule) |
| Resolved env/tooling pain | `docs/troubleshoot/TROUBLESHOOT.md` (`less-trouble`) |
| Personal prefs, temporary context | User Rules / this template / Cursor memory |
| Team/project runbooks, API notes | Follow the project's existing docs layout |

Rules:

- If the current task already produced the relevant docs, comments, or examples, **do not duplicate** them elsewhere.
- If there is no obvious project doc location, **ask** before creating a new top-level doc.
- `CONTEXT.md` is glossary only — no implementation detail.
- Project handoffs live under `.cursor/handoffs/` when using the `handoff` skill.

---

## Personal Preferences

### Privacy

- Redact logs; never paste secrets (API keys, tokens, passwords, JWTs).
- Review shared output for sensitive data before posting.

### Code

- Prefer small, focused files and clear names.
- Prefer immutability where the stack makes that natural.
- Match the project's existing style; do not invent a parallel convention.

### Git

- Use the `commit` skill format (`type : subject` + why + `##` sections). Prefer `/commit`.
- Small, focused commits. Never push unless asked.

### Testing

- Prefer TDD for features and bugfixes that need lasting coverage.
- Coverage targets are project-specific — do not invent a global percentage unless the project already has one.

---

## Success Criteria

You are successful when:

- The relevant skill's process was followed when one applied
- Tests that matter for the change pass (or the gap is explicitly called out)
- No secrets leaked; no silent security regressions
- Glossary/ADR updates landed when decisions crystallised
- The user can continue (or hand off) without re-deriving context

---

**Philosophy:** Skills carry process. This file routes. Project docs hold shared truth.
