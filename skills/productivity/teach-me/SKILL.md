---
name: teach-me
description: Reverse-engineer unfamiliar or legacy code that has no spec — trace it, interview you to fill the gaps, verify every claim against the code, and write cited docs to context/rg/. Use when the user wants to understand, learn, or onboard onto legacy or undocumented code, asks how a specific piece of code works, or faces a codebase with no spec.
---

# Teach Me

Reverse-engineer legacy code that has no spec, and leave the understanding behind for the next reader. The discipline is **citation**: nothing enters a doc unless the code proves it, and anything the code can't prove is marked an **assumption**, not a fact.

You run in a loop over one user-named target at a time. You do not narrate the code back — you extract *why* it exists, *how* it flows, and *what* will surprise the next reader.

## File structure

```
/
├── CONTEXT.md              ← domain glossary (shared with grill-me)
└── context/
    └── rg/                 ← reverse-engineering docs, one per unit
        ├── auth-flow.md
        └── billing-cron.md
```

Create files lazily — only when you have something proven to write. If `CONTEXT.md` exists, extend it; never fork a second glossary. When a parent Workspace context exists, follow layered glossary rules in [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md) (walk-up discover, scope-test write, grill on collisions).

## Documentation language

Write all documentation you produce — `context/rg/` docs, `CONTEXT.md` — in **English**, regardless of the language of the conversation or the codebase. Keep code identifiers, type names, file paths, and citations as they appear in the code.

## The loop

Repeat per target until the user stops.

### 1. Scope

The user names a target — a file, directory, feature, or "this". Read it. Trace its dependencies in and out. Expand to neighbouring code **only** when a flow forces you to; do not sweep the whole repo.

If [`context/architecture-graph.json`](../../../context/architecture-graph.json) exists, read it first to locate which component (app, CI pack, infra remote, platform service) owns the target and which edges matter — then grep or open files. Treat the graph as a **map, not evidence**; citations remain `file:line` you verified.

Completion: you can name the unit's entry points and its immediate dependencies.

### 2. Trace

Follow each key flow through the code. For every claim you intend to write, capture the evidence: `file:line` or the call path that proves it. A claim you cannot pin to code is not yet a claim.

Completion: every key flow has a cited path from entry to effect.

### 3. Interview

Interview the user to fill what the code can't tell you — intent, history, external constraints, dead code. Ask **one question at a time**, wait for the answer, and give your recommended answer with each question.

Cross-reference every answer against the code. When they contradict, surface it immediately: "You said cancellation refunds the order, but `cancel()` at `orders.py:88` only flips a flag — which is right?"

Completion: no open question that the user could answer is still open.

### 4. Verify

An uncited claim is an **assumption**. Try to resolve each one — dig deeper in the code, or ask the user. Whatever survives unresolved goes into the doc's *Open assumptions* section, labelled as such. Never launder an assumption into a fact.

Completion: every statement is either cited or explicitly marked an assumption.

### 5. Document

Write `context/rg/<unit>.md` following [RG-FORMAT.md](./RG-FORMAT.md). Draw the flows a human would rather see than read as mermaid charts (sequence, flowchart, state, ER) — every node and edge traced to cited code. Push any discovered domain term to the correct `CONTEXT.md` layer using [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md) (scope test: shared → Workspace context, local → Project context) — the term's definition lives in the glossary, the flows live in the rg doc. One concept, one home.

Then add source comments **only where they earn it**: intent, trade-offs, constraints, or a landmine the code cannot express. Never narrate what the code already says.

<bad-example>
```java
// check if the id is null
if (user.getId() == null)
```
</bad-example>

<good-example>
```java
// legacy import path leaves id null until the nightly backfill runs (see context/rg/user-import.md)
if (user.getId() == null)
```
</good-example>

Completion: doc written, terms in glossary, comments added only where non-obvious.

### 6. Next

Move to the next target, or stop.

## Done

The run is complete when the target and every flow you traced are documented with citations, every domain term is in `CONTEXT.md`, and every open assumption is listed for the user to confirm later.
