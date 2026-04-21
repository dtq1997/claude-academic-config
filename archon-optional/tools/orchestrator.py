#!/usr/bin/env python3
"""
Archon 编排器 — Plan Agent 驱动版本

核心逻辑完全委托给 Claude Code 的原生 subagent 系统：
- Plan Agent (.claude/agents/plan-agent.md) 作为主线程
- Lean Agent (.claude/agents/lean-agent.md) 作为 subagent
- Gemini 作为非正式智能体 (通过 mcp__multi-ai__ask)
- Lean LSP MCP 提供编译反馈和 LeanSearch

本脚本仅负责：启动、日志、成本汇总。
"""

import sys
import json
import subprocess
from datetime import datetime
from pathlib import Path


def run(proof_path, project_dir, *, budget=100, phase="all"):
    """启动 Archon 形式化"""
    project = Path(project_dir).resolve()
    proof = Path(proof_path).resolve()
    memory_dir = project / "memory"
    memory_dir.mkdir(exist_ok=True)

    session_id = datetime.now().strftime("%Y%m%d_%H%M%S")
    session_log = memory_dir / f"session-{session_id}.md"

    # 构建 prompt
    proof_content = proof.read_text()

    if phase == "all":
        prompt = f"""请执行完整的三阶段形式化工作流。

非正式证明文件: {proof}
内容:
---
{proof_content}
---

按照你的三阶段工作流执行：
1. 搭建框架：使用 lean-agent 构建 Lean 文件结构 + sorry 占位
2. 证明：逐个填充 sorry（失败时按失败类型选择干预策略）
3. 完善：提取引理、优化风格、确认无 sorry

开始吧。"""
    elif phase == "scaffold":
        prompt = f"仅执行阶段 1（搭建框架）。非正式证明:\n{proof_content}"
    elif phase == "prove":
        prompt = f"仅执行阶段 2（证明）。填充所有 sorry。非正式证明:\n{proof_content}"
    elif phase == "polish":
        prompt = "仅执行阶段 3（验证与完善）。"

    # 启动 Plan Agent
    cmd = [
        "claude",
        "--agent", "plan-agent",
        "--dangerously-skip-permissions",
        "--max-budget-usd", str(budget),
        "--print",
        "--output-format", "json",
        prompt,
    ]

    start = datetime.now()
    ts = start.strftime("%H:%M:%S")
    print(f"[{ts}] · Archon 启动 — 项目: {project}")
    print(f"[{ts}] · 非正式证明: {proof}")
    print(f"[{ts}] · 预算上限: ${budget}")
    print(f"[{ts}] · Plan Agent 运行中...")

    with open(session_log, "a") as log:
        log.write(f"[{ts}] Archon 启动\n")
        log.write(f"  项目: {project}\n")
        log.write(f"  证明: {proof}\n")
        log.write(f"  阶段: {phase}\n")
        log.write(f"  预算: ${budget}\n\n")

    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            cwd=str(project),
            timeout=3600,  # 1 小时总超时
        )

        elapsed = (datetime.now() - start).total_seconds()
        ts = datetime.now().strftime("%H:%M:%S")

        # 解析结果
        cost = 0.0
        output_text = ""
        if result.returncode == 0:
            try:
                data = json.loads(result.stdout)
                cost = data.get("total_cost_usd", 0)
                output_text = data.get("result", "")
            except json.JSONDecodeError:
                output_text = result.stdout

        success = result.returncode == 0

        # 日志
        status = "完成" if success else "失败"
        print(f"[{ts}] {'✓' if success else '✗'} 形式化{status} — 耗时 {elapsed:.0f}s, 费用 ${cost:.2f}")

        with open(session_log, "a") as log:
            log.write(f"\n[{ts}] 形式化{status}\n")
            log.write(f"  耗时: {elapsed:.0f}s\n")
            log.write(f"  费用: ${cost:.2f}\n")
            log.write(f"  退出码: {result.returncode}\n")
            if output_text:
                log.write(f"\n--- Plan Agent 输出 ---\n{output_text[:2000]}\n")
            if result.stderr:
                log.write(f"\n--- stderr ---\n{result.stderr[:1000]}\n")

        print(f"[{ts}] · 日志: {session_log}")

        return success

    except subprocess.TimeoutExpired:
        ts = datetime.now().strftime("%H:%M:%S")
        print(f"[{ts}] ✗ 超时（1小时）")
        return False
    except KeyboardInterrupt:
        ts = datetime.now().strftime("%H:%M:%S")
        print(f"\n[{ts}] · 用户中断")
        return False


def main():
    import argparse

    parser = argparse.ArgumentParser(
        description="Archon — 研究级数学形式化系统",
        epilog="示例: python3 orchestrator.py docs/informal-proof.md ."
    )
    parser.add_argument("proof", help="非正式证明文件路径")
    parser.add_argument("project", nargs="?", default=".", help="Lean 项目目录（默认当前目录）")
    parser.add_argument("--phase", choices=["scaffold", "prove", "polish", "all"],
                        default="all", help="仅运行指定阶段")
    parser.add_argument("--budget", type=float, default=100,
                        help="成本上限（美元，默认 100）")

    args = parser.parse_args()
    success = run(args.proof, args.project, budget=args.budget, phase=args.phase)
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
