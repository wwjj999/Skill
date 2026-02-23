# Claude Code & Projects Configuration

This file serves as the source of truth for Claude Code CLI and Claude Projects.

## 🏗️ Build & Test

- **Build**: `npm install` (JS) or `pip install -r requirements.txt` (Python)
- **Test**: `npm test` (JS) or `pytest` (Python)
- **Lint**: `npm run lint` (JS) or `ruff check .` (Python)

## 🛠️ Antigravity Skills (Commands)

This project uses specialized agents (Skills) for core tasks. Use these commands:

- **Format Code**: `node .agents/skills/format-js/script.js` (example) - *See SKILL.md for exact usage*
- **Lint Code**: *See .agents/skills/lint-js/SKILL.md*
- **Commit**: *See .agents/skills/git-commit/SKILL.md*

### Skills Index

- **format-js**: `.agents/skills/format-js/SKILL.md`
- **lint-js**: `.agents/skills/lint-js/SKILL.md`
- **format-python**: `.agents/skills/format-python/SKILL.md`
- **lint-python**: `.agents/skills/lint-python/SKILL.md`
- **generate-changelog**: `.agents/skills/generate-changelog/SKILL.md`
- **run-tests**: `.agents/skills/run-tests/SKILL.md`
- **security-check**: `.agents/skills/security-check/SKILL.md`

## 🧩 Style & Conventions

- Follow strict separation of concerns.
- Use the Skills for all formatting and linting to ensure consistency.
