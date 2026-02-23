"""
Shared Utility Functions

Provides path resolution, YAML loading, and other common utilities.
Designed to run with zero third-party dependencies.
"""

import os
import sys
from pathlib import Path
from typing import Any, Dict, List, Union

def get_project_root() -> Path:
    """
    Dynamically locate the project root directory.
    Strategy:
    1. Check environment variable 'AGENTS_PROJECT_ROOT'
    2. Walk upward looking for a directory containing 'AGENTS.md' (up to 5 levels)
    3. Fallback: assume script is at scripts/utils.py and return parent of parent
    """
    # 1. Environment Variable
    env_root = os.environ.get('AGENTS_PROJECT_ROOT')
    if env_root and os.path.exists(env_root):
        return Path(env_root).resolve()

    # 2. Upward Search
    current = Path(__file__).resolve().parent
    for _ in range(5):
        if (current / "AGENTS.md").exists():
            return current
        if current.parent == current: # Reached filesystem root
            break
        current = current.parent
    
    # 3. Fallback (Relative to this file: scripts/utils.py -> project_root)
    # scripts/utils.py -> scripts/ -> project_root
    return Path(__file__).resolve().parent.parent

class SimpleYamlParser:
    """
    A minimal YAML parser for reading AGENTS_INDEX.yaml without PyYAML dependency.
    Supports only the simple subset of YAML used by this project.
    """
    
    @staticmethod
    def parse(file_path: Union[str, Path]) -> Dict[str, Any]:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            
        result = {}
        stack = [(result, -1)]  # (current_dict_or_list, indentation_level)
        
        # Simplified heuristic parse — only for reading core config.
        # For production, use: pip install pyyaml
        return SimpleYamlParser._heuristic_parse(lines)

    @staticmethod
    def _heuristic_parse(lines: List[str]) -> Dict[str, Any]:
        """
        Heuristic parser targeting the AGENTS_INDEX.yaml structure.
        Extracts 'path' fields from the registry section.
        """
        data = {'registry': {}}
        current_section = None
        
        for line in lines:
            line = line.rstrip()
            if not line or line.strip().startswith('#'):
                continue
                
            indent = len(line) - len(line.lstrip())
            content = line.strip()
            
            # Top level keys
            if indent == 0 and content.endswith(':'):
                key = content[:-1]
                if key == 'registry':
                    pass # We are in registry
                else:
                    current_section = None # Ignore other sections
                    
            # Registry sections (context, languages, etc.)
            elif indent == 2 and content.endswith(':'):
                current_section = content[:-1]
                if current_section not in data['registry']:
                     data['registry'][current_section] = []
            
            # List items or properties
            elif indent >= 4:
                if current_section:
                    # Attempt to extract 'path' value
                    if 'path:' in content:
                        parts = content.split('path:')
                        if len(parts) > 1:
                            path_part = parts[1]
                            
                            # Strip trailing comments
                            if '#' in path_part:
                                path_part = path_part.split('#')[0]
                            
                            # Strip commas and braces (inline dicts)
                            path_part = path_part.split(',')[0].strip().rstrip('}').strip()
                            
                            # Strip quotes
                            path_part = path_part.strip('"\'')
                            
                            if path_part:
                                data['registry'][current_section].append({'path': path_part})
        
        return data

def load_yaml_config(file_path: Union[str, Path]) -> Dict[str, Any]:
    """
    Load a YAML file, preferring PyYAML and falling back to SimpleYamlParser.
    """
    try:
        import yaml
        with open(file_path, 'r', encoding='utf-8') as f:
            return yaml.safe_load(f)
    except ImportError:
        return SimpleYamlParser.parse(file_path)
    except Exception as e:
        print(f"Warning: Error loading YAML {file_path}: {e}")
        return {}
