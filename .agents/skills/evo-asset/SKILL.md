---
name: evo-asset
description: >
  Structure, validate, and locally manage evolution assets (Gene, Capsule, EvolutionEvent).
  Use when the user wants to record a solution, document a bug fix, create a Gene or Capsule,
  capture an evolution process, or compute an asset_id locally.
  No network connection required. Trigger keywords: Gene, Capsule, EvolutionEvent,
  evolution asset, asset_id, record solution, save fix, document repair.
---

# evo-asset — Local Evolution Asset Management

This skill helps you structure any solved problem into a **Gene + Capsule + EvolutionEvent**
bundle, compute content-addressable IDs locally, and validate asset quality — all without
any network connection.

---

## 1. Core Concepts

| Term | Definition |
|---|---|
| **Gene** | A reusable *strategy template* describing **how** to approach a class of problems. Captures the abstract pattern (e.g., "retry with backoff"). |
| **Capsule** | A *validated fix or optimization* — a concrete implementation of a Gene applied to a specific problem. Captures what was done, confidence level, and scope of change. |
| **EvolutionEvent** | An *audit record* of the evolution process. Documents what was tried, how many attempts, and the final outcome. Strongly recommended in every bundle. |
| **asset_id** | A content-addressable fingerprint: `sha256:` + SHA256 hash of the asset's canonical JSON (with `asset_id` field excluded). Uniquely identifies each asset by its content. |
| **Bundle** | A Gene + Capsule (+ EvolutionEvent) published together. Gene and Capsule must always be paired. |

---

## 2. When to Use This Skill

Activate this skill when the user wants to:

- Record or document a solution they just implemented
- Create a Gene/Capsule/EvolutionEvent structure
- Compute a local `asset_id` for any asset JSON
- Validate whether a Capsule meets quality standards
- Understand the Gene/Capsule/EvolutionEvent data model

---

## 3. Bundle Rules

1. **Gene + Capsule must always be paired** — never save a Capsule without its companion Gene.
2. **EvolutionEvent is strongly recommended** — always include it as the third element.
3. Each asset has its **own independently computed `asset_id`**.
4. Asset type values are case-sensitive: `"Gene"`, `"Capsule"`, `"EvolutionEvent"`.
5. Categories / intents must be one of: `repair`, `optimize`, `innovate`.

---

## 4. Gene Structure

A Gene captures the abstract strategy — the *why and how* of a solution pattern.

```json
{
  "type": "Gene",
  "schema_version": "1.5.0",
  "category": "repair",
  "signals_match": ["TimeoutError", "ECONNREFUSED"],
  "summary": "Retry with exponential backoff on timeout errors",
  "validation": ["node tests/retry.test.js"],
  "asset_id": "sha256:<computed>"
}
```

| Field | Required | Type | Constraints |
|---|---|---|---|
| `type` | Yes | string | Must be `"Gene"` |
| `schema_version` | Yes | string | `"1.5.0"` |
| `category` | Yes | string | `repair` / `optimize` / `innovate` |
| `signals_match` | Yes | string[] | Min 1 item, each item min 3 chars |
| `summary` | Yes | string | Min 10 characters |
| `validation` | No | string[] | Local validation commands (node/npm/npx only) |
| `asset_id` | Yes | string | `sha256:` + hash (compute via script) |

---

## 5. Capsule Structure

A Capsule captures the concrete implementation — the *what was done* with measurable outcomes.

```json
{
  "type": "Capsule",
  "schema_version": "1.5.0",
  "trigger": ["TimeoutError", "ECONNREFUSED"],
  "gene": "sha256:<gene_asset_id>",
  "summary": "Fix API timeout with bounded retry and connection pooling",
  "confidence": 0.85,
  "blast_radius": { "files": 3, "lines": 52 },
  "outcome": { "status": "success", "score": 0.85 },
  "success_streak": 4,
  "env_fingerprint": {
    "node_version": "v22.0.0",
    "platform": "win32",
    "arch": "x64"
  },
  "asset_id": "sha256:<computed>"
}
```

| Field | Required | Type | Constraints |
|---|---|---|---|
| `type` | Yes | string | Must be `"Capsule"` |
| `schema_version` | Yes | string | `"1.5.0"` |
| `trigger` | Yes | string[] | Min 1 item, each item min 3 chars |
| `gene` | No | string | Companion Gene's `asset_id` |
| `summary` | Yes | string | Min 20 characters |
| `confidence` | Yes | number | 0–1 (how certain this fix is correct) |
| `blast_radius` | Yes | object | `{ "files": N, "lines": N }` — scope of change |
| `outcome` | Yes | object | `{ "status": "success"/"failure", "score": 0–1 }` |
| `env_fingerprint` | Yes | object | `{ "platform": "...", "arch": "..." }` |
| `success_streak` | No | integer | Consecutive successes |
| `asset_id` | Yes | string | `sha256:` + hash (compute via script) |

---

## 6. EvolutionEvent Structure

An EvolutionEvent records the evolution *process* that produced a Capsule.
Always include it — bundles without it have lower quality scores.

```json
{
  "type": "EvolutionEvent",
  "intent": "repair",
  "capsule_id": "sha256:<capsule_asset_id>",
  "genes_used": ["sha256:<gene_asset_id>"],
  "outcome": { "status": "success", "score": 0.85 },
  "mutations_tried": 3,
  "total_cycles": 5,
  "asset_id": "sha256:<computed>"
}
```

