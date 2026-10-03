---
name: grill-me
description: Build and sharpen the domain model — glossary, ADRs, and design boundaries. Use by default when a task admits multiple valid architectural approaches with real trade-offs (e.g. mapper vs align model on API contract, local state vs server refetch) — ask before implementing. Also use when the user wants to stress-test a plan, pin down terminology, record an architectural decision, or update CONTEXT.md outside a formal grill session. Merely reading CONTEXT.md for vocabulary is not this skill; use it when you are changing the model, not just consuming it.
---

<what-to-do>

Actively build and sharpen the project's domain model. In a **grill session**, interview me relentlessly about every aspect of this plan until we reach a shared understanding. Outside a grill, apply the same discipline — challenge terms, stress-test scenarios, and write glossary entries and ADRs the moment they crystallise. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time, waiting for feedback on each question before continuing.

If a question can be answered by exploring the codebase, explore the codebase instead.

</what-to-do>

<supporting-info>

## Domain awareness

During codebase exploration, also look for existing documentation:

### File structure

Most repos have a single context:

```
/
├── CONTEXT.md
├── context/
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

If a `CONTEXT-MAP.md` exists at the root, the repo has multiple contexts. The map points to where each one lives:

```
/
├── CONTEXT-MAP.md
├── context/
│   └── adr/                          ← system-wide decisions
├── src/
│   ├── ordering/
│   │   ├── CONTEXT.md
│   │   └── context/adr/              ← context-specific decisions
│   └── billing/
│       ├── CONTEXT.md
│       └── context/adr/
```

Create files lazily — only when you have something to write.
If no `CONTEXT.md` exists, create one when the first term is resolved.
If no `context/adr/` exists, create it when the first ADR is needed. Prefer `context/adr/`; if the project already uses legacy `docs/adr/`, keep writing there.

## During the session

### Challenge against the glossary

When the user uses a term that conflicts with the existing language in `CONTEXT.md`, call it out immediately. "Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?"

### Sharpen fuzzy language

When the user uses vague or overloaded terms, propose a precise canonical term. "You're saying 'account' — do you mean the Customer or the User? Those are different things."

### Discuss concrete scenarios

When domain relationships are being discussed, stress-test them with specific scenarios. Invent scenarios that probe edge cases and force the user to be precise about the boundaries between concepts.

### Cross-reference with code

When the user states how something works, check whether the code agrees. If you find a contradiction, surface it: "Your code cancels entire Orders, but you just said partial cancellation is possible — which is right?"

### Update CONTEXT.md inline

When a term is resolved, update `CONTEXT.md` right there. Don't batch these up — capture them as they happen. Use the format in [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md).

`CONTEXT.md` should be totally devoid of implementation details. Do not treat `CONTEXT.md` as a spec, a scratch pad, or a repository for implementation decisions. It is a glossary and nothing else.

### Offer ADRs sparingly

Only offer to create an ADR when all three are true:

1. **Hard to reverse** — the cost of changing your mind later is meaningful
2. **Surprising without context** — a future reader will wonder "why did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and you picked one for specific reasons

If any of the three is missing, skip the ADR. Use the format in [ADR-FORMAT.md](./ADR-FORMAT.md).

### Design heuristics

When the model starts dictating code boundaries rather than vocabulary, these references carry the heuristics: [deep-modules.md](./deep-modules.md) for interface-to-implementation ratio, [interface-design.md](./interface-design.md) for taking dependencies as parameters, and [refactoring.md](./refactoring.md) for what to look for once the tests are green.

### When a new ADR contradicts an existing ADR

Before writing, scan existing ADRs in the project's ADR directory. If the new decision contradicts or replaces an earlier one:

1. **Archive the old ADR** — rename `NNNN-slug.md` → `NNNN-slug_ARCHIVED.md`
2. **Prefix the archived file's content** with (blank line after the blockquote):
   ```
   > * ⚠️ OBSOLETE

   ```
   Optionally add a second line in the blockquote: `Superseded by ADR-NNNN` (or link to the new file).
3. **Write the new ADR** with the next sequential number — do not reuse the archived number.
4. Tell the user which ADR was archived and which replaces it.

## Question format

Each turn ends with exactly one question (unless the session is complete). Structure:

```markdown
**[Branch]** — [why this matters now]

[Single question?]

**Recommended:** [your answer] — [one-line rationale]
```

If codebase or docs exploration answered part of the question, lead with findings:

```markdown
**From codebase:** [what you found, with paths if useful]

**[Branch]** — [remaining ambiguity]

[Single question?]

**Recommended:** [your answer] — [one-line rationale]
```

## Completion

Stop when every branch in scope has a resolved decision or explicit assumption, and no open dependencies remain. Summarize with a short **Decision log** — resolved choices and assumptions, grouped by branch. List any `CONTEXT.md` updates and ADRs created or offered during the session.

</supporting-info>
