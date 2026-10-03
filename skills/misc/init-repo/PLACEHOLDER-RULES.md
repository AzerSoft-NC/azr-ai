# Placeholder vs substantive rules

A **placeholder** file may be scaffolded. A **substantive** file must not be modified.

## `.gitignore`

Always treated as a **merge** — never placeholder, never full replace.

## `README.md`

| Placeholder | Substantive |
|-------------|-------------|
| Absent | — |
| Only `# {title}` or title + one line | Sections **Prerequisites**, **Run**, **Install**, or **Usage** with real content |
| Fewer than ~10 non-empty lines, no concrete instructions | Build/run instructions, config, or detailed doc links |

## `CHANGELOG.md`

| Placeholder | Substantive |
|-------------|-------------|
| Absent | — |
| Title only (`# Changelog`) | Version entry `## [x.y.z]` or `## [Unreleased]` with bullets under Added/Changed/Fixed |

## `CONTEXT.md`

| Placeholder | Substantive |
|-------------|-------------|
| Absent | — |
| Title + one-line description, empty `## Language` | At least one term defined under `## Language` with definition text |

## `docs/architecture.md`

| Placeholder | Substantive |
|-------------|-------------|
| Absent | — |
| Only `# Architecture` or empty section headings | **Stack** or **Structure** section with facts (versions, tree, diagram) |

## Directories `context/adr/`, `context/rg/`

Create if absent. Presence alone (empty or `.gitkeep`) is not a placeholder signal — do not delete existing content.
