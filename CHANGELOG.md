# CHANGELOG

## 2026-02-09 - 治理模式选择机制实施

### feat: 实现交互式治理模式选择功能

**背景**: README 承诺首次运行时会提示用户选择治理模式,但 setup 脚本未实现此功能

**实施内容**:

1. **增强 setup.bat (Windows)**
   - 添加 PROJECT_STATUS.md 存在性检查
   - 实现交互式治理模式选择 (Frozen/Hybrid/Aggressive)
   - 默认推荐 Hybrid 模式
   - 自动创建 PROJECT_STATUS.md 文件并记录 ADR

2. **增强 setup.sh (Linux/macOS)**
   - 添加 PROJECT_STATUS.md 存在性检查
   - 实现交互式治理模式选择 (Frozen/Hybrid/Aggressive)
   - 默认推荐 Hybrid 模式
   - 自动创建 PROJECT_STATUS.md 文件并记录 ADR

3. **改进 ResetAG.bat (Windows)**
   - 修改完成提示信息,引导用户运行 setup.bat
   - 删除旧的"复制粘贴给 AI"提示
   - 提供手动编辑 PROJECT_STATUS.md 的选项

4. **改进 ResetAG.sh (Linux/macOS)**
   - 修改完成提示信息,引导用户运行 setup.sh
   - 删除旧的"复制粘贴给 AI"提示
   - 提供手动编辑 PROJECT_STATUS.md 的选项

5. **更新 PROJECT_STATUS.md**
   - 初始化为 Hybrid 模式
   - 添加 ADR-001: 初始化治理模式
   - 添加 ADR-002: 实现治理模式选择机制

**影响**:

- ✅ 用户首次运行 setup 脚本时会被提示选择治理模式
- ✅ ResetAG 后会引导用户重新运行 setup
- ✅ 文档与实现保持一致
- ✅ 用户体验更加流畅

**相关文件**:

- `setup.bat` - 添加 84 行代码
- `setup.sh` - 添加 93 行代码
- `ResetAG.bat` - 修改提示信息
- `ResetAG.sh` - 修改提示信息
- `PROJECT_STATUS.md` - 初始化并记录 ADR

---

## Project Initialized

- chore: Project initialized for distribution.
