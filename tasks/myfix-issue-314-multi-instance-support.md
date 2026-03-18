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

- [ ] 理解需求 - brainstorming skill
- [ ] 编写测试 - test-driven-development skill
- [ ] 实现修复 - subagent-driven-development skill
- [ ] 验证通过 - verification-before-completion skill
- [ ] 代码审查 - requesting-code-review skill

## 进度记录

- 2026-03-18: 开始处理，创建 worktree 和 task 文档

## Skill 使用记录

| Skill | 使用时间 | 结果 |
|-------|---------|------|
| superpowers:using-git-worktrees | 2026-03-18 14:29 | 成功创建 worktree |
| superpowers:brainstorming | 待使用 | - |
| superpowers:test-driven-development | 待使用 | - |
| superpowers:subagent-driven-development | 待使用 | - |
| superpowers:verification-before-completion | 待使用 | - |
| superpowers:requesting-code-review | 待使用 | - |