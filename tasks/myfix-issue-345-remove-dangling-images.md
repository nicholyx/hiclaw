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

- [x] 理解需求 - brainstorming (已完成)
- [x] 编写测试 - test-driven-development (已完成)
- [x] 实现修复 - subagent-driven-development (已完成)
- [x] 验证通过 - verification-before-completion (已完成)
- [x] 代码审查 - requesting-code-review (已完成，修复了 Important 问题)

## 进度记录

- 2026-03-18: 开始处理
- 2026-03-18: 使用 brainstorming skill 分析问题
  - 问题：升级时拉取新镜像后，旧镜像变成悬空镜像
  - 解决方案：在容器删除后运行 `docker image prune -f`
- 2026-03-18: 使用 test-driven-development skill 编写测试
  - 创建 tests/test-15-dangling-image-cleanup.sh
  - 测试验证：prune 命令存在、位置正确、使用 -f 标志、仅在升级时执行
- 2026-03-18: 使用 verification-before-completion skill 验证
  - 测试全部通过 (6/6)
- 2026-03-18: 使用 requesting-code-review skill 进行代码审查
  - 发现 Important 问题：清理逻辑应在升级条件内执行
  - 已修复：添加 HICLAW_UPGRADE 条件判断
  - 审查通过