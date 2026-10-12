# Global Config Templates

Pointer and legacy filename for the Cursor router.

| File | Role |
|------|------|
| [user-CURSOR.md](./user-CURSOR.md) | Points at [../rules/skill-router.mdc](../rules/skill-router.mdc) — **not** pasted into User Rules |

Cursor is the only target. Claude Code support was dropped (workspace ADR 0002).

## Router source of truth

- **Installed:** `~/.cursor/rules/skill-router.mdc` (from [install-skills.sh](../install-skills.sh))
- **Catalog:** [../rules/skill-router.mdc](../rules/skill-router.mdc)

## Skills referenced

Run [../install-skills.sh](../install-skills.sh) first.

Authored here: `commit`, `contract-first`, `grill-me`, `handoff`, `caveman`, `less-trouble`, `teach-me`, `map-architecture`, `init-repo`.

Vendored (pinned): superpowers process skills, `skill-inspector` (SkillSpector). See [../README.md](../README.md).
