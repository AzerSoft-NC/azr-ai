---
name: map-architecture
description: Maintain the curated workspace architecture graph at context/architecture-graph.json — add or update component nodes, tags, and edges when CI, infra, platform, or apps change. Use when the user asks to update the architecture map, after ADRs or platform changes, when onboarding agents, or when the graph is missing or clearly stale.
---

# Map Architecture

Keep [`context/architecture-graph.json`](../../../context/architecture-graph.json) accurate. This is a **curated component map** (apps, CI packs, infra remotes, platform services, docs) — not a code AST graph and not a glossary (that stays in [`CONTEXT.md`](../../../CONTEXT.md)).

## When to run

- New or renamed app under `src/<client>/`
- New infra remote, chart, or platform service
- Compose ↔ K3s transition or deploy path change
- User says "update the architecture graph" / "map the workspace"
- Rule `architecture-graph` flagged missing or stale graph

## Graph contract

**File:** `context/architecture-graph.json`

| Field | Rule |
|-------|------|
| `version` | Integer schema version (currently `1`) |
| `updated` | ISO date `YYYY-MM-DD` on every write |
| `nodes[].id` | `<category>.<slug>` — unique |
| `nodes[].category` | One of: `workspace`, `ci`, `infra`, `app`, `platform`, `ai`, `docs` |
| `nodes[].tags` | Optional multi-value filters (see below) |
| `nodes[].path` | Repo-relative path when the node maps to disk |
| `nodes[].summary` | One line: what it does |
| `edges[].rel` | One of: `owns_path`, `depends_on`, `deploys`, `routes_to`, `stores_in`, `authenticates_via`, `documents`, `same_as` |

**Tag vocabulary** (orthogonal to `category`):

- **layer:** `edge`, `auth`, `gateway`, `data`, `cache`, `storage`, `mail`, `product`, `ops`
- **tech:** `typescript`, `astro`, `java`, `terraform`, `helm`, `ansible`, `bash`, `compose`, `k3s`, `k3d`, `gha`, `postgres`, `valkey`, `s3`, `oidc`, `nginx`
- **deploy:** `chart`, `compose`, `terraform`, `ansible`, `gha`, `just`
- **env:** `local`, `droplet`, `both`
- **status:** `target`, `transition`, `legacy`
- **client:** `azer-soft`, `my-supplement`, `plein-cap`, `poke-bar` (mainly on `app` nodes)

## Workflow

1. **Read** the current JSON and [`docs/architecture.md`](../../../docs/architecture.md) for target topology.
2. **Diff mentally** — what nodes/edges changed? Propose deltas to the user if the change is ambiguous (new `same_as` edge, split platform service, etc.).
3. **Edit** JSON: add/update/remove nodes and edges; bump `updated`.
4. **Validate** before saving:
   - All `id` values unique
   - Every edge `from` / `to` references an existing node
   - No file-level or symbol-level nodes (component grain only)
   - `path` points at real directories/files when you can check (nested `src/` may be gitignored — warn, do not invent apps)
5. **Changelog** — if the map change reflects user-visible architecture, add one line under `[Unreleased]` in [`CHANGELOG.md`](../../../CHANGELOG.md).
6. **Do not** generate HTML, MCP servers, or auto-scan the repo tree.

## Forbidden

- Replacing or duplicating `CONTEXT.md` terminology
- Nodes for individual source files, functions, or `node_modules`
- Bulk import from graphify or other AST tools

## Querying (for agents)

Read the JSON and filter by `category`, `tags`, or walk `edges` from a known `id`. Treat output as a **map, not evidence** — confirm behavior by opening cited paths.
