# AI COST POLICY

## Context Minimization

AI MUST:

- Load only task-relevant files
- Prefer summaries over full documents
- Avoid scanning entire repository
- Ignore human-only documentation

---

## Retrieval Strategy

Priority order:

1. AI_CONTEXT.md
2. Relevant source files
3. AGENTS.md sections
4. Memory ADRs

---

## Conversation Management

- Prefer stateless operations
- Avoid long multi-turn reasoning chains
- Reset context when task changes

---

## Large File Handling

For files > 1000 lines:

- Read only relevant sections
- Use semantic search
- Avoid full-file rewrites

---

## Change Scope Control

Prefer:

- Small incremental edits
- Patch-style modifications

Avoid:

- Full project regeneration
