"""
Centralized Configuration for Project Scripts

Eliminates code duplication (DRY) and unifies path handling logic.
"""

import os
from pathlib import Path

# --- Core Path Logic ---
try:
    from scripts.utils import get_project_root, load_yaml_config
except ImportError:
    # Fallback when config.py is executed directly (not recommended)
    import sys
    sys.path.append(str(Path(__file__).resolve().parent.parent))
    from scripts.utils import get_project_root, load_yaml_config

# Global project root
PROJECT_ROOT = get_project_root()

# --- Unified Constants ---

# Directories to ignore during file tree generation
IGNORE_DIRS = {
    '.git',
    '__pycache__',
    'node_modules',
    'context',       # Auto-generated context files; not source code
    '.gemini',
    '.history',
    '.idea',
    '.vscode',
    'dist',
    'build',
    '.agents',       # Protocol Land: large rule library, excluded to prevent tree truncation
    'bmad'           # Protected territory, same reason
}

# File extensions to include in scans
EXTENSIONS = {
    '.py', '.md', '.json', '.js', '.ts', '.tsx', '.jsx',
    '.vue', '.ps1', '.sh', '.txt', '.yaml', '.yml', '.toml'
}

# --- Dynamic Core File List ---
def _load_core_files() -> set:
    """Load the core file list from AGENTS_INDEX.yaml, merged with baseline defaults."""
    
    # Baseline core files (always included even if YAML is missing)
    defaults = {
        'AGENTS.md', 'GEMINI.md', 'PROJECT_STATUS.md', 'README.md',
        'scripts/', '.agents/', 'context/'
    }
    
    yaml_path = PROJECT_ROOT / 'AGENTS_INDEX.yaml'
    if not yaml_path.exists():
        return defaults
        
    data = load_yaml_config(yaml_path)
    registry = data.get('registry', {})
    
    yaml_files = set()
    
    # Traverse all registry sections (context, languages, etc.)
    for section, items in registry.items():
        if isinstance(items, list):
            for item in items:
                if isinstance(item, dict) and 'path' in item:
                    # Normalize path: use forward slashes, strip leading ./
                    raw_path = item['path'].replace('\\', '/')
                    if raw_path.startswith('./'):
                        raw_path = raw_path[2:]
                    yaml_files.add(raw_path)
                    
    return defaults.union(yaml_files)

CORE_FILES = _load_core_files()
