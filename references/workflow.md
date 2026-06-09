# S/M/L 详细流程

> PM 判级、调度、推进流水线的完整操作手册。SKILL.md 的快速参考表是索引，本文档是执行规范。

---

## Phase 0: PM 判级

Supervisor 提出需求后，PM 第一动作是判级。判断标准:

### S 级 — 微调 (同会话内完成)

**触发条件** (满足任一):
- Bug 修复 (逻辑错误、样式问题、文案修正)
- 配置项调整 (环境变量、常量、开关)
- 无接口/数据模型/页面流转变化
- 预计改动 ≤2 个文件

**流程**: PM → Coder → PM 自测 → 通知 Supervisor

**跳过**: BA / Architect / UX / Tester

### M 级 — 特性 (2-3 个会话)

**触发条件** (满足任一):
- 在已有模块上新增功能
- 涉及 1-2 个角色的专项设计
- 有 UI 改动但不涉及新架构
- 预计改动 3-10 个文件

**流程**:
```
PM 判级 → 选 1-2 个 Worker:
  有 UI 改动 → UX → Coder
  有接口/数据变更 → Architect → Coder
  两者都有 → Architect ∥ UX → Coder
→ Tester
```

**跳过**: BA (需求明确时)

### L 级 — 大型变更 (3-5 个会话)

**触发条件** (满足任一):
- 新建模块/子系统
- 架构变更 (换框架、换数据层方案、新服务)
- 跨模块改动 (≥3 个模块受影响)
- 新数据表 + 新接口 + 新页面三者都有

**流程 (7 阶段)**:
```
Phase 0: PM 判级 + 向 Supervisor 确认范围
Phase 1: BA 需求澄清 → Supervisor 确认
Phase 2: Architect ∥ UX 并行设计 → PM alignment
Phase 3: Coder 方案 → Architect 审核 → Coder 编码 → PM 自测
Phase 4: Tester 独立测试
Phase 5: PM 汇总 → Supervisor 最终验收
```

---

## S 级详细流程

```
1. PM 确认范围:
   "这是 S 级 bug/config fix，我直接拉 Coder 改。"

2. PM dispatch Coder:
   - 角色: Coder (编码者)
   - 输入: 问题描述 + 相关文件路径
   - 产出: 代码变更 + 自测结果
   - 纪律: 只改问题范围，不做额外重构

3. Coder 完成 → PM 自测:
   - typecheck/lint 通过？
   - 改动在描述范围内？
   - 自测 case 通过？

4. PM 通知 Supervisor: "已修复。改了 X 文件的 Y 函数。"
```

**预计耗时**: 5-15 分钟

---

## M 级详细流程

### Session 1: PM 判级 + 选 Worker

```
1. PM 判级 → "这是 M 级，需要 [Architect / UX]，预计 2 个会话。"
2. PM 判断是否需要 BA:
   - 需求边界模糊 → 拉 BA 先澄清
   - 需求明确 → 跳过 BA
3. PM 选 Worker 组合:
   - 纯后端改动 → Architect → Coder
   - 纯前端改动 → UX → Coder
   - 全栈改动 → Architect ∥ UX → Coder
```

### Session 2: Coder 编码 + Tester 验证

```
4. Worker 产出就绪 → PM dispatch Coder
5. Coder 方案 + 编码 + 自测
6. PM dispatch Tester
7. Tester 报告 → PM 汇总 → Supervisor 验收
```

**预计耗时**: 30-60 分钟 (2 个会话)

---

## L 级详细流程

### Phase 1: BA 需求澄清

```
PM dispatch BA:
  - 输入: Supervisor 原始描述 + PM 范围确认
  - 产出: docs/ba/<feature>.md
  - 门禁: MUST 全部满足 → PM 提交 Supervisor 确认
  - Supervisor 打回 → 分级处理 (MINOR/MAJOR/FATAL)
```

### Phase 2: Architect ∥ UX 并行

```
PM 同时 dispatch:
  Architect: 基于 BA 文档做架构设计
  UX:       基于 BA 文档做交互设计

Architect 做出重大技术决策时 (选框架、定架构模式、引入新依赖):
  → PM 自动创建 ADR 草稿: `memory/decisions/ADR-<序号>-<标题>.md`
  → 填入: 背景、决策、备选方案矩阵、后果
  → 标记状态: "提议"
  → Supervisor 或后续 Architect 可修改/废弃

竞态处理:
  - Architect 先完成 → PM 验证接口边界段 → 转发 UX → UX 对齐
  - UX 先完成 → PM 暂存 → Architect 完成后交叉比对
  - 冲突 → PM 仲裁 (成本小方改)

PM Alignment 检查:
  - UX 依赖的接口字段都在 Architect 接口边界段中？
  - UX 假设的数据结构匹配 Architect 的类型定义？
  - UX 页面流转覆盖所有接口状态 (Loading/Error/Empty)？
  - 没有"无主字段" (UX 用但 Architect 没定义)？
```

