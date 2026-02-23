"""
README.md Link Verification Script
Verifies all TOC links correctly point to their corresponding section headers.
"""
import re
import sys
import os
from pathlib import Path

# Ensure project modules are importable
project_root = Path(__file__).parent
if str(project_root) not in sys.path:
    sys.path.append(str(project_root))

def extract_toc_links(content):
    """Extract all links from the Table of Contents."""
    # Match links of the form [text](#anchor)
    pattern = r'\[([^\]]+)\]\(#([^\)]+)\)'
    return re.findall(pattern, content)

def extract_headers(content):
    """Extract all section headers and their corresponding anchors."""
    headers = {}
    prefix_map = {}  # Auxiliary index for fast prefix-based fuzzy matching
    lines = content.split('\n')
    
    # Load anchor generation utility from the hidden skill directory
    import importlib.util
    utils_path = project_root / '.agents' / 'skills' / 'shared-utils' / 'markdown_utils.py'
    spec = importlib.util.spec_from_file_location("markdown_utils", utils_path)
    markdown_utils = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(markdown_utils)
    generate_github_anchor = markdown_utils.generate_github_anchor
    
    for line in lines:
        match = re.match(r'^(#{1,6})\s+(.+)$', line.strip())
        if match:
            title = match.group(2).strip()
            anchor = generate_github_anchor(title)
            headers[anchor] = {'title': title, 'line': line}
            
            # Build prefix index (first 10 chars) for O(1) fuzzy lookup
            prefix = anchor[:10]
            if prefix not in prefix_map:
                prefix_map[prefix] = []
            prefix_map[prefix].append(anchor)
    
    return headers, prefix_map

def verify_readme_links(readme_path, output_file=None):
    """Verify all links in the given README file."""
    def output(msg):
        if output_file:
            output_file.write(msg + '\n')
        else:
            print(msg)
    
    with open(readme_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    toc_links = extract_toc_links(content)
    output(f"[TOC] Found {len(toc_links)} TOC link(s)")
    
    headers, prefix_map = extract_headers(content)
    output(f"[HEADERS] Found {len(headers)} section header(s)\n")
    
    invalid_links = []
    valid_links = []
    
    for link_text, anchor in toc_links:
        if anchor in headers:
            valid_links.append((link_text, anchor, headers[anchor]['title']))
        else:
            invalid_links.append((link_text, anchor))
    
    if invalid_links:
        output("[ERROR] Broken links found:\n")
        for text, anchor in invalid_links:
            output(f"  Link:    [{text}](#{anchor})")
            output(f"  Problem: No matching section header found")
            
            # Fast fuzzy search using prefix index (O(1) lookup)
            similar = prefix_map.get(anchor[:10], [])
            if similar:
                output(f"  Suggest: Possible targets -> {similar[:3]}")
            output('')
    else:
        output("[OK] All TOC links are valid!\n")
    
    output(f"Total: {len(valid_links)} valid, {len(invalid_links)} broken")
    
    # Show first 10 valid links as sample
    if valid_links:
        output("\n[SAMPLE] Valid link examples (first 10):")
        for i, (text, anchor, title) in enumerate(valid_links[:10], 1):
            output(f"  {i}. [{text}](#{anchor}) -> {title}")
    
    return len(invalid_links) == 0

if __name__ == "__main__":
    project_root = Path(__file__).parent
    readme_path = project_root / 'README.md'
    output_path = project_root / 'link_verification_report.txt'
    
    if not readme_path.exists():
        print(f"File not found: {readme_path}")
        exit(1)
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write("=" * 60 + '\n')
        f.write(" README.md Link Verification\n")
        f.write("=" * 60 + '\n\n')
        
        success = verify_readme_links(readme_path, f)
        
        f.write('\n')
        f.write("=" * 60 + '\n')
        if success:
            f.write("PASSED: All links are valid.\n")
        else:
            f.write("FAILED: Broken links detected — please fix them.\n")
        f.write("=" * 60 + '\n')
    
    print(f"Report generated: {output_path}")
    
    # Print report content
    with open(output_path, 'r', encoding='utf-8') as f:
        print(f.read())
    
    exit(0 if success else 1)
