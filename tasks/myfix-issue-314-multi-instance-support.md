# Fix Issue #314: Add Support for Multiple Isolated Instances (Custom Manager Name / Workspace)

## Issue 概述

- **Issue 编号**: #314
- **Issue 类型**: feature/enhancement
- **仓库**: higress-group/hiclaw
- **状态**: In Progress

## 问题描述

Feature request: allow running multiple HiClaw instances on the same host.

The install script currently hardcodes the manager container name (`hiclaw-manager`) and default workspace, which causes conflicts when installing a second instance, even with different ports.

It would help to support either:
- an install wizard prompt (instance name), or
- environment variables (e.g. HICLAW_MANAGER_NAME, HICLAW_WORKSPACE_DIR)

These should be used to control container name, workspace path, and related resources.

This would enable clean multi-instance setups without manual renaming or custom docker-compose.

## 相关链接

- Issue URL: https://github.com/higress-group/hiclaw/issues/314

## 实现计划

- [x] 理解需求 - brainstorming skill
- [x] 编写测试 - test-driven-development skill (RED 阶段完成，3个测试失败)
- [x] 实现修复 - subagent-driven-development skill (GREEN 阶段完成)
- [x] 验证通过 - verification-before-completion skill
- [x] 代码审查 - requesting-code-review skill (已修复审查发现的问题)

## 进度记录

- 2026-03-18 14:29: 开始处理，创建 worktree 和 task 文档
- 2026-03-18 14:32: 完成 brainstorming，创建设计文档
- 2026-03-18 14:38: 完成 TDD RED 阶段，创建测试 tests/test-multi-instance.sh，3个实现测试失败（预期）
- 2026-03-18 14:50: 完成 TDD GREEN 阶段（Shell 脚本），14/14 测试通过
- 2026-03-18 14:55: 完成验证，14/14 测试通过，脚本语法正确
- 2026-03-18 15:00: 代码审查发现问题：PowerShell 脚本未更新
- 2026-03-18 15:15: 修复 PowerShell 脚本，所有 16 个测试通过

## Skill 使用记录

| Skill | 使用时间 | 结果 |
|-------|---------|------|
| superpowers:using-git-worktrees | 2026-03-18 14:29 | 成功创建 worktree |
| superpowers:brainstorming | 2026-03-18 14:32 | 完成。分析了安装脚本结构，确定需要添加 HICLAW_MANAGER_NAME 环境变量，创建了设计文档 docs/superpowers/specs/2026-03-18-multi-instance-support-design.md |
| superpowers:test-driven-development | 2026-03-18 14:38 | RED 阶段完成。创建测试验证：1) 安装脚本硬编码问题，2) 导入脚本硬编码问题，3) docker run 命令硬编码。测试失败符合预期。 |
| superpowers:subagent-driven-development | 2026-03-18 14:50 | GREEN 阶段完成。修改了 install/hiclaw-install.sh 和 install/hiclaw-import.sh。 |
| superpowers:verification-before-completion | 2026-03-18 14:55 | 验证通过。证据：测试通过，脚本语法正确 |
| superpowers:requesting-code-review | 2026-03-18 15:00 | 发现关键问题：PowerShell 脚本未更新。已修复，新增 PowerShell 测试，16/16 测试通过 |