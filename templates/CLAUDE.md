# CLAUDE.md

This file provides guidance to Claude Code when working in this repository.

## Project Overview

**crewkit** — 基于多角色 Agent 协作的通用开发框架模板。核心理念是将人类 Supervisor 与多个专职 AI Agent Worker 组织成有纪律的协作流水线，每个 Worker 角色拥有独立的记忆和上下文适配能力。

- **协作模型**: Supervisor (Human) → 多 Worker (AI Agents)，Supervisor 是唯一入口
- **开发模式**: 文档驱动 — 先写文档再写代码，文档按角色组织
- **语言/框架**: 不限，本模板为方法论层，可适配任意技术栈

## Supervisor-Worker 角色体系

```
Supervisor (人类)
    │
    ▼
  PM (Worker) ─── 编排调度中枢
    │
    ├── BA (Worker)         需求澄清 + 需求文档
    ├── Architect (Worker)  技术调研 + 架构设计
    ├── UX Designer (Worker) 交互设计 + 原型
    ├── Coder (Worker)      方案 → 编码 → 自测
    └── Tester (Worker)     独立测试 + 报告
```

| # | 角色 | 类型 | 输入 → 产出 | 核心职责 |
|---|------|------|-------------|---------|
| 1 | **Supervisor** | Human | 业务目标 → 需求描述 | 提需求、验收各阶段产出 |
| 2 | **PM** | AI Worker | 需求 → 进度 + 编排 | 分级判定、按需调度、进度追踪、对接 Supervisor |
| 3 | **BA** | AI Worker | 口头需求 → `docs/ba/<feature>.md` | Q&A 追问澄清，产出需求文档 |
| 4 | **Architect** | AI Worker | 需求文档 → `docs/architect/<module>.md` | 技术调研 + 可行性 + 架构设计 |
| 5 | **UX Designer** | AI Worker | 需求 + 接口边界 → `docs/ux/<journey>.md` | 交互流程、状态矩阵、原型 |
| 6 | **Coder** | AI Worker | 架构文档 + 交互文档 → 代码 | 出方案 → 审核 → 编码 → 自测 |
| 7 | **Tester** | AI Worker | 全量文档 + 代码 → `docs/tester/<feature>.md` | 提前写用例，编码后执行测试 |

**核心原则**: Supervisor 只和 PM 对话。PM 是唯一入口和出口。其余 Worker 是 PM 的工具箱，互相可协作，但产出统一汇总到 PM。

## 变更分级（CRITICAL — 入会话即判断）

每个任务进入会话时，PM 首先判断变更级别，走不同轨道：

| 级别 | 典型场景 | 流程 | 预计耗时 |
|------|---------|------|---------|
| **S** | Bug fix、文案/样式微调、配置变更 | Supervisor → PM → Coder 直接改 → PM 自测 | 同会话内 |
| **M** | 现有模块加功能、新增接口 | BA(可选) → Architect 标代码位置 → Coder 方案 → 编码 → Tester | 2-3 会话 |
| **L** | 全新模块、跨模块架构变更 | 完整 7 阶段流水线 | 按节奏 |

**S 级判定标准**: 不改接口/协议、不改数据模型、不改变更流转。满足全部三条。

## L 级全流程

```
Supervisor ──→ PM ──→ PM 判断级别，拉 BA 做需求澄清
                      │
                      ↓ BA 产出需求文档 → 交回 PM
                 PM 消化后找 Supervisor 确认 ──→ 不通过 → PM 拉 BA 修改
                      │
                      ↓ Supervisor 通过
                 PM 拉 Architect 做技术调研 + 可行性判断
                      │
                      ├── 不可行 → PM 反馈 Supervisor
                      │
                      ↓ 可行
                 PM 拉 Architect (接口边界) ∥ UX (交互设计)
                      │                              │
                      ↓ 架构文档                      ↓ 交互文档
                      └──────── PM 一致性检查 ────────┘
                                   │
                                   ↓ 通过
                 PM 拉 Coder (出方案) → PM 拉 Architect 审核方案
                                   │
                                   ↓ 方案通过
                 PM 并行分派:
                   Coder 编码 ┃ Tester 写用例
                      │              │
                      ↓ 代码         ↓ 用例就绪
                 PM 自测初步验证      │
                      │              ↓
                      └──────→ Tester 执行测试
                                   │
                                   ↓ 测试报告 → PM
                 PM 汇总结果，找 Supervisor 验收
```

## M 级流程（精简轨道）

PM 按需拉人，不全员出动：

