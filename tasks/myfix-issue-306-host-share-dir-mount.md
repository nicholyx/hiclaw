# Fix Issue #306: 指定了HICLAW_HOST_SHARE_DIR，但无效

## Issue 概述

- **Issue 编号**: #306
- **Issue 类型**: bug
- **仓库**: higress-group/hiclaw
- **状态**: In Progress

## 问题描述

在安装时指定了 HICLAW_HOST_SHARE_DIR=/home/luxue/docker-volumes/hiclaw，但 manager 容器的挂载信息中没有挂载这个卷。

用户报告指定了 `HICLAW_HOST_SHARE_DIR` 环境变量，但该目录没有被正确挂载到 manager 容器中。

**根本原因分析：**
安装脚本 `hiclaw-install.sh` 第 2004-2011 行存在 bug：无论 `HICLAW_HOST_SHARE_DIR` 指向的目录是否存在，都会生成挂载参数 `HOST_SHARE_MOUNT_ARGS`。当目录不存在时，这会导致：
1. Docker 可能创建空目录挂载（非用户预期）
2. 如果 `HICLAW_HOST_SHARE_DIR` 为空，会生成无效的 `-v :/host-share` 参数

## 相关链接

- Issue URL: https://github.com/higress-group/hiclaw/issues/306

## 实现计划

- [x] 理解需求 (brainstorming) - 已完成，分析了代码逻辑
- [x] 编写测试 (test-driven-development) - 已完成，创建了单元测试和集成测试
- [x] 实现修复 - 已完成，修复了 bash 和 PowerShell 脚本
- [x] 验证通过 (verification-before-completion) - 已完成，所有测试通过
- [ ] 代码审查 (requesting-code-review)

## 进度记录

- 2026-03-18: 开始处理
- 2026-03-18: 创建 worktree 和分支
- 2026-03-18: 使用 brainstorming 分析问题根因
- 2026-03-18: 编写 TDD 测试用例
- 2026-03-18: 实现修复（bash 和 PowerShell 脚本）
- 2026-03-18: 验证测试通过

## 修改的文件

1. `install/hiclaw-install.sh` - 修复 HOST_SHARE_MOUNT_ARGS 生成逻辑
2. `install/hiclaw-install.ps1` - 同步修复 PowerShell 版本
3. `tests/test-install-host-share-dir.sh` - 新增单元测试
4. `tests/test-host-share-dir-integration.sh` - 新增集成测试