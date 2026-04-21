# Mathematica .wl ↔ .nb 转换与排版方法论

> [Claude] 2026-03-09 创建。来源：pvi-survey/schwarz-demo 项目排版迭代经验。

## 核心认知

- `.wl` 文件 IS notebook 的文本表示（`Notebook[{Cell[...], ...}]`）
- `.nb` 是同一格式但带 FrontEnd cache（打开后生成）
- 两者可直接 `Import[file, "NB"]` 解析为 `Notebook` 表达式再 `Export[file, nb, "NB"]`
- **wolframscript 足以完成全部转换，不需要打开 GUI**

## 方法一：Import → 编程修改 → Export（推荐）

```mathematica
nb = Import["file.wl", "NB"];          (* 解析为 Notebook 表达式 *)
(* ... 用 Cases/ReplaceAll 等修改 cell 结构 ... *)
Export["file.nb", newNb, "NB"];        (* 导出为 .nb *)
```

### 关键操作

| 操作 | 代码 |
|------|------|
| 找到所有 Text cells | `Cases[nb, Cell[_, "Text", ___], Infinity]` |
| 找到所有 Code cells | `Cases[nb, Cell[BoxData[_], "Code", ___], Infinity]` |
| 表达式→Box | `ToBoxes[expr, StandardForm]` |
| Box→表达式 | `ToExpression[boxes, StandardForm]` |
| 隐藏 cell | 添加 `CellOpen -> False` 选项 |
| 删除特定类型 cell | `Select[cells, !MatchQ[#, pattern] &]` |

### 预渲染 Output cells

对于 Code cell 中的显示表达式（Grid/Column/TraditionalForm/Framed），可预渲染为 Output cell：

```mathematica
(* 1. 提取 BoxData *)
Cell[BoxData[boxes_], "Code", ___]
(* 2. 转为表达式再转为渲染后的 box *)
expr = ToExpression[boxes, StandardForm];
outBoxes = ToBoxes[expr, StandardForm];
(* 3. 创建 Output cell *)
Cell[BoxData[outBoxes], "Output", GeneratedCell -> True, CellAutoOverwrite -> True]
```

**适用场景**：需要快速从 .wl 批量生成 .nb 时，如 gen-nb.wl 脚本。
**局限**：Output cell 和 Text cell 之间有横线分隔，视觉上不融合。

## 方法二：TextData + InlineFormula（最佳排版）

在 .nb 中实现"正文中嵌入公式"的唯一正确方式：

```mathematica
Cell[TextData[{
  "Gauss 超几何方程：",
  Cell[BoxData[FormBox[
    RowBox[{"z", "(", RowBox[{"1", "-", "z"}], ")", " ",
      SuperscriptBox["y", "\[Prime]\[Prime]"],
      "+", " ", ...}],
    TraditionalForm]], "InlineFormula"],
  "。它有三个参数 ",
  Cell[BoxData[FormBox[
    RowBox[{"(", "a", ",", "b", ",", "c", ")"}],
    TraditionalForm]], "InlineFormula"],
  "。"
}], "Text"]
```

### 常用 Box 构件

| 数学 | Box 表示 |
|------|---------|
| 上标 x² | `SuperscriptBox["x", "2"]` |
| 下标 y₁ | `SubscriptBox["y", "1"]` |
| 分数 a/b | `FractionBox["a", "b"]` |
| 根号 √x | `SqrtBox["x"]` |
| 行组合 | `RowBox[{"a", "+", "b"}]` |
| ₂F₁ | `TemplateBox[{"2", "1"}, "Hypergeometric2F1"]` 或手动 `RowBox[{SubscriptBox["", "2"], SubscriptBox["F", "1"]}]` |
| 希腊字母 | `"\[Lambda]"`, `"\[Mu]"` 等（Text cell 中直接写即可渲染） |
| TraditionalForm 包装 | `FormBox[boxes, TraditionalForm]` |

### 自动生成 InlineFormula Box

不必手写 Box——用 wolframscript 的 `ToBoxes` 自动生成：

```mathematica
(* 获取 ₂F₁(a,b;c;z) 的 box 形式 *)
boxes = ToBoxes[TraditionalForm[HoldForm[Hypergeometric2F1[a, b, c, z]]]];
(* boxes 可直接嵌入 InlineFormula cell *)
```

**工作流**：
1. 在 wolframscript 中写出数学表达式
2. `ToString[ToBoxes[expr], InputForm]` 得到 box 文本
3. 将 box 文本粘贴到 TextData 的 InlineFormula 位置

## 方法三：UsingFrontEnd（有限场景）

```mathematica
UsingFrontEnd[
  nb = NotebookOpen["file.wl", Visible -> False];
  FrontEndTokenExecute[nb, "SaveRename", {"file.nb", "Notebook"}];
  NotebookClose[nb];
]
```

**限制**：
- `NotebookEvaluate` 产生的 Output 是 `OutputFormData`（纯文本），不是 `BoxData`（格式化）
- 需要 Mathematica 安装在本机
- 无法产生真正的格式化输出（没有完整 FrontEnd 渲染管线）

## 踩坑记录

1. **`\x{2013}` 不是合法 Mathematica 字符串转义** → 用 `\:2013` 或 `\[Dash]`
2. **`Import[file, "NB"]` 返回的 Notebook 只有 1 个顶层 CellGroupData** → 用 `Cases[..., Infinity]` 搜索
3. **wolframscript 的 `UsingFrontEnd` + `NotebookEvaluate`** → Output 只有 OutputFormData 纯文本，不是 BoxData
4. **Export 的 Notebook 表达式如果有未求值部分** → 会把整个表达式写成一个巨大的 BoxData cell
5. **Text cell 中的 `\[Lambda]` 等命名字符** → 在 Mathematica FrontEnd 中自动渲染为希腊字母，无需转为 InlineFormula
6. **Code→Output 方式有横线分隔** → 视觉碎片化，最终排版应改用 TextData + InlineFormula
7. **`Export[file, nb, "NB"]` 会把 ExpressionUUID 移到 cell index** → `Import` 不恢复。解决方案：gen-nb.wl v4 从 cell index 用正则提取 UUID 列表，按深度优先顺序注入回 Cell options。**绝不要对 .wl source 做 Import→Export roundtrip**
8. **`CellOpen -> False` 完全隐藏 cell** → 没有 GUI 展开按钮，无法用于代码折叠

## 工具链

- **gen-nb.wl 脚本模板**：见 `pvi-survey/gen-nb.wl`（Import → 遍历 cells → ToBoxes 预渲染 → Export）
- **调用方式**：`wolframscript -file gen-nb.wl`
- **可重复运行**：修改 .wl 后重跑即可重新生成 .nb
