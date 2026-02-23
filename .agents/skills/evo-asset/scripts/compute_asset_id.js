#!/usr/bin/env node
/**
 * compute_asset_id.js
 *
 * Computes the content-addressable asset_id for an EvoMap evolution asset.
 *
 * Algorithm:
 *   sha256(canonical_json(asset_without_asset_id_field))
 *
 * Canonical JSON = all keys sorted alphabetically at every nesting level,
 * serialized as a compact string (no extra whitespace).
 *
 * Usage:
 *   node compute_asset_id.js <asset.json>
 *
 * Output:
 *   sha256:<hex_digest>
 *
 * Example:
 *   node compute_asset_id.js examples/gene_example.json
 *   sha256:3a7f2c9d...
 */

'use strict';

const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

// ── Helpers ────────────────────────────────────────────────────────────────

/**
 * Recursively sort all object keys alphabetically (canonical JSON).
 * Arrays preserve their order; only object keys are sorted.
 */
function sortKeysDeep(value) {
  if (Array.isArray(value)) {
    return value.map(sortKeysDeep);
  }
  if (value !== null && typeof value === 'object') {
    return Object.keys(value)
      .sort()
      .reduce((acc, key) => {
        acc[key] = sortKeysDeep(value[key]);
        return acc;
      }, {});
  }
  return value;
}

/**
 * Compute sha256 of a UTF-8 string, return hex digest.
 */
function sha256(str) {
  return crypto.createHash('sha256').update(str, 'utf8').digest('hex');
}

// ── Main ───────────────────────────────────────────────────────────────────

const filePath = process.argv[2];

if (!filePath) {
  console.error('Usage: node compute_asset_id.js <asset.json>');
  console.error('');
  console.error('  Reads the JSON file, removes the "asset_id" field,');
  console.error('  and prints the canonical SHA256 asset_id.');
  process.exit(1);
}

const resolvedPath = path.resolve(filePath);

if (!fs.existsSync(resolvedPath)) {
  console.error(`Error: File not found: ${resolvedPath}`);
  process.exit(1);
}

let raw;
try {
  const content = fs.readFileSync(resolvedPath, 'utf8');
  raw = JSON.parse(content);
} catch (err) {
  console.error(`Error: Failed to parse JSON — ${err.message}`);
  process.exit(1);
}

if (typeof raw !== 'object' || raw === null || Array.isArray(raw)) {
  console.error('Error: Input must be a JSON object (not an array or primitive).');
  process.exit(1);
}

// Remove asset_id field before hashing
const { asset_id: _removed, ...assetWithoutId } = raw;

// Canonical JSON: sort keys recursively, compact serialization
const canonical = JSON.stringify(sortKeysDeep(assetWithoutId));

const digest = sha256(canonical);
console.log(`sha256:${digest}`);
