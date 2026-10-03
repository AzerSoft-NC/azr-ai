---
name: less-trouble
description: Capture resolved dev-environment issues into docs/troubleshoot/TROUBLESHOOT.md so the same bug is not debugged twice. Use when a bug is fixed, user says "less trouble" / "document this fix", dev server won't start, native module ABI errors, or after a debugging session concludes.
---

# Less Trouble

After a dev-environment issue is **resolved**, write it down before the context is lost. Goal: next agent (or future you) finds the answer in `docs/troubleshoot/TROUBLESHOOT.md` instead of re-diagnosing from scratch.

Inspired by [grill-me](../grill-me/SKILL.md): lazy file creation, inline updates, strict format — but for operational pain, not domain language.

## When to run

- User invokes `/less-trouble` or asks to document a fix
- Debugging session just concluded with a confirmed fix
- User hits a symptom that matches an existing entry — **read the doc first**, apply the fix, skip re-diagnosis

## File structure

```
docs/
└── troubleshoot/
    └── TROUBLESHOOT.md    # single file, TOC at top, one section per issue
```

Create `docs/troubleshoot/` lazily — only when there is something to write.

## Workflow

### 1. Check existing docs

Read `docs/troubleshoot/TROUBLESHOOT.md` if it exists. Search for the symptom (error text, package name, config key).

- **Match found** → apply documented fix, tell user which entry. Update entry only if fix or cause changed.
- **No match** → continue.

### 2. Confirm the fix

Do not document until:

- [ ] Symptom reproduced (or user confirms it was real)
- [ ] Fix applied and verified (dev starts, error gone, test passes)
- [ ] Root cause identified — not just "it works now"

If still debugging, use the `systematic-debugging` skill first (vendored from superpowers). When you cannot reproduce the bug yourself, [scripts/hitl-loop.template.sh](./scripts/hitl-loop.template.sh) walks the user through the steps in their own terminal and prints their answers back as `KEY=VALUE` for you to parse.

### 3. Write or update the entry

Use the format in [TROUBLESHOOT-FORMAT.md](./TROUBLESHOOT-FORMAT.md).

- **New issue** → add section + TOC link
- **Same issue, better fix** → update existing section, note what changed
- **Duplicate symptom, different cause** → new section (don't overwrite)

Capture inline during the session — don't batch for end of chat.

### 4. Cross-reference codebase

Note which files embody the fix (`.nvmrc`, `nuxt.config.ts`, `package.json` scripts). If the fix is only in docs but not in code, flag that — the doc will rot.

## Entry template

```markdown
## {Issue title}

**Symptom:** …

**Cause:** …

**Fix:** …

**Prevention:** …

**Files:** …
```

## Anti-patterns

- **Don't** write ADR-length essays — this is a runbook, not architecture.
- **Don't** duplicate README setup steps — link to README for first-time setup; TROUBLESHOOT is for *things that broke*.
- **Don't** document transient upstream bugs without the workaround *and* a re-check trigger (e.g. "remove when Nuxt > X").

## Completion

After updating, tell the user:

1. Which section was added or updated (with anchor)
2. Any follow-up still needed in code (pin missing, script not added)
