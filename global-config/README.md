# Global Config Templates

Portable **router** file for Cursor. It points at skills; it does not replace them.

Copy it into the install location below, then edit personal preferences as needed. Keep the skill catalog in [../skills/](../skills/) as the source of truth for workflows.

| File | Tool | Install location |
|------|------|------------------|
| [user-CURSOR.md](./user-CURSOR.md) | Cursor | User Rules (paste) or adapt into `AGENTS.md` |

Cursor is the only target. The Claude Code variant was dropped — keeping two routers in sync bought nothing once Cursor became the only harness in use.

## What these are

- **Philosophy** — how the agent should approach work
- **Skill router** — which skill to reach for, given a trigger
- **Knowledge capture** — where glossary, ADRs, and personal prefs live

## What these are not

- Not a dump of skill bodies (those stay in `skills/`)
- Not project-level docs (use `CONTEXT.md`, ADRs, and project rules per repo)

## Skills referenced

Run [../install-skills.sh](../install-skills.sh) first — it copies this catalog and the vendored upstream skills (see [../README.md](../README.md)).

Authored here: `commit`, `grill-me`, `handoff`, `caveman`, `less-trouble`, `teach-me`, `init-repo`.

Vendored from superpowers: `systematic-debugging`, `test-driven-development`, `writing-skills`, `brainstorming`, `writing-plans`, `executing-plans`, `subagent-driven-development`, `requesting-code-review`, `receiving-code-review`, `verification-before-completion`, `using-git-worktrees`, `dispatching-parallel-agents`, `finishing-a-development-branch`, `diagnosing-superpowers`.
