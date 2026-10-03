# TROUBLESHOOT.md Format

## Structure

```md
# Troubleshooting

{One sentence: what this file covers.}

## Table of contents

- [{Issue title}](#{anchor})

## {Issue title}

**Symptom:** {What the user sees — error message, log line, or behavior. Quote exact errors when possible.}

**Cause:** {Root cause in plain language. Name versions, mismatches, or race conditions.}

**Fix:** {What was applied — config change, rebuild command, version pin.}

**Prevention:** {How to avoid recurrence — .nvmrc, postinstall, checklist step.}

**Files:** {Comma-separated paths touched, e.g. `.nvmrc`, `nuxt.config.ts`}
```

## Rules

- **One section per distinct issue.** Don't merge unrelated failures into one entry.
- **Symptom first.** Future readers search by error text, not by root cause.
- **Quote exact errors** when available — paraphrase only when the message is noisy.
- **Fix = what we did**, not a menu of options. If multiple fixes were tried, note which one stuck.
- **Prevention = actionable.** Commands, pins, config keys — not "be careful."
- **Anchor slugs:** lowercase, hyphens, no special chars — e.g. `better-sqlite3-node-abi-mismatch`.
- **Update TOC** every time a section is added or renamed. Keep TOC order alphabetical by issue title.
- **No secrets.** Redact tokens, keys, host-specific paths unless they're the project's documented defaults.

## Location

Lives at `docs/troubleshoot/TROUBLESHOOT.md`. Create the directory lazily on first resolved issue.
