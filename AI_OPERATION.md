# AI OPERATION MANUAL FOR CODING AGENTS

Purpose: Define deterministic behavior for AI agents when analyzing,
modifying, and generating code in this repository.

Enforcement Level: MANDATORY

---

## 🔍 1. CONTEXT ACQUISITION

AI MUST:

- Load ONLY files relevant to the current task
- Prefer semantic search over full-project scanning
- Avoid reading human-only documentation
- Prioritize AI_CONTEXT.md if available

AI MUST NOT:

- Scan entire repository without justification
- Assume knowledge of unseen files

---

## ✂️ 2. LOCALIZED CHANGE POLICY

When modifying code:

- Make the smallest change necessary
- Prefer patch-style edits over full rewrites
- Preserve existing behavior unless instructed
- Maintain backward compatibility

Forbidden:

- Global refactoring during targeted tasks
- Reformatting unrelated code
- Renaming public symbols without migration plan

---

## 🧱 3. MODULE BOUNDARY RULE

AI MUST respect architectural boundaries:

- Modify ONLY affected modules
- Do not introduce cross-layer dependencies
- Do not merge unrelated components
- Keep responsibilities separated

---

## 🧪 4. REUSE BEFORE CREATE

Before writing new code, AI MUST:

1. Search for existing implementations
2. Prefer reuse over duplication
3. Extend existing modules when appropriate

AI MUST NOT:

- Reimplement existing functionality
- Create parallel systems

---

## 📦 5. STRUCTURE PRESERVATION

AI SHOULD:

- Maintain file organization
- Avoid unnecessary file moves
- Prefer additive changes

Destructive operations require justification.

---

## 🧠 6. LARGE CHANGE PROTOCOL

If change affects multiple modules:

AI MUST provide:

- Rationale
- Impact analysis
- Migration strategy

---

## 🚫 7. ANTI-HALLUCINATION SAFEGUARDS

AI MUST NOT:

- Invent APIs
- Assume undocumented behavior
- Modify files not inspected
- Guess configuration values

If uncertainty exists → request clarification.

---

## ⚡ 8. PERFORMANCE AWARENESS

AI SHOULD:

- Prefer efficient algorithms
- Avoid unnecessary complexity
- Respect project constraints

---

## 📜 9. CODE QUALITY STANDARD

Generated code MUST be:

- Readable over clever
- Deterministic over speculative
- Consistent with project style
- Properly documented when non-obvious

---

## 🧩 10. AI-FRIENDLY DESIGN GUIDELINES

New modules SHOULD:

- Follow single responsibility principle
- Expose clear public interfaces
- Minimize side effects
- Prefer stateless designs

Avoid:

- God objects
- Deep inheritance chains
- Hidden global state

---

## 🔒 11. SAFE DELETION RULE

Before deleting code, AI MUST verify:

- Code is unused
- No external dependency exists
- Removal does not break public API

If uncertain → do not delete.

---

## 🧭 12. PRIORITY ORDER

When rules conflict, follow:

1. AGENTS.md (governance)
2. PROJECT_GOVERNANCE.md
3. AI_OPERATION.md
4. Existing project conventions
5. AI preference
