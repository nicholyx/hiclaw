# Fix Issue #346: 本地vllm启动的模型，长度超限

## Issue 概述

- **Issue 编号**: #346
- **Issue 类型**: bug
- **仓库**: higress-group/hiclaw
- **状态**: In Progress

## 问题描述

用户配置了 32K 长度的本地 vllm 模型，通过 OpenAI 兼容接口配置。但用户只问了一句"你好"，就收到错误：

```
400 You passed 74655 input characters and requested 32000 output tokens. However, the model's context length is only 32000 tokens, resulting in a maximum input length of 0 tokens (at most 0 characters). Please reduce the length of the input prompt. (parameter=input_text, value=74655)
```

问题关键：用户只输入了简单的"你好"，但系统报告输入了 74655 字符，说明系统提示词或上下文累积了过多内容。

## 相关链接

- Issue URL: https://github.com/higress-group/hiclaw/issues/346

## 实现计划

- [ ] 理解需求 - 使用 brainstorming skill
- [ ] 编写测试 - 使用 test-driven-development skill
- [ ] 实现修复 - 使用 subagent-driven-development skill
- [ ] 验证通过 - 使用 verification-before-completion skill
- [ ] 代码审查 - 使用 requesting-code-review skill

## 进度记录

- 2026-03-18: 开始处理，创建 worktree 和分支