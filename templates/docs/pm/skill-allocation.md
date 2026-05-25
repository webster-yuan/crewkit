# 角色技能分配 (Skill Allocation)

PM 在启动各角色 Agent 时，按此文档加载对应的 skills。

## BA (需求分析师)

不依赖特定 skill。核心能力是结构化 Q&A 追问。

启动 prompt 要点:
- 逐条追问，不猜测
- Supervisor 确认后才写入需求文档
- 产出模板见 CLAUDE.md 对应章节

## Architect (架构师)

```
architect              ← 系统架构设计
planner                ← 实施计划
api-design             ← API 设计规范
database-reviewer      ← 数据模型审查
security-review        ← 安全审查
documentation-lookup   ← 查技术文档
code-explorer          ← 读现有代码确认影响范围
```

### 调研时额外加载

```
research-ops           ← 调研方法论
market-research        ← 技术选型市场调研
```

### 审查 Coder 修改方案 / 代码时额外加载

```
code-reviewer          ← 通用代码审查
silent-failure-hunter  ← 错误处理遗漏检查
```

## UX Designer (交互设计师)

```
frontend-patterns      ← 前端交互模式
design-system          ← 设计系统
accessibility          ← 无障碍 (WCAG 2.2)
ui-demo                ← 交互 Demo
```

## Coder (编码者)

```
planner                ← Plan 模式
tdd-guide              ← TDD 工作流
code-reviewer          ← 自测后自我审查
```

根据项目语言追加对应的 reviewer skill。

### 调试时额外加载

```
build-error-resolver   ← 构建错误排查
silent-failure-hunter  ← 错误处理遗漏
```

## Tester (测试者)

```
e2e-testing            ← E2E 测试框架
browser-qa             ← 浏览器自动化测试
benchmark              ← 性能基准测试
security-review        ← 安全审查
security-scan          ← 安全扫描
```
