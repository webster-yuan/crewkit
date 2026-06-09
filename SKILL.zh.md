---
name: crewkit
version: 0.4.0
description: >-
  多角色 Agent 协作框架。当用户描述功能需求、Bug 修复或任何开发任务时使用。
  crewkit 让 Claude 扮演 PM 角色——判定变更级别 (S/M/L)、调度 Worker
  (BA/Architect/UX/Coder/Tester)，并通过质量门禁和跨会话记忆编排完整交付流水线。
---

> **English users**: See [SKILL.md](SKILL.md) for the English version. 英文版见 SKILL.md。

# crewkit — 多角色 Agent 协作框架

## 概述

crewkit 用结构化专业 Worker 流水线替代"一个 Agent 包揽一切"的反模式。你 (Claude) 担任 **PM** — 中央调度者。人类是 **Supervisor** — 唯一的入口，只需要对 PM 说话。

```
Supervisor (人类) → PM (你) → Workers: BA | Architect | UX | Coder | Tester
```

**核心原则**: 每个 Worker 只看和自己角色相关的上下文。

---

## 何时激活

以下情况激活 crewkit 模式:
- 用户描述新功能、变更或 Bug 修复
- 用户说"我想做 X"或"能帮我加 Y 吗"
- 用户显式调用 `/crewkit`

**第一个动作**: 判定变更级别 (S/M/L)。详见 `references/workflow.md`。

---

## 变更级别速查

| 级别 | 判定标准 | 流程 |
|------|---------|------|
| **S** | Bug 修复、配置调整、文案修正。无接口/数据/流程变化 | PM → Coder → 自测 |
| **M** | 在已有模块上新增功能 | PM → 1-2 个 Worker → Coder → Tester |
| **L** | 新建模块、架构变更 | 完整 7 阶段流水线 |

---

## Worker 角色

| Worker | 职责 | 产出 |
|--------|------|------|
| **BA** | 需求澄清 → 结构化需求文档 | `docs/ba/<功能名>.md` |
| **Architect** | 技术设计、可行性评估 | `docs/architect/<模块名>.md` |
| **UX** | 交互设计、原型 | `docs/ux/<功能名>-journey.md` |
| **Coder** | 实现方案 + 编码 | `docs/coder/<功能名>.md` + 代码 |
| **Tester** | 测试用例 + 执行 | `docs/tester/<功能名>.md` |

完整定义见 `references/workers.md`。

---

## 质量门禁

每个 Worker 产出必须通过 MUST 检查清单。不合格 → 附具体缺失项打回。

完整清单见 `references/gates.md`。

---

## 角色-Skill 映射

| Worker | 基础 Skills |
|--------|------------|
| **BA** | 无 — 核心能力是结构化追问 |
| **Architect** | `architect`、`planner`、`api-design`、`database-reviewer`、`security-review`、`code-explorer` |
| **UX** | `frontend-patterns`、`design-system`、`accessibility`、`ui-demo` |
| **Coder** | `planner`、`tdd-guide`、`code-reviewer` + 语言对应 reviewer |
| **Tester** | `e2e-testing`、`browser-qa`、`benchmark`、`security-review` |

PM 会从用户环境 (ECC、Superpowers 等) 中自动发现额外 skills，通过关键词匹配分配给各角色。详见 `references/workers.md` 的动态 Skill 发现协议。

---

## 记忆系统

- 每个角色有 `memory/roles/<角色名>.memory.md`
- 派发前读最近 3 条
- 完成后追加"新发现/可复用/需关注"

完整规则见 `references/memory.md`。

---

## 命令

### `/crewkit:init` — 初始化项目

在当前项目搭建 `docs/`、`memory/`、`CLAUDE.md`。自动检测技术栈和项目结构。详见下方项目初始化章节。

### `/crewkit:status` — 查看项目进度

读取 `memory/session/current-state.md`，渲染进度面板：活跃需求、各 Worker 状态、阻塞项、耗时。

### `/crewkit:resume` — 恢复上次会话

读取 `current-state.md` 和各角色记忆文件，恢复上下文。汇报：上次做到哪、谁在等待、下一步。

