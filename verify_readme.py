"""
README.md Full Validation Script
Checks document structure, formatting, and link integrity.
"""
import re
import sys
from pathlib import Path

# Add shared-utils to module path
sys.path.insert(0, str(Path(__file__).parent / '.agents' / 'skills' / 'shared-utils'))
from markdown_utils import generate_github_anchor

def main():
    readme_path = Path(__file__).parent / 'README.md'
    content = readme_path.read_text(encoding='utf-8')
    lines = content.split('\n')
    
    print('=' * 80)
    print('README.md Validation Report')
    print('=' * 80)
    print()
    
    # 1. Basic info
    print('1. Document Info')
    print(f'   Total lines: {len(lines)}')
    print(f'   File size: {len(content):,} characters')
    print()
    
    # 2. Emoji check in headers
    print('2. Section Header Emoji Check')
    emoji_pattern = re.compile(r'[⭐🔧📁🧠🔴🟢🧪🤖📄🐙🧩📚🔒🎤🛡️📐🌍️]')
    headers_with_emoji = []
    for i, line in enumerate(lines, 1):
        if re.match(r'^#{1,6}\s+', line) and emoji_pattern.search(line):
            headers_with_emoji.append((i, line.strip()))
    
    if headers_with_emoji:
        print(f'   FAIL: {len(headers_with_emoji)} header(s) contain emoji:')
        for line_num, header in headers_with_emoji[:5]:
            print(f'      Line {line_num}: {header}')
    else:
        print('   OK: All section headers are emoji-free')
    print()
    
    # 3. Directory tree count (semantic detection via box-drawing characters)
    print('3. Directory Tree Check')
    # Detect trees by box-drawing characters (\u251c = ├, \u2514 = └) — decoupled from project name
    tree_blocks = re.findall(r'```[^\n]*\n(?:.*\n)*?.*(?:\u251c\u2500\u2500|\u2514\u2500\u2500).*(?:\n.*)*?```', content)
    if not tree_blocks:
        # Fallback: consecutive lines (2+) containing tree characters
        tree_blocks = re.findall(r'(?:^|\n)((?:[^\n]*(?:\u251c\u2500\u2500|\u2514\u2500\u2500)[^\n]*\n?){2,})', content)
    tree_count = len(tree_blocks)
    print(f'   Found {tree_count} directory tree block(s) (detected via \u251c\u2500\u2500/\u2514\u2500\u2500 characters)')
    if tree_count == 2:
        print('   OK: Correct (1 English + 1 Chinese)')
    elif tree_count == 0:
        print('   FAIL: No directory tree detected — check README format')
    else:
        print(f'   WARN: Unexpected tree count: {tree_count} (expected 2)')
    print()
    
    # 4. File Categories section
    print('4. "File Categories" Section Check')
    file_cat_en = len(re.findall(r'^### File Categories', content, re.MULTILINE))
    file_cat_cn = len(re.findall(r'^### 文件分类', content, re.MULTILINE))
    print(f'   English "File Categories": {file_cat_en}')
    print(f'   Chinese "文件分类": {file_cat_cn}')
    if file_cat_en == 1 and file_cat_cn == 1:
        print('   OK: One per language version')
    else:
        print('   FAIL: Count mismatch')
    print()
    
    # 5. Duplicate header check
    print('5. Duplicate Section Check')
    headers = re.findall(r'^#{1,6}\s+(.+)$', content, re.MULTILINE)
    header_counts = {}
    for h in headers:
        clean_h = h.strip()
        header_counts[clean_h] = header_counts.get(clean_h, 0) + 1
    
    duplicates = {h: c for h, c in header_counts.items() if c > 1}
    if duplicates:
        print(f'   WARN: {len(duplicates)} duplicate header(s) found:')
        for h, c in list(duplicates.items())[:3]:
            print(f'      "{h}" appears {c} times')
    else:
        print('   OK: No duplicate section headers')
    print()
    
    # 6. TOC link integrity
    print('6. TOC Link Integrity Check')
    toc_section = re.search(r'## Table of Contents / 目录(.+?)(?=^##|\Z)', content, re.DOTALL | re.MULTILINE)
    if toc_section:
        toc_links = re.findall(r'\[(.+?)\]\(#(.+?)\)', toc_section.group(1))
        print(f'   TOC links found: {len(toc_links)}')
        
        # Extract all actual headers and generate anchors
        actual_anchors = set()
        for match in re.finditer(r'^(#{1,6})\s+(.+)$', content, re.MULTILINE):
            title = match.group(2).strip()
            anchor = generate_github_anchor(title)
            actual_anchors.add(anchor)
        
        # Check for broken links
        broken_links = []
        for text, anchor in toc_links:
            if anchor not in actual_anchors:
                broken_links.append((text, anchor))
        
        if broken_links:
            print(f'   WARN: {len(broken_links)} broken link(s):')
            for text, anchor in broken_links[:5]:
                print(f'      [{text}](#{anchor})')
        else:
            print('   OK: All TOC links are valid')
    print()
    
    # 7. Structural symmetry between EN and CN sections
    print('7. EN/CN Structural Symmetry')
    cn_section_start = None
    for m in re.finditer(r'^(#{1,2})\s+(.+)$', content, re.MULTILINE):
        title = m.group(2)
        cn_chars = len(re.findall(r'[\u4e00-\u9fff]', title))
        if cn_chars >= 2 and m.group(1) == '#':
            cn_section_start = m.start()
            break
    
    if cn_section_start:
        en_part = content[:cn_section_start]
        cn_part = content[cn_section_start:]
        en_h2 = len(re.findall(r'^## [^#]', en_part, re.MULTILINE))
        cn_h2 = len(re.findall(r'^## [^#]', cn_part, re.MULTILINE))
    else:
        en_h2 = len(re.findall(r'^## [^#]', content[:len(content)//2], re.MULTILINE))
        cn_h2 = len(re.findall(r'^## [^#]', content[len(content)//2:], re.MULTILINE))
    print(f'   English main sections: {en_h2}')
    print(f'   Chinese main sections: {cn_h2}')
    if abs(en_h2 - cn_h2) <= 2:
        print('   OK: Structure is roughly symmetric')
    else:
        print('   WARN: Structure may be asymmetric')
    print()
    
    print('=' * 80)
    print('Validation complete.')
    print('=' * 80)

if __name__ == '__main__':
    main()
