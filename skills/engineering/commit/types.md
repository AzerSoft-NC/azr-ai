# Commit types

Infer type from the diff. User hints and approval overrides take precedence.

| Type | Use when |
|------|----------|
| `revert` | Reverts a previous commit or release |
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `refactor` | Optimisation and refactoring — no new feature, no bug fix |
| `performance` | Performance or resource improvement |
| `test` | New or corrected tests |
| `chore` | Routine maintenance and housekeeping |

## Inference signals

| Diff signal | Likely type |
|-------------|-------------|
| New public behaviour, endpoints, UI | `feat` |
| Corrects wrong behaviour | `fix` |
| Only `*.md` or doc comments | `docs` |
| Only `*Test*` / test directories | `test` |
| `package-lock.json`, version bumps in manifests, tooling upkeep | `chore` |
| Restructure with same behaviour | `refactor` |
| Measurable runtime or resource improvement | `performance` |
| `git revert` context | `revert` |

When signals conflict, prefer the type that best describes **user-visible impact**.