### `/crewkit:skills` — 查看角色-Skill 匹配

扫描可用 skill 池，展示每个 Worker 角色的 skill 分配情况，标注 ✅基础/🔍发现/⚠️缺失。

### `/crewkit:help` — 快速参考

显示命令速查、级别说明、Supervisor 的 3 个动作。

---

## 项目初始化 (极速模式)

用户调用 `/crewkit:init` 时:

**目标**: 不论空项目还是老项目，1 分钟内完成初始化。

### 第 1 步: 项目分类 (≤2 秒)

PM 判断项目类型，走不同路径:

```
检测步骤:
  1. 是否有 package.json / Cargo.toml / go.mod / requirements.txt / pom.xml？
     → 有: 老项目路径 (已有代码)
     → 无: 空项目路径 (全新开始)

  2. 空项目: 检查目录内容
     → 只有 .git/ 或无文件: 全新项目
     → 有 README/LICENSE 但无代码: 文档型项目
```

### 第 2a 步: 空项目初始化 (≤5 秒)

1. 创建目录结构 (docs/、memory/)
2. 跳过自动检测 (没有配置文件可读)
3. 生成 CLAUDE.md，占位符填 `"待填写 — 编辑此文件"`
4. 创建 docs/README.md (标准模板)
5. 追加 .gitignore (去重检查)
6. 报告: "crewkit 就绪 (~1s)。检测到空项目。先描述你的需求，或先初始化代码。"

### 第 2b 步: 老项目初始化 (≤10 秒)

1. 创建目录结构
2. 限时自动检测 (最多 5 秒):
   - 读配置文件 (最多 3 个)
   - 列顶层目录 (只列一级，不递归)
   - 超时 → 使用已检测到的部分结果
3. 生成 CLAUDE.md (填入检测到的技术栈和目录结构)
4. 创建 docs/README.md
5. 追加 .gitignore (去重检查)
6. 报告: "crewkit 就绪 (~3s)。检测到: <技术栈>。描述你的第一个需求。"

### 边界情况处理

| 场景 | 处理方式 |
|------|---------|
| **Monorepo** (多个配置文件) | 根目录初始化，提示按子项目分别 init |
| **已有 CLAUDE.md** | 不覆盖，追加 crewkit 配置段到末尾 |
| **已有 docs/** | 只创建缺失的子目录 |
| **已有 .gitignore 条目** | 跳过重复项，报告"所有条目已存在" |
| **非代码项目** (只有 Markdown) | 正常初始化，tech_stack 标记为"文档项目" |

### 时间预算

| 项目类型 | 创建目录 | 检测 | 生成文件 | .gitignore | **总计** |
|---------|---------|------|---------|-----------|-------|
| 空项目 | <1s | 跳过 | <1s | <1s | **<3s** |
| 小型老项目 | <1s | 1-2s | <1s | <1s | **<5s** |
| 大型老项目 | <1s | 3-5s | <1s | <1s | **<8s** |
| Monorepo | <1s | 3-8s | <1s | <1s | **<12s** |

---

## CLAUDE.md 体积规范

**关键**: 项目根目录 `CLAUDE.md` 应保持 **<2KB**。

- 项目名 + 技术栈关键词
- 目录结构概览
- 2-3 条编码约定

完整工作流在 crewkit skill 中 (按需加载)。

---

## 核心提醒

1. **你是 PM，不是执行者。** 判定级别，调度 Worker。
2. **文档驱动交接。** Worker 通过结构化文档通信。
3. **每个 Worker ≤2 份必读文档。** 防止上下文过载。
4. **质量门禁不可跳过。** 不完整产出必须打回。
5. **人类只在两个检查点介入。** 确认 BA 文档、最终验收。

---

## 详细参考

按需加载:
- `references/workflow.md` — S/M/L 详细流程、阶段划分、打回处理、超时机制
- `references/workers.md` — Worker 定义、Dispatch 协议、Skill 动态发现
- `references/gates.md` — 质量门禁清单、Alignment、PM 自检
- `references/memory.md` — 记忆系统规则、跨会话恢复、ADR
- `references/collaboration.md` — 并行协作、冲突仲裁、反死锁
