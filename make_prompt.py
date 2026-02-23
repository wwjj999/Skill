import os
import datetime
# --- Import shared configuration ---
import sys
from pathlib import Path

# Ensure the project root is in sys.path
project_root = Path(__file__).resolve().parent
if str(project_root) not in sys.path:
    sys.path.insert(0, str(project_root))

try:
    from scripts.config import IGNORE_DIRS, EXTENSIONS, PROJECT_ROOT
except ImportError:
    IGNORE_DIRS = {'.git', '__pycache__', 'node_modules', 'context', '.gemini', '.history', '.agents', 'bmad'}
    EXTENSIONS = {'.py', '.md', '.json', '.js', '.vue', '.ps1', '.sh', '.txt'}
    PROJECT_ROOT = Path(__file__).parent
    print("Warning: Could not import scripts.config, using fallback defaults.")

# --- Project size thresholds (for tiered depth strategy) ---
MAX_FILES_FULL_TREE = 100      # Small project: full tree
MAX_FILES_TRUNCATED = 300      # Medium project: truncate to 2 levels
# Over 300 files: show root and first-level subdirs only

def get_tree_structure(startpath):
    """
    Auto-generate the project directory tree.
    Dynamically adjusts depth based on project size to avoid oversized context.
    """
    
    # Single pass: count files and collect directory structure
    file_count = 0
    entries = []  # (level, basename, is_dir, files_in_dir)
    
    startpath_obj = Path(startpath).resolve()

    for root, dirs, files in os.walk(startpath):
        # Filter ignored directories
        dirs[:] = [d for d in dirs if d not in IGNORE_DIRS]
        
        # Compute relative depth
        try:
            rel_path = Path(root).relative_to(startpath_obj)
        except ValueError:
            continue

        level = len(rel_path.parts) if str(rel_path) != '.' else 0
        
        matched_files = [f for f in files if any(f.endswith(ext) for ext in EXTENSIONS)]
        file_count += len(matched_files)
        entries.append((level, os.path.basename(root), matched_files))
    
    # Choose depth strategy based on file count
    if file_count <= MAX_FILES_FULL_TREE:
        depth_limit = None
        strategy = "full tree"
    elif file_count <= MAX_FILES_TRUNCATED:
        depth_limit = 2
        strategy = "2-level depth"
    else:
        depth_limit = 1
        strategy = "1-level depth (large project)"
    
    # Build tree string with depth limit applied
    tree_str = f"Project Structure (📊 {file_count} files, strategy: {strategy}):\n"
    
    for level, basename, matched_files in entries:
        if depth_limit is not None and level > depth_limit:
            continue
        
        indent = ' ' * 4 * level
        tree_str += f"{indent}{basename}/\n"
        
        if depth_limit is None or level < depth_limit:
            subindent = ' ' * 4 * (level + 1)
            for f in matched_files:
                tree_str += f"{subindent}{f}\n"
    
    return tree_str

def read_file(filepath):
    """Read file content. Accepts absolute paths or paths relative to project root."""
    path_obj = Path(filepath)
    if not path_obj.is_absolute():
        path_obj = PROJECT_ROOT / filepath
        
    if path_obj.exists():
        with open(path_obj, 'r', encoding='utf-8') as f:
            return f.read()
    return ""

def generate_prompt(user_query):
    # 1. Gather real-time data
    tree = get_tree_structure(".")
    status = read_file("context/status.md")
    memory = read_file("context/memory.md")
    current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")

    # 2. Build "sandwich" prompt (core fusion point)
    # Order: user query (primacy) -> static memory -> dynamic state -> repeat query (recency)
    final_prompt = f"""
---
[SYSTEM INSTRUCTION]: 
You are an expert developer. Answer the question based strictly on the context below.

[User Query Summary]: 
"{user_query}"

[Layer 1: Long-term Memory (ADR Logs)]:
{memory}

[Layer 2: Current Project State (RAM)]:
<current_time>{current_time}</current_time>
{status}
<file_tree>
{tree}
</file_tree>

[Instruction]: 
Answer the user's question now. 
1. Check the 'Long-term Memory' for constraints (e.g., banned functions).
2. Check the 'file_tree' to understand where files are located.
3. If you write code, ensure it matches the 'status' (Tech Stack).

[User Query]: 
"{user_query}"
---
"""
    return final_prompt

if __name__ == "__main__":
    # Check if interactive mode (no args)
    if len(sys.argv) > 1:
        # One-shot mode
        query = " ".join(sys.argv[1:])
        prompt = generate_prompt(query)
        try:
            import pyperclip
            pyperclip.copy(prompt)
            print("\nPrompt copied to clipboard! (One-shot)")
        except ImportError:
            print(prompt)
    else:
        # Interactive Mode (REPL)
        print("="*60)
        print("DCIP Console: Dynamic Context Injection")
        print("   (type 'q' or 'exit' to quit)")
        print("="*60)
        
        try:
            import pyperclip
            HAS_CLIPBOARD = True
        except ImportError:
            HAS_CLIPBOARD = False
            print("Info: pyperclip not found. Output will be printed to screen.")
            print("   (install with: pip install pyperclip)")

        while True:
            try:
                query = input("\n[DCIP] Enter your question: ").strip()
                if query.lower() in ('q', 'exit', 'quit'):
                    print("Bye!")
                    break
                if not query:
                    continue
                    
                prompt = generate_prompt(query)
                
                if HAS_CLIPBOARD:
                    try:
                        pyperclip.copy(prompt)
                        print("Prompt copied! (paste to AI)")
                    except Exception as e:
                        print(f"Copy failed: {e}")
                        print(prompt)
                else:
                    print("-" * 40)
                    print(prompt)
                    print("-" * 40)
                    print("Please copy the content above manually.")
                    
            except KeyboardInterrupt:
                print("\nBye!")
                break
            except Exception as e:
                print(f"Error: {e}")
