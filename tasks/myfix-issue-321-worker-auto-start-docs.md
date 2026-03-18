# Fix Issue #321: Worker 远程模式自动启动文档改进

## Issue 概述

- **Issue 编号**: #321
- **Issue 类型**: enhancement (文档改进)
- **仓库**: higress-group/hiclaw
- **状态**: ✅ Completed

## 问题描述

用户询问：worker 的远程模式只能通过命令行方式手动启动吗？如何让它像本地模式一样类似容器自行启动。

当前文档 (worker-guide.md) 提供了两种 Worker 安装方法：
1. **Direct Creation**: Manager 直接创建容器（本地开发推荐）
2. **Docker Run Command**: Manager 提供 docker run 命令（远程部署）

但是，Method 2 的文档没有说明如何让 Worker 容器自动启动（如使用 `--restart` 参数或 systemd service）。

## 相关链接

- Issue URL: https://github.com/higress-group/hiclaw/issues/321

## 实现计划

- [x] 理解需求 - 用户想知道如何让远程 Worker 自动启动
- [x] 编写改进 - 在 worker-guide.md 中添加自动启动说明
- [x] 验证 - 确保文档格式正确，信息完整
- [x] 代码审查 - ✅ 通过
- [x] 提交代码

## 使用的 Skills

| 步骤 | Skill | 结果 |
|------|-------|------|
| 步骤 4 | superpowers:using-git-worktrees | ✅ 成功创建 worktree |
| 步骤 6 | superpowers:brainstorming | ✅ 快速完成需求理解 |
| 步骤 10 | superpowers:requesting-code-review | ✅ 审查通过，修复后再次通过 |

## 解决方案

在 `docs/worker-guide.md` 中进行了以下改进：

### 1. 在 Method 2 的 docker run 命令中添加 `--restart=unless-stopped` 参数

```bash
docker run -d --name hiclaw-worker-alice \
  --restart=unless-stopped \
  -e HICLAW_WORKER_NAME=alice \
  ...
```

### 2. 添加了提示框说明 restart 参数的作用

> **Tip**: The `--restart=unless-stopped` flag ensures the Worker container automatically restarts when:
> - The Docker daemon restarts (e.g., after system reboot)
> - The container crashes unexpectedly

### 3. 添加了 "Auto-restart Options for Remote Workers" 章节

包含三种自动启动方式：

#### Option 1: Docker Restart Policy (Recommended)
- 提供了 restart policy 选项表格
- 说明了 `unless-stopped`、`always`、`on-failure` 的区别

#### Option 2: Apply Restart Policy to Existing Container
- 使用 `docker update --restart=unless-stopped` 命令
- 添加了说明：对运行和停止的容器都有效

#### Option 3: Systemd Service (Linux)
- 提供了完整的 systemd service 配置示例
- 说明了与 docker restart policy 的冲突避免

## 修改的文件

- `docs/worker-guide.md` - 添加了自动启动说明

## Git 提交记录

```
a572ad7 docs(worker): improve auto-restart section structure
4b914e6 docs(worker): add auto-restart options for remote workers
817179c docs: add task for issue #321 - worker auto-start docs
```

## 进度记录

- 2026-03-18 18:05: 开始处理，创建 task 文档
- 2026-03-18 18:10: 完成文档修改
- 2026-03-18 18:15: 第一次代码审查，发现 3 个 Important 问题
- 2026-03-18 18:20: 修复问题并重新提交
- 2026-03-18 18:22: 第二次代码审查通过
- 2026-03-18 18:25: 任务完成
