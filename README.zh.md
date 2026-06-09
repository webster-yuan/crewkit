# crewkit — 多角色 Agent 协作开发框架

> 一个 Claude Code skill，将传统单人 Agent 的"一条龙"拆解为 **Supervisor + PM + 5 个专职 Worker** 的协作流水线。

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-skill-6C4DFF)](https://claude.ai/code)

---

## 为什么是 SKILL 而不是 CLAUDE.md

### 按需加载，不常驻上下文

如果把 crewkit 完整流程（角色定义、Quality Gates、Dispatch Protocol、Anti-Deadlock 等）全塞进项目根目录 `CLAUDE.md`，每次会话自动注入 6,000+ tokens 的流程文档。

排查一个 API 报错时，这些用不上。但 LLM 每轮都得先读完。

SKILL 模式：
- `CLAUDE.md` 只放 2KB 的项目简介 + 一句话「开发走 crewkit 流程」
- 用户说「实现一个新功能」→ LLM 识别 → 加载 crewkit SKILL → 完整的 PM 流水线
- 用户说「排查 405 错误」→ 不加载 crewkit → 6,000 tokens 省了

### 跨项目复用

SKILL 装在 `~/.claude/skills/` 或 `~/.hermes/skills/`，所有项目共享。不需要每个项目复制粘贴一份 25KB 的流程文档。

### 可组合

SKILL 不是孤立的。crewkit 可以和 `forensic-bisect`（排查时用）、`skill-scout`（派 Worker 前自动匹配技能）、`desktop-app-secrets`（Electron 安全）组合加载。CLAUDE.md 做不到按场景动态组合。

---

## 为什么用 crewkit

### 1. 角色分化，产出具体落地
单人开发时容易"想一步做一步"。crewkit 把开发拆成 PM/BA/Architect/UX/Coder/Tester 六个角色，每个角色产出独立文档——需求澄清、架构方案、交互设计、测试用例——不再是"代码写了就行"。

### 2. 文档成长链路
`docs/` + `memory/` 双目录驱动项目演进：
- `docs/ba/` → 需求澄清记录
- `docs/architect/` → 技术方案 + 候选方案对比
- `docs/tester/` → 用例矩阵 + 回归清单
- `memory/roles/` → 每个角色跨会话积累经验
新成员接手时不再是"看代码猜业务"，而是"读文档理解设计"。

### 3. 快照式会话启动
每个新会话，PM 先检查 `docs/pm/from-*/`（Worker 完成通知）+ `memory/session/current-state.md`。三行状态表代替半小时代码扫描，进来就知道"上次做到哪了、这棒该谁接"。

### 4. 防猜修机制
Coder 必须有 Architect 方案才能动手，Tester 必须有 UX 交互文档才能写用例。Quality Gates 强制先想清楚再写代码——堵死了单人开发最大的坑：看到 bug 直接改、看到需求直接写。

### 5. 上下文预算管理
每个 Worker 只看自己那段——BA 看需求、Architect 看接口边界、Coder 看方案输出。不会出现"一个会话塞 50KB 上下文然后 LLM 注意力涣散"的问题。DeepSeek v4-pro 这种无 prompt caching 的模型尤其受益。

### 6. 强制结构化思维
crewkit 本质是一场思维体操。BA 阶段逼你问"用户到底要什么"，Architect 阶段逼你列"至少两个候选方案"，Tester 阶段逼你写"失败场景+边界条件"。没有这个框架，大多数人会跳过这些，直奔代码。

### 7. 决策审计链
两周后回来看 `docs/architect/`，能知道"为什么选方案 B 而不是 A"——方案对比矩阵、候选优缺点、推荐理由都在。不只是知道"选了 B"，而是记得"当时的权衡是什么"。

### 8. 委派安全网
Dispatch Protocol 的五段式 prompt（身份 + 输入 + 产出 + 纪律 + 交付）是防静默失败的保险。子 Agent 不能提问、不能读记忆——prompt 稍有遗漏就产出报废。这个模板确保每个 Worker 得到完整的任务上下文。

---

## 安装

```bash
git clone https://github.com/YOUR_USERNAME/crewkit.git
cd crewkit
bash install.sh        # macOS / Linux / WSL
# 或
.\install.ps1          # Windows PowerShell
```

安装到 `~/.claude/skills/crewkit/` 后即可在任何项目中使用。

## 快速开始

**1. 在项目中初始化 crewkit：**

在 Claude Code 会话中输入：

```
/crewkit:init
```

这会在项目根目录创建 `docs/`、`memory/` 和 `CLAUDE.md` 模板。

**2. 描述你的需求：**

```
我想给后台加一个操作日志功能
```

Claude 会自动以 **PM** 角色判断变更级别（S/M/L），按需调动 BA、Architect、UX、Coder、Tester。

**3. 你只需在两个节点确认：** 需求文档确认 + 最终验收。中间全部由 PM 自动调度。

---

## 为什么传统单人 Agent 效率低

把需求到交付全压在一个 Agent 身上，会触发 6 个系统性问题：

| 问题 | 根因 | 表现 |
|------|------|------|
| **上下文过载** | 一个会话塞进需求→架构→编码→测试的全部上下文 | 越往后 LLM 推理质量越差，丢失早期细节 |
| **角色混淆** | 同一 Agent 一会儿想架构、一会儿写代码、一会儿测功能 | 角色切换时丢失思维深度，架构决策和编码实现互相污染 |
| **无机构记忆** | 每次新会话从零开始 | 上次调研过的技术约束、踩过的坑全部丢失，重复踩 |
| **长链衰减** | 从需求到测试几千 token 的推理链 | 链条末端的决策质量远低于开端，测试往往形式化 |
| **自查盲区** | 同一个人（Agent）审自己的方案 | 架构问题、边界遗漏很难自检，需要外部视角 |
| **人类瓶颈** | 要么人类盯全程（累），要么完全不盯（失控） | 两个极端之间缺少结构化的人类介入点 |

### 根本原因

**LLM 在长上下文、多角色混合场景下的注意力衰减。** 单个 Agent 在从需求到交付的链条上，每往前推进一步，上下文就膨胀一轮。到了链条后端（编码、测试），Agent 脑子里的"需求原意"已经被前面的推理层层包裹，很容易走偏。

---

## crewkit 怎么解决

### 核心思路：分而治之

```
传统模式:                         crewkit 模式:

单个 Agent                        Supervisor (Human)
  │                                  │
  ├── 理解需求 (模糊)                PM (编排中枢)
  ├── 想架构 (拍脑袋)                │
  ├── 写代码 (边写边改)              ├── BA        → 需求文档    [聚焦: 澄清+边界]
  └── 测一下 (走形式)                ├── Architect → 架构文档    [聚焦: 技术+可行]
                                     ├── UX        → 交互文档    [聚焦: 流转+状态]
                                     ├── Coder     → 代码        [聚焦: 方案→实现]
                                     └── Tester    → 测试报告    [聚焦: 独立验证]
```

**每个 Worker 只处理自己角色范围内的上下文。** BA 不需要知道技术方案，Coder 不需要重新理解需求——他读 BA 的结构化文档。

### 四个核心机制

#### 1. 文档即接口 — 用结构化产出替代原始上下文传递

Worker 之间不传递会话历史，只传递**结构化文档**。一个 500 行的架构文档，是对 Architect 几千行思考链的压缩蒸馏。

```
需求原文 (自然语言, 模糊)
    → BA 文档 (结构化的需求规格, ~200行)
    → Architect 文档 (候选方案+接口定义, ~300行)
    → UX 文档 (状态矩阵+流转图, ~200行)
    → Coder 方案 (改动范围+步骤, ~150行)
    → 代码
    → Tester 报告 (用例矩阵, ~150行)
```

每一步都在**提炼和结构化**，而不是简单地把原始上下文往后堆。

#### 2. 角色隔离 — 每个 Worker 有独立的记忆和上下文边界

| 隔离维度 | 机制 |
|---------|------|
| **Prompt 隔离** | 每个 Worker 启动时注入角色专属 prompt，定义职责边界和行为约束 |
| **记忆隔离** | 每个 Worker 有独立的 `memory/roles/<role>.memory.md`，只积累自己领域的知识 |
| **上下文隔离** | Worker 只读自己的必读文档（≤2 份），不被其他角色的噪音干扰 |
| **纪律隔离** | "不越界" — Architect 不设计 UI，UX 不决定数据模型，Coder 不做设计决策 |

#### 3. 质量门禁 — 每个交接点有 MUST checklist

每个角色交接处设质量门禁，由一个**不是产出者**的角色执行。Architect 审核 Coder 方案，Tester 独立验证 Coder 代码——交叉审查天然覆盖自查盲区。

#### 4. 跨会话记忆 — 角色知识持续积累

每个 Worker 完成任务后追加更新自己的记忆文件，下次 PM 派发同一角色时自动注入。知识不随会话结束而丢失。

---

## 流程设计：三级分流

```
Supervisor 提需求
    │
    ▼
PM 判级 (不改接口/数据模型/流转 → S 级)
    │
    ├── S 级 (Bug fix、文案微调)
    │     PM → Coder 直接改 → PM 自测 (同会话内)
    │
    ├── M 级 (现有模块加功能)
    │     PM 按需拉 1-2 个角色 → Coder → Tester (2-3 会话)
    │
    └── L 级 (全新模块、架构变更)
          完整 7 阶段流水线: BA → Architect∥UX → Coder+Tester
```

**小改动不惊动全员**，只有大变更才拉满火力。

---

## 项目结构

```
crewkit/                              # ← 这个 repo (skill 源码)
├── SKILL.md                          # Skill 定义 (Claude Code 入口)
├── README.md                         # 本文件
├── install.sh / install.ps1          # 安装脚本
├── templates/                        # 项目脚手架 (复制到用户项目)
│   ├── CLAUDE.md                     #   PM 协议参考
│   ├── docs/                         #   各角色产出模板
│   │   ├── ba/                       #     BA: 需求文档 + 原型
│   │   ├── architect/                #     Architect: 架构设计 + 调研 + 审核
│   │   ├── ux/                       #     UX: 用户交互文档
│   │   ├── coder/                    #     Coder: 实现方案 + 调试记录
│   │   ├── tester/                   #     Tester: 测试报告 + E2E
│   │   ├── pm/                       #     PM: 调度协议 + 质量门禁 + 收件箱
│   │   └── roles/                    #     技术角色定义 (前端/后端/数据/...)
│   └── memory/                       #   跨会话角色记忆系统
│       ├── roles/                    #     每个 Worker 的知识积累
│       ├── session/current-state.md  #     会话状态恢复
│       └── decisions/                #     架构决策记录 (ADR)
├── LICENSE                           # MIT
└── .gitignore
```

---

## 适配任意技术栈

crewkit 是**方法论层**的 skill，不绑定语言和框架：

- 前端项目？给 UX + Coder 注入 `frontend-patterns` skill
- 后端项目？给 Architect 注入 `api-design` + `database-reviewer`
- 全栈项目？按模块拆，UI 走 M 级 (UX→Coder)，API 走 M 级 (Architect→Coder)
- 非软件项目（研究报告、内容生产）？保留 BA + PM + Tester，角色换成对应领域

核心不变的是：**分角色、文档接口、质量门禁、跨会话记忆**。

---

## crewkit 与 CrewAI / 多 Agent SDK 的区别

经常有人把 crewkit 跟 **CrewAI**（最主流的 Python 多 Agent 框架）做对比。它们解决的是不同问题：

| | **CrewAI** | **crewkit** |
|---|-----------|------------|
| **本质** | Python SDK — 写代码定义 Agent | Claude Code skill — 用自然语言驱动 |
| **上手** | `pip install` + 写 Python/YAML | `/crewkit:init` 然后描述需求 |
| **Agent 通信** | Python 内存对象传递 | 结构化 markdown 文档（可追溯、可审计） |
| **上下文控制** | 无内置限制 | ≤2 必读文档（防止注意力衰减） |
| **质量控制** | 无内置门禁 | 每阶段 MUST checklist，交叉审核 |
| **人的角色** | 可选钩子 | **结构支点** — Supervisor 是整个流程的轴心 |
| **跨会话记忆** | 任务级 | 文件持久化角色记忆，跨会话累积 |
| **任务分流** | 所有任务走相同流程 | S/M/L 三级分流 — 小改不动全员 |
| **适合** | 构建基于 Agent 的应用 | 用 Agent 团队管理开发流程 |

**CrewAI 是构建 Agent 应用的库，crewkit 是管理 Agent 开发团队的协议。** 二者互补 — 可以用 crewkit 来管理一个基于 CrewAI 的应用开发流程。

---

## 为什么是 "Supervisor" 而不是 "甲方" 或 "组长"

有人会疑惑：*"我是不是变成甲方了？我以前是开发者啊。"*

你既不是甲方也不是组长。**Supervisor 是一个独立角色**：

- 不是 **甲方** — 这是你自己的项目，不是在委外
- 不是 **组长** — 你不管理人也不写代码
- 你是 **决策者 + 质检员** — 你定方向（确认 BA 文档）、验成果（最终验收），中间信任 PM

深度没有消失，只是转移了：从*执行深度*（我知道怎么实现）变成了*体系深度*（我设计了一套让 Agent 不跑偏的协议）。

---

## 贡献

欢迎提 Issue 和 PR。

```bash
git clone https://github.com/YOUR_USERNAME/crewkit.git
cd crewkit
# SKILL.md 是主文件，templates/ 是脚手架
```

## License

MIT — 详见 [LICENSE](LICENSE)
