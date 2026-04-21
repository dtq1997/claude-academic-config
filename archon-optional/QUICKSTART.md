# Archon 快速启动指南

## 前置条件检查

运行环境检查：
```bash
bash ~/ai/workspace/archon/setup/01-check-env.sh
```

## 配置 API Keys

编辑 `~/ai/data/keys/api-keys.json`，添加：

```json
{
  "anthropic": {
    "api_key": "sk-ant-api03-...",
    "model": "claude-opus-4-6"
  },
  "google_gemini": {
    "api_key": "AIza...",
    "model": "gemini-3.1-pro-preview"
  }
}
```

然后运行：
```bash
bash ~/ai/workspace/archon/setup/05-configure-api-keys.sh
```

## 创建第一个项目

```bash
cd ~/ai/workspace/archon
./tools/archon.sh init my-first-theorem
```

## 手动形式化流程

由于完整的自动化编排需要深度集成 Claude Code API，当前版本采用**半自动化**工作流：

### 阶段 1: 搭建框架

1. 准备非正式证明（Markdown 格式）
2. 启动 Claude Code：
   ```bash
   cd ~/ai/workspace/archon/projects/my-first-theorem
   claude
   ```
3. 加载 Lean 智能体技能：
   ```
   请阅读 ~/ai/workspace/archon/skills/lean-agent.md
   ```
4. 指示智能体：
   ```
   请分析 docs/informal-proof.md，构建模块化的 Lean 文件结构，
   在每个证明义务处放置 sorry 占位符。
   ```

### 阶段 2: 证明

1. 启动新的 Claude Code 会话（规划智能体）：
   ```bash
   cd ~/ai/workspace/archon
   claude
   ```
2. 加载规划智能体技能：
   ```
   请阅读 ~/ai/workspace/archon/skills/plan-agent.md
   ```
3. 让规划智能体分析项目状态：
   ```
   请分析 ~/ai/workspace/archon/projects/my-first-theorem 的状态，
   识别所有待证明义务，并为每个义务生成工作计划。
   ```
4. 规划智能体会调用非正式智能体（Gemini）生成详细证明
5. 在另一个终端启动 Lean 智能体执行具体形式化

### 阶段 3: 验证与完善

1. 编译检查：
   ```bash
   cd ~/ai/workspace/archon/projects/my-first-theorem
   lake build
   ```
2. 启动 Claude Code 并加载 Lean 智能体技能
3. 指示智能体：
   ```
   请运行完善阶段：
   - 提取可重用引理
   - 移除 set_option maxHeartbeats
   - 简化证明项
   - 遵循 Mathlib 风格
   ```

## 使用 Gemini 非正式智能体

在 Claude Code 中调用 Gemini：

```
请使用 mcp__multi-ai__ask 工具，model 设为 gemini-3.1-pro-preview，
为以下定理生成详细的逐步证明：

[定理陈述]
```

## 查看项目状态

```bash
./tools/archon.sh status my-first-theorem
```

## 常见问题

### Q: 如何处理编译错误？
A: Lean 智能体会自动读取诊断信息并修复。如果重复失败，规划智能体会介入。

### Q: 如何处理 Mathlib 缺失的基础设施？
A: 规划智能体会调用非正式智能体提出替代证明路线（策略 C）。

### Q: 如何并行处理多个证明义务？
A: 启动多个 Lean 智能体会话，每个处理一个独立的 sorry。

## 进阶：完全自动化

完全自动化需要：
1. 实现 Claude Code API 集成
2. 开发智能体间通信协议
3. 实现自动会话管理

当前版本提供了所有必要的组件和技能文件，但需要手动协调。

## 示例项目

参考 FirstProof 问题 6 的形式化流程：
- 非正式证明：约 2 页
- 形式化代码：约 500 行 Lean
- 成本：< $2000
- 时间：2-3 天（自动化）

## 获取帮助

- 查看技能文件：`~/ai/workspace/archon/skills/`
- 查看会话日志：`~/ai/workspace/archon/memory/`
- 记录问题：`~/ai/memory/unresolved/archon-blockers.md`
