# Fix Issue #345: 升级后产生悬空镜像，建议删除容器时同步删除镜像

## Issue 概述

- **Issue 编号**: #345
- **Issue 类型**: enhancement
- **仓库**: higress-group/hiclaw
- **状态**: In Progress

## 问题描述

每次升级 HiClaw 时都会产生悬空镜像（dangling images），占用磁盘空间。

建议在删除容器的同时，同步删除相关镜像，避免空间浪费。

## 相关链接

- Issue URL: https://github.com/higress-group/hiclaw/issues/345

## 实现计划

- [ ] 理解需求 - brainstorming
- [ ] 编写测试 - test-driven-development
- [ ] 实现修复 - subagent-driven-development
- [ ] 验证通过 - verification-before-completion
- [ ] 代码审查 - requesting-code-review

## 进度记录

- 2026-03-18: 开始处理