# Fix Issue #321: Worker 远程模式自动启动文档改进

## Issue 概述

- **Issue 编号**: #321
- **Issue 类型**: enhancement (文档改进)
- **仓库**: higress-group/hiclaw
- **状态**: In Progress

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
- [ ] 编写改进 - 在 worker-guide.md 中添加自动启动说明
- [ ] 验证 - 确保文档格式正确，信息完整
- [ ] 代码审查
- [ ] 提交代码

## 解决方案

在 `docs/worker-guide.md` 中添加以下内容：

### 1. 在 Method 2 的 docker run 命令中添加 `--restart` 参数说明

```bash
docker run -d --name hiclaw-worker-alice \
  --restart=unless-stopped \
  -e HICLAW_WORKER_NAME=alice \
  ...
```

### 2. 添加一个新的章节 "Auto-start for Remote Workers"

说明几种自动启动方式：
- Docker restart policy (`--restart=always` 或 `--restart=unless-stopped`)
- systemd service (适用于 Linux)
- Docker Compose (可选)

## 进度记录

- 2026-03-18: 开始处理，创建 task 文档
