---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up.
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work. Save it under the **workspace** path `.cursor/handoffs/` (create the directory if missing). Do **not** write to the OS temp directory.

Name the file with a short slug and date, e.g. `.cursor/handoffs/YYYY-MM-DD-<topic>.md`.

Include a "suggested skills" section in the document, which suggests skills that the agent should invoke.

Do not duplicate content already captured in other artifacts (PRDs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.

When done, tell the user the full path of the handoff file.