| Field | Required | Type | Constraints |
|---|---|---|---|
| `type` | Yes | string | Must be `"EvolutionEvent"` |
| `intent` | Yes | string | `repair` / `optimize` / `innovate` |
| `capsule_id` | No | string | The companion Capsule's `asset_id` |
| `genes_used` | No | string[] | Array of Gene `asset_id`s used |
| `outcome` | Yes | object | `{ "status": "success"/"failure", "score": 0–1 }` |
| `mutations_tried` | No | integer | How many approaches were attempted |
| `total_cycles` | No | integer | Total iterations in the process |
| `asset_id` | Yes | string | `sha256:` + hash (compute via script) |

---

## 7. Asset ID — Local Computation

Every asset's `asset_id` is a **content-addressable hash** computed locally.

### Algorithm (language-agnostic)

```
1. Start with the asset JSON object (dict/object)
2. REMOVE the "asset_id" field if it exists
3. Sort ALL keys at ALL nesting levels alphabetically (canonical JSON)
4. Serialize to a compact string — no extra spaces, no newlines
5. Encode the string as UTF-8 bytes
6. Compute SHA256 of those bytes
7. Output:  "sha256:" + hex_digest
```

> **Critical**: Keys must be sorted recursively at every level. A difference in key order
> produces a different hash and will fail validation.

### Using the provided scripts

**Node.js:**

```bash
node scripts/compute_asset_id.js examples/gene_example.json
# Output: sha256:3a7f2c...
```

**Python:**

```bash
# Linux / macOS
python3 scripts/compute_asset_id.py examples/gene_example.json

# Windows (Python Launcher)
py -3 scripts/compute_asset_id.py examples/gene_example.json

# Output: sha256:3a7f2c...
```

Both scripts produce identical output for the same input.

---

## 8. Capsule Quality Standards

A Capsule passes the local quality check when **all** of the following hold:

| Check | Requirement |
|---|---|
| Outcome score | `outcome.score >= 0.7` |
| Blast radius: files | `blast_radius.files > 0` |
| Blast radius: lines | `blast_radius.lines > 0` |
| Summary length | `summary.length >= 20` |
| Trigger signals | At least 1 signal, each >= 3 chars |

Additional factors that improve quality (not hard requirements):

- Smaller `blast_radius` (more focused fix = higher precision)
- Higher `success_streak` (more repeated successes = more reliable)
- Confidence closer to 1.0

---

## 9. AI Operation SOP

When this skill is triggered, follow these steps:

**Step 1 — Understand the problem**
Ask (or infer from context):

- What problem was solved? (brief description)
- What type? `repair` (bug fix) / `optimize` (performance) / `innovate` (new capability)
- What signals/errors triggered it? (e.g., error message, symptom)
- How many files/lines were changed?
- Did it succeed?

**Step 2 — Fill the Gene**
Create `gene.json` (without `asset_id`):

- `category` = the problem type
- `signals_match` = error keywords or symptom strings
- `summary` = the abstract strategy (≥10 chars)

Compute: `node scripts/compute_asset_id.js gene.json` → save result as Gene's `asset_id`.

**Step 3 — Fill the Capsule**
Create `capsule.json` (without `asset_id`):

- `trigger` = same signals as Gene's `signals_match`
- `gene` = Gene's `asset_id` from Step 2
- `summary` = what was concretely done (≥20 chars)
- `confidence` = how confident the fix is (0–1)
- `blast_radius` = actual files/lines changed (must be > 0)
- `outcome.score` = effectiveness score (must be ≥0.7 to pass quality)
- `env_fingerprint` = current platform info

Compute: `node scripts/compute_asset_id.js capsule.json` → save as Capsule's `asset_id`.

**Step 4 — Fill the EvolutionEvent**
Create `event.json` (without `asset_id`):

- `intent` = same as Gene's `category`
- `capsule_id` = Capsule's `asset_id` from Step 3
- `genes_used` = [Gene's `asset_id`]
- `mutations_tried` = number of approaches attempted
- `total_cycles` = total iterations

Compute: `node scripts/compute_asset_id.js event.json` → save as EvolutionEvent's `asset_id`.

**Step 5 — Validate & finalize**
Run quality checks (Step 8). If passed, assemble the final bundle:

```json
{
  "bundle": [
    { ...gene_with_asset_id... },
    { ...capsule_with_asset_id... },
    { ...event_with_asset_id... }
  ]
}
```

Save to a local file for archiving. Show the user the filled bundle and quality results.

---

## Quick Reference

| What | How |
|---|---|
| Compute asset_id (Node) | `node scripts/compute_asset_id.js <file.json>` |
| Compute asset_id (Python/Linux) | `python3 scripts/compute_asset_id.py <file.json>` |
| Compute asset_id (Python/Win) | `py -3 scripts/compute_asset_id.py <file.json>` |
| Gene template | `examples/gene_example.json` |
| Capsule template | `examples/capsule_example.json` |
| EvolutionEvent template | `examples/evolution_event_example.json` |
| category/intent values | `repair` / `optimize` / `innovate` |
| Minimum score to pass | `outcome.score >= 0.7` |
