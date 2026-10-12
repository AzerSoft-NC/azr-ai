# CONTEXT.md Format

Canonical twin: [teach-me/CONTEXT-FORMAT.md](../teach-me/CONTEXT-FORMAT.md). Keep both files byte-identical so `grill-me` works when installed without `teach-me`.

## Structure

```md
# {Context Name}

{One or two sentence description of what this context is and why it exists.}

## Language

**Order**:
{A one or two sentence description of the term}
_Avoid_: Purchase, transaction

**Invoice**:
A request for payment sent to a customer after delivery.
_Avoid_: Bill, payment request

**Customer**:
A person or organization that places orders.
_Avoid_: Client, buyer, account
```

## Rules

- **Be opinionated.** When multiple words exist for the same concept, pick the best one and list the others under `_Avoid_`.
- **Keep definitions tight.** One or two sentences max. Define what it IS, not what it does.
- **Only include terms specific to this project's context.** General programming concepts (timeouts, error types, utility patterns) don't belong even if the project uses them extensively. Before adding a term, ask: is this a concept unique to this context, or a general programming concept? Only the former belongs.
- **Group terms under subheadings** when natural clusters emerge. If all terms belong to a single cohesive area, a flat list is fine.

## Layered glossaries (workspace + project)

A checkout may sit under a parent workspace that also has a `CONTEXT.md`. Treat them as layers:

- **Workspace context** — `CONTEXT.md` at the workspace root. Shared language not specific to one App or tool repo.
- **Project context** — `CONTEXT.md` at an App or tool repo root. Language specific to that repo only.

**Discover (walk-up):** From the cwd, walk up the directory tree and read **every** `CONTEXT.md` found. Challenge terms against the full stack.

**Write (scope test):** If another repo in the same workspace would need the term with the same meaning → write to the Workspace context. Otherwise → write to the nearest Project context. Criterion: "Would another repo here need this word with the same sense?"

**Collisions:** Never silently override. If the same term appears (or conflicts) at two layers — duplicate or divergent — **grill** before changing either file.

**ADRs follow the same scope:** Changing the Workspace context → ADR under the workspace `context/adr/`. Changing only a Project context → ADR under that repo's `context/adr/` (or legacy `docs/adr/`).

## Single vs multi-context repos

**Single context (most repos):** One `CONTEXT.md` at the repo root.

**Multiple contexts:** A `CONTEXT-MAP.md` at the repo root lists the contexts, where they live, and how they relate to each other:

```md
# Context Map

## Contexts

- [Ordering](./src/ordering/CONTEXT.md) — receives and tracks customer orders
- [Billing](./src/billing/CONTEXT.md) — generates invoices and processes payments
- [Fulfillment](./src/fulfillment/CONTEXT.md) — manages warehouse picking and shipping

## Relationships

- **Ordering → Fulfillment**: Ordering emits `OrderPlaced` events; Fulfillment consumes them to start picking
- **Fulfillment → Billing**: Fulfillment emits `ShipmentDispatched` events; Billing consumes them to generate invoices
- **Ordering ↔ Billing**: Shared types for `CustomerId` and `Money`
```

The skill infers which structure applies:

- If `CONTEXT-MAP.md` exists, read it to find contexts
- If only a root `CONTEXT.md` exists, single context
- If neither exists, create a root `CONTEXT.md` lazily when the first term is resolved

When multiple contexts exist, infer which one the current topic relates to. If unclear, ask.

Layered workspace/project glossaries (walk-up) compose with the above: a repo may still be single- or multi-context *internally*, while also sitting under a Workspace context.
