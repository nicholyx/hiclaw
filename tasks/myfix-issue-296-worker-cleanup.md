# Fix Issue #296: 删除项目时，worker未被清理

## Issue 概述

- **Issue 编号**: #296
- **Issue 类型**: bug
- **仓库**: higress-group/hiclaw
- **状态**: Completed

## 问题描述

删除项目时，有worker遗留，多次提醒后还是删除失败。

经尝试，在删除命令下达时：
- 小概率未下达关闭命令
- 大概率只是关闭未删除，在下次Heartbeat检查时会重启

这是新建了一个项目团队，运行一段时间后，命令团队任务取消，解散删除worker后的执行情况。

## 相关链接

- Issue URL: https://github.com/higress-group/hiclaw/issues/296

## 实现计划

- [x] 理解需求 - 使用 brainstorming skill ✓
- [x] 编写测试 - 使用 test-driven-development skill ✓ (RED → GREEN)
- [x] 实现修复 - 在 lifecycle-worker.sh 中添加 delete action
- [x] 验证通过 - 使用 verification-before-completion skill ✓ (11/11 测试通过)
- [x] 代码审查 - 使用 requesting-code-review skill ✓ (批准，已修复 Important 问题)

## 进度记录

- 2026-03-18: 开始处理
- 2026-03-18: 创建 worktree 和分支
- 2026-03-18: 完成 brainstorming - 分析问题根源：项目完成时没有清理 worker
- 2026-03-18: 完成 TDD RED 阶段 - 测试正确失败
- 2026-03-18: 完成 TDD GREEN 阶段 - 所有测试通过
- 2026-03-18: 更新 SKILL.md 文档 - project-management 和 worker-management
- 2026-03-18: 代码审查 - 批准，修复 Important 级别问题
- 2026-03-18: 最终验证 - 11/11 测试通过

## 修改的文件

1. `manager/agent/skills/worker-management/scripts/lifecycle-worker.sh`
   - 添加 `action_delete` 函数
   - 添加 worker 存在性检查
   - 为所有错误情况输出 JSON 状态
   - 添加 `delete` action case
   - 更新 usage 信息

2. `manager/agent/skills/project-management/SKILL.md`
   - Step 3g 添加项目完成时清理 worker 的步骤

3. `manager/agent/skills/worker-management/SKILL.md`
   - 添加 "Delete a Worker" 章节

4. `manager/tests/test-lifecycle-worker.sh` (新增)
   - lifecycle-worker.sh 的单元测试 (11 个测试)

## 测试结果

```
Total:  11
Passed: 11
Failed: 0
```