| 需求涉及 | PM 拉谁 | 跳过谁 |
|---------|---------|--------|
| 只改交互/UI/样式 | PM → UX → Coder → Tester | 不拉 Architect |
| 只改后台/数据/API | PM → Architect → Coder → Tester | 不拉 UX |
| UI + 后台都涉及 | PM → Architect ∥ UX → Coder → Tester | — |

最终收口永远是 Tester。每个角色完成 → 通知 PM → PM 推动下一棒。

## S 级流程（快速轨道）

```
Supervisor 告诉 PM "改一下 X"
  → PM 判断 S 级（不改接口/数据模型/流转）
  → PM 拉 Coder 直接改（同会话内）
  → PM 自测验证
  → commit
```

## 角色纪律

| 纪律 | 说明 |
|------|------|
| **先分级再动手** | PM 入会话第一件事：判断 S/M/L |
| **不跳级** | Coder 只能从 Architect + UX 接收输入（L 级）|
| **不猜测** | BA 不确定的需求必须追问 Supervisor |
| **不越界** | Architect 不设计 UI，UX 不决定数据模型 |
| **不拍板** | Coder 遇文档未覆盖的决策，标记问 PM |
| **不走过场** | Tester 必须实际执行测试，不能只读代码推断 |
| **方案审核最多 1 轮驳回** | Architect 驳回必须附可执行建议。第 2 轮仍不通过 → Architect 自己写方案关键段 |

## Worker 角色记忆与上下文适配

每个 Worker Agent 启动时，PM 需为其注入**角色专属上下文**：

### 角色 Prompt 注入结构

```
PM 拉 Worker 时，prompt 结构：

1. 角色身份声明    "你是 XX 角色，职责是..."
2. 输入文件清单    必读文档 + 参考文档（不超过 2 份必读）
3. 产出规格要求    格式模板 + 必须包含的章节
4. 纪律约束        该角色需遵守的规则
5. 时间预算        预期完成时间（后台 Agent 标注 5 分钟内）
```

### 上下文精简原则

- 必读文档 ≤ 2 份（每多一份文档，Agent Read 耗时累加，易超时）
- 参考文档按需 Read，不在 prompt 中全量列出
- 先给高层次指令，让 Agent 自己决定需要 Read 哪些参考文档

### 角色技能映射

| 角色 | 建议加载的 Skills |
|------|------------------|
| **BA** | 无需特定 skill；核心是结构化 Q&A 追问 |
| **Architect** | `architect`, `planner`, `api-design`, `database-reviewer`, `security-review`, `documentation-lookup` |
| **UX Designer** | `frontend-patterns`, `design-system`, `accessibility` |
| **Coder** | `planner`, `tdd-guide`, `code-reviewer`, 语言相关 reviewer |
| **Tester** | `e2e-testing`, `browser-qa`, `benchmark`, `security-review` |

### 跨会话记忆持久化

每个 Worker 拥有独立的记忆文件 (`memory/roles/<role>.memory.md`)，在多次会话间持续积累。

**PM 派发 Worker 时的注入流程**:

```
1. PM 读取 memory/roles/<role>.memory.md 最近 3 条记录
2. PM 读取 memory/session/current-state.md 获取全局上下文
3. PM 将记忆摘要注入 Worker prompt 的"已知上下文"段
4. Worker 执行任务
5. Worker 完成后同时做两件事:
   a. 写 docs/pm/from-<role>/<date>-done.md（通知 PM）
   b. 追加更新 memory/roles/<role>.memory.md（持久化记忆）
6. PM 更新 memory/session/current-state.md
```

**记忆追加格式** (Worker 写):

```markdown
## <YYYY-MM-DD> — <任务简述>

### 新发现
- 约束/限制/模式

### 可复用
- 调研结论/代码片段/测试用例

### 需要关注
- 潜在风险/未完事项
```

**记忆读取时机**:

| 时机 | 读什么 |
|------|--------|
| PM 新会话启动 | `memory/session/current-state.md` 恢复上下文 |
| 派发 Worker 前 | `memory/roles/<role>.memory.md` 最近 3 条 |
| 做同类需求 | 在记忆文件中搜索关键词 |
| 遇到阻塞 | 检查 `current-state.md` 的阻塞项 |

**记忆目录结构**:

```
memory/
├── roles/                           # 各 Worker 知识积累
│   ├── architect.memory.md          # 技术调研缓存、架构约束
│   ├── ba.memory.md                 # 领域术语、Supervisor 偏好
│   ├── ux.memory.md                 # 设计决策、交互模式
│   ├── coder.memory.md              # 代码约定、踩坑记录
│   └── tester.memory.md             # 测试模式、回归点
├── session/
│   └── current-state.md             # 当前会话状态
└── decisions/                       # 架构决策记录 (ADR)
```

