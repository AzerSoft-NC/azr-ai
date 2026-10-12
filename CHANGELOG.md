# Changelog

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- Skill `contract-first` — boundary contracts (OpenAPI, AsyncAPI, JSON Schema); adapted from ECC (MIT), CAFAT-specific sections omitted.
- Rule `skill-router.mdc` — always-on router (philosophy, skill map, knowledge capture); replaces manual User Rules paste.
- Rule `clean-code.mdc` — clean code within the requested change only.
- Vendored `skill-inspector` (NVIDIA SkillSpector), pinned; optional `skillspector` CLI via `uv`.
- Pinned superpowers vendor commit (`SUPERPOWERS_REF` in `install-skills.sh`).
- Layered workspace + project glossaries in `grill-me` / `teach-me` (`CONTEXT-FORMAT.md`).
- `CHANGELOG.md`.

### Changed

- `handoff` writes to `context/handoffs/` (not `.cursor/handoffs/`).
- Installer patches installed copies of `writing-plans` and `brainstorming` to use `context/plans/` and `context/specs/`.
- [global-config/user-CURSOR.md](./global-config/user-CURSOR.md) is a pointer to `skill-router.mdc` only.
- README and skill index updated for new router, vendors, and agent-doc conventions.

### Removed

- CAFAT-only catalog content from upstream `ai-skills` (not ported): `flux-amq`, `revue-java`, `new-app`, `guidelines/`, `cafat-branching`, etc.
