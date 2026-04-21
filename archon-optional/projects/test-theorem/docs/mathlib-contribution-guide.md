# Mathlib 贡献指南（实操版）

基于 2026-03 调研，三模型交叉验证。

## 审查标准（不只是正确）

1. **通用性** — 能证一般形式就别证特例（如 ∫ x^{s-1}/(a+x) 优于 ∫ x^{s-1}/(1+x)）
2. **API 完整性** — 积分等式必须配套独立的 `Integrable` / `IntegrableOn` 引理
3. **编译性能** — 禁止 `set_option maxHeartbeats`；超时说明证明结构有问题，需拆分
4. **代码精简** — 冗余步骤会被逐行砍
5. **文档** — 所有 public 定理必须有 `/-- ... -/` docstring；文件头需 `/-! ... -/` module docstring + copyright + authors
6. **命名** — 严格 `snake_case`，名字描述结论而非证明方法
7. **行宽** — 100 字符上限（linter 自动检查）
8. **缩进** — 2 空格新块，4 空格续行

## 命名规范（分析/积分）

| 类型 | 命名模式 | 示例 |
|------|---------|------|
| Lebesgue 可积的定积分 | `integral_描述` | `integral_inv_one_add_pow_four` |
| 条件收敛的瑕积分 | `tendsto_integral_描述` | `tendsto_integral_sin_div_x` |
| 可积性引理 | `integrable_描述` / `integrableOn_描述` | `integrable_inv_one_add_pow_four` |
| Ioi 上的积分 | `integral_Ioi_描述` | `integral_Ioi_rpow_div_one_add` |

## 我们的代码需要改什么

| 问题 | 现状 | Mathlib 要求 |
|------|------|-------------|
| `maxHeartbeats 400000` | EulerReflection 用了 | 去掉，拆分证明 |
| `private` 辅助引理 | 大量 private | 改 public + 加 docstring |
| module docstring | 格式不标准 | `/-! ... -/` + copyright + authors |
| 文件组织 | 独立项目 | 放入 Mathlib 层级 `Analysis/SpecialFunctions/Integrals/` |
| PR 大小 | 7 个定理 | **一个定理一个 PR**，每个 ≤ 300 行 |

## 操作流程

1. 在 [Zulip](https://leanprover.zulipchat.com/) `#mathlib4` 频道自我介绍 + 说明要贡献什么
2. Fork `leanprover-community/mathlib4`
3. 在 Mathlib 代码树里写代码（不是独立项目）
4. 通过 linter 检查
5. 一个 PR 一个定理，标题简洁
6. PR 描述写清楚：证明策略、依赖的已有引理、新增 API
7. 等 review，接受改写建议（reviewers 会重写代码，这是正常的）

## 提交顺序建议

按依赖关系和难度排序：

1. **EulerReflection** `integral_Ioi_rpow_div_one_add` — 基础引理，QuarticIntegral 依赖它
2. **QuarticIntegral** `integral_inv_one_add_pow_four` — 短、自洽、Lebesgue 可积，最容易过审
3. **LaplaceTransform** `integral_Ioi_exp_neg_mul_sin/cos` — 独立，应用广泛
4. **GaussianMoments** `integral_Ioi_pow_mul_exp_neg_sq` — 非常短，调用已有引理
5. **DirichletIntegral** `tendsto_integral_sin_div_x` — 最长最复杂，积累经验后再提
6. **FresnelIntegral** — 完成 sorry 后再提

## 关键资源

- [贡献指南](https://leanprover-community.github.io/contribute/index.html)
- [代码风格](https://leanprover-community.github.io/contribute/style.html)
- [命名规范](https://leanprover-community.github.io/contribute/naming.html)
- [PR 审查指南](https://leanprover-community.github.io/contribute/pr-review.html)
- [Zulip 社区](https://leanprover.zulipchat.com/)
- [Mathlib4 仓库](https://github.com/leanprover-community/mathlib4)

## Bochner 积分陷阱

Mathlib 的 `∫` 是 Bochner 积分，要求绝对可积。对于条件收敛的积分（sin(x)/x、Fresnel）：
- `∫ x in Ioi 0, sin x / x` 在 Mathlib 里 **等于 0**（因为不绝对可积）
- 必须表述为极限：`Tendsto (fun R => ∫ x in 0..R, sin x / x) atTop (nhds (π/2))`
- 我们的 DirichletIntegral 和 FresnelIntegral 已经正确使用了 `Tendsto` 形式 ✓