## 状态同步机制

每个 Worker 完成工作后，往 `docs/pm/from-<自己角色>/<YYYY-MM-DD>-done.md` 写通知：

```markdown
# <角色> - Phase X done (YYYY-MM-DD)
- 产出: docs/<role>/<file>
- 下一棒: <角色>，需读 docs/<role>/<file1> + docs/<role>/<file2>
- 备注: <有无阻塞/风险>
```

PM 收到通知后负责更新状态表。各 Worker 不自己改状态表（减少冲突）。

## PM 会话启动检查清单

PM 进入新会话后，第一件事：

1. 检查 `docs/pm/from-*/` 看有无未读通知
2. 有 `from-<role>/<date>-done.md` → 立刻触发下一棒角色
3. 更新工作流状态表
4. 如有 `from-<role>` 标了「需要 Supervisor 决策」→ 立即同步

## Agent 防死锁规则

| 规则 | 做法 |
|------|------|
| **派发前去重** | 拉新 Agent 前先检查目标产出文件是否已存在。已存在 → 不重复派发 |
| **6 分钟超时重拉** | cron 超过 2 轮无产出 → 直接重拉，prompt 标注「请控制在 5 分钟内完成」|
| **cron 自驱** | cron prompt 必须包含完整 dispatch 指令（读什么、判什么、拉谁）|
| **重复产出取新** | 同任务两个 Agent 都完成时，用后完成的覆盖 |
| **只异步阶段用 cron** | Coding 是同步执行的，不需要 cron。Architect/UX/Tester 后台跑才需要 |

## 文档目录结构

```
docs/
├── ba/                             # BA 产出: <feature>.md + prototype/
├── architect/                      # Architect 产出: <module>.md + research/ + review/
├── ux/                             # UX 产出: <module>-journey.md
├── coder/                          # Coder 产出: <feature>.md + debug/
├── tester/                         # Tester 产出: <feature>.md + e2e/
└── pm/                             # PM 产出 + 收件箱
    ├── progress-report.md          # 项目进度报表
    ├── skill-allocation.md         # 角色技能分配表
    ├── <feature>-alignment.md     # 设计对齐检查
    └── from-{ba,architect,ux,coder,tester}/  ← Worker → PM 反馈通道
```

## 每份产出文档末尾必须加

```markdown
---
## 下一棒阅读清单

| 优先级 | 文档 | 用途 |
|--------|------|------|
| 必读 | `docs/xxx/yyy.md` | 为什么必读 |
| 参考 | `docs/xxx/zzz.md` | 什么场景参考 |
```

## 工作流状态

| 需求 | Phase 1 BA | Phase 2 架构 | Phase 2 UX | Phase 3 方案 | Phase 3 编码 | Phase 4 测试 | Phase 5 验收 |
|------|-----------|-------------|-----------|-------------|-------------|-------------|-------------|
| — | — | — | — | — | — | — | — |

状态标记: `⏳ 进行中` / `✅ 完成` / `❌ 打回` / `— 未开始` / `⏭️ 跳过` / `⚠️ 阻塞`

## PM 智能调度索引

> Supervisor 提出需求 → PM 根据关键词匹配下表 → 知道查哪份架构文档 + 拉哪些角色。

| Supervisor 说（关键词） | 架构文档 | 级别 | PM 拉谁 |
|------------------------|---------|------|---------|
| (按项目实际填写) | `docs/architect/xxx.md` | **M/L** | Architect → Coder → Tester |

## PM 效率经验（持续积累）

### 并行 Worker 分派

触发条件: 改动涉及 ≥3 个文件，且文件间无共享类型/接口变更依赖。

做法:
1. PM 先做依赖分析 — 确认哪些文件可以独立修改
2. 按文件粒度拆任务
3. 预提取共享素材避免 Worker 重复劳动
4. 并行分派后 PM 监控，完成后立刻合并验证

### Agent prompt 只给必读文档

每多一份文档就多一轮 Read → 多几十秒 → Agent 累积超时。必读文档控制在 2 份以内。

### Cron 跟着流程阶段切换

流程推进时，旧 cron 检查逻辑已过期。PM 必须: 删旧 cron → 建新 cron，确保只检查当前阶段的产出文件。

### Coder 编码阶段不需要 cron

Coding 是同步执行的，完成后直接通知。只在异步阶段（Architect/UX/Tester 后台跑）才需要 cron 驱动。

## 项目架构决策

> 记录关键架构决策及其原因。每次重大决策后在此追加。

| 日期 | 决策 | 原因 | 备选方案 |
|------|------|------|---------|
| — | — | — | — |
