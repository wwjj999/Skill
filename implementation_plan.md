# README.md 更新实施计划

## 目标

更新 `README.md` 以反映完整的项目结构和持久化文件，同时清理临时分析报告。

## 第一阶段：清理

- **删除**: `AGENTS_ANALYSIS_REPORT.md`
- **删除**: `AGENTS_INDEX_ANALYSIS.md`
- **删除**: `DM_FILES_ANALYSIS.md`

## 第二阶段：README 结构更新

- **拟收录的目标文件**:
  - `PRINCIPLES.DM` (核心原则 / Core Principles)
  - `TOKEN_AUDIT.DM` (Token 审计 / Token Audit)
  - `CALL_CHAIN_ANALYSIS.md` (上下文架构 / Context Architecture)
  - `AI_RULES_INJECTION.txt` (上帝模式注入 / God Mode Injection)
  - `ResetAG.bat` / `ResetAG.sh` (系统维护 / System Maintenance)
  - `.agents/` 目录内容 (协议文件 / Protocols)

## 第三阶段：内容起草 (双语)

- **风格**: 保持标准的 `| Category分类 | File文件 | Description描述 |` 表格格式。
- **描述要求**: 简洁、双语对照、与现有条目风格一致。

## 第四阶段：执行

- **步骤 1**: 使用 `tree` 风格更新“目录树 (Directory Tree)”部分。
- **步骤 2**: 更新“文件分类 (File Categories)”表。
  - 插入新行。
  - 验证列对齐。
- **步骤 3**: 验证目录 (TOC) 和内部链接。

## 验证

- **检查**: 渲染后的 Markdown 视图。
- **检查**: 确保无临时文件列出。
- **检查**: 双语一致性。
