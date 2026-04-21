# AI 辅助数学研究工作流

## 方法论来源

基于以下顶级数学家的实际 AI 使用经验提炼（原文存于 `~/ai/workspace/academic/references/workflow/`）：

- **Ernest Ryu**（UCLA）：用 GPT-5 解决 40 年未解问题，AI 作为 brainstorming partner
- **Ivan Nourdin 等**（arxiv 2509.03065）：GPT-5 辅助 Malliavin-Stein 研究的系统实验
- **Terence Tao**（Fields 2006）：The Atlantic 2026.2 访谈，AI 作为 junior co-author
- **Daniel Litt**（Toronto）：博客 "Mathematics in the Library of Babel"，AI 降低探索成本

## 核心原则

1. **AI 是 brainstorming partner + executor，不是 autonomous solver**
   - 人提供方向和判断，AI 执行计算和探索（Tao: "conversation > autonomous"）
   - AI 的价值 = 降低「第一个笨想法」的成本（Litt），不是替代数学直觉

2. **逐步对话，不要 one-shot**
   - 分步喂信息，每步确认后再继续（Ryu 的核心方法）
   - 具体 hint >> 开放式 hint（Nourdin 的关键发现：给 1-2 句精确提示，效果远超「请证明这个」）

3. **新 session 验证**
   - 得到重要结论后，在全新 session 中让 AI 独立验证（Ryu 的杀手锏）
   - 避免 AI 在同一对话中「顺着自己说」的确认偏误

4. **人的数学判断不可替代**
   - AI 输出必须人工审核，尤其是证明的关键步骤（所有四位数学家的共识）
   - AI 擅长从邻近领域拉工具，但不擅长判断哪条路值得走

## 三模型分工

**GPT-5.2（ask_gpt）— Ryu 式 brainstorming partner**
- 数学推导的主力：证明验证、寻找反例、严格逻辑链
- 使用方式：先喂论文背景（可发完整 main.tex），再提精确问题
- 多轮对话积累上下文，同一数学问题在同一 session 内深入
- 换新问题时用 reset_history 清空，避免上下文污染

**Claude（我）— Nourdin 式 orchestrator**
- 维持对话主线，协调 GPT 和 Gemini 的输出
- 直接编辑 main.tex，整合证明片段为论文语言
- 翻译、润色、LaTeX 排版
- 概念解释、直觉讨论、多轮追问

**Gemini（ask_gemini）— 长上下文 + 视觉**
- 手写笔记、图表的视觉理解
- 需要综合大量文献的问题（超长上下文窗口）
- 涉及几何直觉的讨论
- Tao 式「blast through tedious computations」的备选执行者

**同时问两个（ask_both）**
- 关键证明的正确性验证（交叉检验）
- 涉及论文核心结论的判断
- 用户明确说「不确定」或「帮我验证」

## 操作规程

**攻克一个 Step 的标准流程：**

1. **定义问题**：Claude 与用户对话，明确当前 step 的精确数学目标和已知条件
2. **喂背景给 GPT**：将相关章节（或完整论文）+ 精确问题发给 GPT-5.2
3. **迭代探索**：GPT 提出思路 → 用户/Claude 判断方向 → 给更具体的 hint → GPT 细化
4. **关键结论验证**：reset_history → 在新 session 中让 GPT 独立重新推导（Ryu 验证法）
5. **写入论文**：Claude 将验证通过的证明整合进 main.tex，调整为论文风格
6. **Gemini 审读**（可选）：对完成的章节做长上下文一致性检查

**prompt 工程（数学专用）：**
- 给 GPT 的 prompt 结构：`[背景/定义] + [已证明的结果] + [精确问题] + [1-2句hint]`
- 不要问「请证明 X」，要问「用 Y 方法能否证明 X？具体困难在 Z 处」
- 计算类任务给完整符号定义，不要让 AI 猜记号

**AI 出错时的处理：**
- GPT 给出可疑证明时，不要在同一 session 追问「你确定吗」（AI 会倾向于坚持错误）
- 正确做法：reset_history → 换个角度重新提问，或给不同的 hint
- 如果两次独立 session 给出矛盾结论，用 ask_both 交叉检验

**Claude 主动调用 GPT 的边界：**
- 可以主动调：常规计算验证、符号化简、检查已有证明的逻辑完整性
- 必须先问用户：涉及证明策略选择、是否放弃当前路线、引入新工具/新方法

**Gemini 审读触发条件：**
- 完成一整个 section 的书写后
- 解决一个 T2 级别以上的技术困难后
- 用户明确要求全文一致性检查时

**session 管理：**
- 同一数学问题：保持 GPT session，积累上下文
- 换新问题/新 step：reset_history
- 重要结论验证：必须 reset 后在干净 session 重新验证
- Gemini 的 session 独立于 GPT，按需 reset
