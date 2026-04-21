---
name: mathematica-nb
description: Mathematica 笔记本 (.wl/.nb) 的编程式编辑、生成、排版。用 wolframscript 做迭代测试,用 TextData+InlineFormula 实现正文嵌公式。适用:用户要写/改 .wl 或 .nb 文件、批量生成 notebook、或在 notebook 里做复杂排版。
---

# Mathematica Notebook 编辑 Skill

核心知识库位于 `~/.claude-academic-config/shared/mathematica-nb-guide.md`。加载本 skill 时同时读取该 guide。

## 触发场景

- 用户要编辑/生成 `.wl` 或 `.nb` 文件
- 用户问"怎么在 Mathematica 里排版数学公式"/"正文怎么嵌公式"
- 用户有批量生成 notebook 的需求

## 核心原则

1. **不要让用户当人肉编译器**:有 `wolframscript` 就直接调用,拿到输出/报错再改代码
2. **.wl 是 notebook 的文本表示**:用 `Import[file, "NB"]` → 修改 Notebook 表达式 → `Export[file, newNb, "NB"]`
3. **正文嵌公式只有一种正确方式**:`Cell[TextData[{..., Cell[BoxData[...], "InlineFormula"], ...}], "Text"]`
4. **不要对 `.wl` source 做 Import→Export roundtrip**:ExpressionUUID 会丢失,cell 会错乱

## 快速工具链

```bash
# 执行代码
wolframscript -code 'expr' 

# 运行脚本文件
wolframscript -file gen-nb.wl

# 生成 InlineFormula box
wolframscript -code 'ToString[ToBoxes[TraditionalForm[expr]], InputForm]'
```

详细的 Box 构件表、常见踩坑、Code→Output 预渲染代码见 guide 文件。
