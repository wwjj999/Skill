#!/usr/bin/env python3
"""
compute_asset_id.py

Computes the content-addressable asset_id for an EvoMap evolution asset.

Algorithm:
    sha256(canonical_json(asset_without_asset_id_field))

Canonical JSON = all keys sorted alphabetically at every nesting level,
serialized as a compact string (no extra whitespace).

Usage:
    python compute_asset_id.py <asset.json>

Output:
    sha256:<hex_digest>

Example:
    python compute_asset_id.py examples/gene_example.json
    sha256:3a7f2c9d...

Requirements:
    Python 3.6+ (standard library only, no pip install needed)
"""

import sys
import json
import hashlib


def sort_keys_deep(value):
    """
    Recursively sort all dict keys alphabetically (canonical JSON).
    Lists preserve their order; only dict keys are sorted.
    """
    if isinstance(value, list):
        return [sort_keys_deep(item) for item in value]
    if isinstance(value, dict):
        return {k: sort_keys_deep(v) for k, v in sorted(value.items())}
    return value


def compute_asset_id(asset_dict: dict) -> str:
    """
    Compute the canonical SHA256 asset_id for an asset.

    Steps:
      1. Remove 'asset_id' field (if present)
      2. Sort all keys recursively
      3. Serialize to compact JSON string
      4. UTF-8 encode and SHA256 hash
      5. Return 'sha256:' + hex_digest
    """
    # Remove asset_id field
    without_id = {k: v for k, v in asset_dict.items() if k != 'asset_id'}

    # Canonical JSON: sorted keys, compact (no spaces)
    canonical = json.dumps(
        sort_keys_deep(without_id),
        separators=(',', ':'),
        ensure_ascii=False
    )

    # SHA256
    digest = hashlib.sha256(canonical.encode('utf-8')).hexdigest()
    return f'sha256:{digest}'


def main():
    if len(sys.argv) < 2:
        print('Usage: python compute_asset_id.py <asset.json>', file=sys.stderr)
        print('', file=sys.stderr)
        print('  Reads the JSON file, removes the "asset_id" field,', file=sys.stderr)
        print('  and prints the canonical SHA256 asset_id.', file=sys.stderr)
        sys.exit(1)

    file_path = sys.argv[1]

    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            raw = json.load(f)
    except FileNotFoundError:
        print(f'Error: File not found: {file_path}', file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f'Error: Failed to parse JSON — {e}', file=sys.stderr)
        sys.exit(1)

    if not isinstance(raw, dict):
        print('Error: Input must be a JSON object (not an array or primitive).', file=sys.stderr)
        sys.exit(1)

    result = compute_asset_id(raw)
    print(result)


if __name__ == '__main__':
    main()