### Phase 3: Coder 方案 + 编码

```
1. PM dispatch Coder (方案阶段):
   - 输入: Architect 文档 + UX 文档 (如有)
   - 产出: docs/coder/<feature>.md (改动范围 + 实现步骤 + 自测计划)

2. Architect 审核方案:
   - 第 1 轮: Architect 标注问题 → Coder 修正
   - 第 2 轮 (仍不通过): Architect 自己写关键段

3. PM dispatch Coder (编码阶段):
   - 基于已审核方案编码
   - 执行自测计划
   - 完成后写 docs/pm/from-coder/<date>-done.md

4. PM 自测代码门禁:
   - 改动在方案范围内？
   - typecheck/lint 通过？
   - 无 console.log / 硬编码凭据？
```

### Phase 4: Tester 独立测试

```
PM dispatch Tester:
  - 输入: Architect 接口定义 + UX 状态矩阵 + Coder 自测计划
  - 产出: docs/tester/<feature>.md
  - 区分 [代码验证] vs [需人工验证]

CRITICAL Bug → 流程阻塞:
  1. 暂停验收
  2. 分析根因: Coder 实现问题 or 架构问题？
  3. 实现问题 → 打回 Coder → 重新测试
  4. 架构问题 → 拉 Architect → 可能回退到 Phase 2
  5. 更新 current-state.md 标记阻塞
  6. 通知 Supervisor
```

### Phase 5: PM 汇总 + Supervisor 验收

```
PM 验收前自查:
  - 所有角色 MUST 门禁已通过？
  - Architect ↔ UX 一致性已对齐？
  - 工作流状态表已更新？
  - memory/session/current-state.md 已更新？
  - 有阻塞项时已同步 Supervisor？

PM 向 Supervisor 汇报:
  - 完成了什么 (功能概述)
  - 改动了什么 (文件数 + 影响范围)
  - 测试结果 (通过数/失败数/Bug 列表)
  - 已知限制 (LOW 问题、待处理项)
```

---

## 打回分级处理

Worker 产出被驳回时，PM 按此分级:

| 级别 | 定义 | 处理方式 | 时限 |
|------|------|---------|------|
| **MINOR** | 缺少 SHOULD 项，或 MUST 项的小缺失 | PM 标注 → Worker 增量补充 | 同会话 |
| **MAJOR** | MUST 项大面积缺失 | PM 标注 → Worker 重做对应章节 | 单次重做 |
| **FATAL** | 方向错误，需重新来 | PM 写清原因 → 重派 | 重新完整产出 |

### BA 被 Supervisor 打回

```
MINOR: PM 标注问题 → BA 增量修改 → PM 再提交
MAJOR: PM 汇总缺失清单 → BA 重写对应章节 → PM 再提交
FATAL: PM 重新向 Supervisor 确认意图 → 重拉 BA
```

### Architect 判定"不可行"

Architect 说不可行时 MUST 附带:
1. 具体原因 (技术限制 / 资源不够 / 时间来不及)
2. 替代路径 ("做不到完整版，但能做到什么程度")
3. 替代路径的成本和风险

PM 消化后整理成 Supervisor 能理解的选择题，Supervisor 选定后重新规划。

### 同一 Worker 超过 3 轮打回

PM 不再打回同一个 Worker:
1. 判断: 跳过此 Worker 继续推进？还是换一个？
2. 跳过 → 标注风险: "缺少 X 的正式审核，PM 已自审替代"
3. 通知 Supervisor: "X 阶段卡住了，我做了 Y 处理，风险是 Z"

---

## Worker 超时/卡死处理

| 情况 | PM 动作 |
|------|--------|
| 派发后 6 分钟无产出 | 重拉新 Agent，prompt 标注 5 分钟完成 |
| 重拉后仍无产出 | 检查 prompt → 缩减必读文档 → 再重拉 |
| 连续 3 次失败 | PM 自判断: 自己完成或换角色策略 |
| 两个 Worker 产出同一任务 | 取后完成的，丢弃先完成的 |

---

## 并行 Coder 分派 (M 级特例)

触发条件: 改动涉及 ≥3 个文件，且文件间无共享类型/接口变更依赖。

PM 标准动作:
1. 列出每个 Coder 的改动文件清单，确认清单间无交集
2. 预提取共享素材 (常量、类型、配置) 在分派前备好
3. 涉及共享类型变更 → 先走单人通道，其他 Coder 等合并
4. 并行完成后 PM 亲自集成验证

---

## 相关文件

- 判级后 dispatch → 见 `references/workers.md`
- 产出验收标准 → 见 `references/gates.md`
- Worker 协作规则 → 见 `references/collaboration.md`
- 跨会话记忆 → 见 `references/memory.md`
