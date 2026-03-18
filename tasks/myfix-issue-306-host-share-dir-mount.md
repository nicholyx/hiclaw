# Fix Issue #306: 指定了HICLAW_HOST_SHARE_DIR，但无效

## Issue 概述

- **Issue 编号**: #306
- **Issue 类型**: bug
- **仓库**: higress-group/hiclaw
- **状态**: In Progress

## 问题描述

在安装时指定了 HICLAW_HOST_SHARE_DIR=/home/luxue/docker-volumes/hiclaw，但 manager 容器的挂载信息中没有挂载这个卷。

用户报告指定了 `HICLAW_HOST_SHARE_DIR` 环境变量，但该目录没有被正确挂载到 manager 容器中。

## 相关链接

- Issue URL: https://github.com/higress-group/hiclaw/issues/306

## 实现计划

- [ ] 理解需求 (brainstorming)
- [ ] 编写测试 (test-driven-development)
- [ ] 实现修复 (subagent-driven-development)
- [ ] 验证通过 (verification-before-completion)
- [ ] 代码审查 (requesting-code-review)

## 进度记录

- 2026-03-18: 开始处理
- 2026-03-18: 创建 worktree 和分支