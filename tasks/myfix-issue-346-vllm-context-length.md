# Fix Issue #346: 本地vllm启动的模型，长度超限

## Issue 概述

- **Issue 编号**: #346
- **Issue 类型**: bug
- **仓库**: higress-group/hiclaw
- **状态**: Completed

## 问题描述

用户配置了 32K 长度的本地 vllm 模型，通过 OpenAI 兼容接口配置。但用户只问了一句"你好"，就收到错误：

```
400 You passed 74655 input characters and requested 32000 output tokens. However, the model's context length is only 32000 tokens, resulting in a maximum input length of 0 tokens (at most 0 characters). Please reduce the length of the input prompt. (parameter=input_text, value=74655)
```

问题根本原因：系统默认使用 `maxTokens=128000`，对于 32K 上下文的模型，请求 128K 输出 tokens 远超模型限制，导致错误。

## 相关链接

- Issue URL: https://github.com/higress-group/hiclaw/issues/346

## 实现计划

- [x] 理解需求 - 使用 brainstorming skill ✅
- [x] 编写测试 - 使用 test-driven-development skill ✅
- [x] 实现修复 - 手动实现 ✅
- [x] 验证通过 - 使用 verification-before-completion skill ✅
- [x] 代码审查 - 使用 requesting-code-review skill ✅

## 进度记录

- 2026-03-18: 开始处理，创建 worktree 和分支
- 2026-03-18: 完成需求分析，确定根本原因
- 2026-03-18: 完成测试编写（TDD）
- 2026-03-18: 完成代码实现
- 2026-03-18: 测试全部通过（60/60）
- 2026-03-18: 代码审查通过 (APPROVED)

## 修改摘要

### 修改的文件

| 文件 | 变更 |
|-----|------|
| install/hiclaw-install.sh | +41 行，添加 contextWindow/maxTokens 询问 |
| install/hiclaw-install.ps1 | +36 行，PowerShell 同步修改 |
| manager/scripts/init/start-manager-agent.sh | +72 行，支持自定义模型配置 |
| manager/tests/test-install-context-window-params.sh | 新增测试文件 |
| manager/tests/test-custom-model-context-window.sh | 新增测试文件 |

### 测试结果

| 测试文件 | 结果 |
|---------|------|
| test-install-context-window-params.sh | 6/6 PASSED |
| test-custom-model-context-window.sh | 14/14 PASSED |
| test-update-builtin-section.sh | 40/40 PASSED |

**总计：60 个测试全部通过**

### 解决方案

为自定义模型（如 vLLM）添加了 `HICLAW_MODEL_CONTEXT_WINDOW` 和 `HICLAW_MODEL_MAX_TOKENS` 环境变量支持：

1. 安装脚本在用户选择 `openai-compat` 提供商时，询问上下文窗口和最大输出 tokens
2. 这些值通过 `.env` 文件传递到容器
3. `start-manager-agent.sh` 读取环境变量，为自定义模型配置正确的参数
4. 用户现在可以为 32K vLLM 模型设置正确的限制，避免 "length exceeding limit" 错误

### 使用方式

用户安装时选择 `openai-compat` 提供商：

```bash
# 交互式安装
./hiclaw-install.sh

# 选择: 2) 自定义 OpenAI 兼容服务
# 输入 Base URL: http://your-vllm-server:8000/v1
# 输入 Model ID: your-model-name
# 输入 Context Window: 32000
# 输入 Max Output Tokens: 4096
```

或非交互式：

```bash
HICLAW_NON_INTERACTIVE=1 \
HICLAW_LLM_PROVIDER=openai-compat \
HICLAW_OPENAI_BASE_URL=http://your-vllm-server:8000/v1 \
HICLAW_DEFAULT_MODEL=your-model-name \
HICLAW_MODEL_CONTEXT_WINDOW=32000 \
HICLAW_MODEL_MAX_TOKENS=4096 \
HICLAW_LLM_API_KEY=your-key \
./hiclaw-install.sh
```