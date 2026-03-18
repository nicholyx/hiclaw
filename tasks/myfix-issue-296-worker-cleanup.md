# Fix Issue #296: 删除项目时，worker未被清理

## Issue 概述

- **Issue 编号**: #296
- **Issue 类型**: bug
- **仓库**: higress-group/hiclaw
- **状态**: In Progress

## 问题描述

删除项目时，有worker遗留，多次提醒后还是删除失败。

经尝试，在删除命令下达时：
- 小概率未下达关闭命令
- 大概率只是关闭未删除，在下次Heartbeat检查时会重启

这是新建了一个项目团队，运行一段时间后，命令团队任务取消，解散删除worker后的执行情况。

## 相关链接

- Issue URL: https://github.com/higress-group/hiclaw/issues/296

## 实现计划

- [ ] 理解需求 - 使用 brainstorming skill
- [ ] 编写测试 - 使用 test-driven-development skill
- [ ] 实现修复 - 使用 subagent-driven-development skill
- [ ] 验证通过 - 使用 verification-before-completion skill
- [ ] 代码审查 - 使用 requesting-code-review skill

## 进度记录

- 2026-03-18: 开始处理
- 2026-03-18: 创建 worktree 和分支
