# PROJECT CONTEXT FOR AI AGENTS

## Architecture Overview

- Core Layer: src/core/
- Service Layer: src/services/
- Interface Layer: src/api/

## Critical Components (DO NOT BREAK)

- Authentication system
- Database schema
- Public API contracts

## Entry Points

- Backend: src/main.py
- Frontend: src/app.tsx

## Dependency Rules

- Core layer must not depend on API layer
- Services may depend on Core only

## Known Constraints

- Python 3.11 only
- No global state
- Async-first design
