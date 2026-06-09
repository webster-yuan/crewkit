# Worker 协作 + 反死锁规则

> 定义并行 Worker 之间的接口对齐方式、冲突仲裁机制、以及 PM 防止流程卡死的自保规则。

---

## 并行协作场景

### 场景 1: Architect ∥ UX (L 级 Phase 2)

Architect 和 UX 同时被 PM 启动，需要共享"接口边界"信息。

```
PM 同时派发:
  ├── Architect: "产出架构文档，标注'给 UX 的接口边界'段"
  └── UX: "先读取需求文档，等 Architect 产出接口边界段后再完成交互文档"

竞态处理:
  Architect 先完成 → PM 验证接口边界段完整 → 转发给 UX → UX 基于接口做设计
  UX 先完成 → PM 暂存，等 Architect → 交叉比对 → 如冲突标记打回 UX
```

**PM 标准动作**:
1. 派发 Architect 时强调: "第 3 章接口边界段是 UX 的输入，必须最先完成"
2. 派发 UX 时说明: "先读需求文档出初稿，等 Architect 接口边界后对齐终稿"
3. Architect 完成后 PM 做 alignment 检查 (见 `references/gates.md`)

### 场景 2: UX 先完成，Architect 后完成

常见于 UX 设计简单、Architect 调研复杂的情况。

```
Architect 的接口定义与 UX 的假设不一致:
  例如 UX 假设"用户列表返回头像URL"，Architect 定义"只返回头像ID"

PM 处理:
  1. 识别冲突点
  2. 判断谁改成本更小
  3. 打回成本更小的一方修改
```

### 场景 3: 并行 Coder 分派 (M 级)

触发条件: 改动涉及 ≥3 个文件，且文件间无共享类型/接口变更依赖。

PM 标准动作:
1. 列出每个 Coder 的改动文件清单，确认清单间无交集
2. 预提取共享素材 (常量、类型、配置) 在分派前备好
3. 涉及共享类型变更 → 先走单人通道，其他 Coder 等合并
4. 并行完成后 PM 亲自集成验证

---

## Worker 间通信规则

### 允许通道

| 场景 | 方式 |
|------|------|
| Coder → Architect 确认技术细节 | 通过 PM 转达，或直接 Read 对方产出文档 |
| UX → Architect 确认接口字段含义 | 通过 PM 转达，或直接 Read 接口边界段 |
| 任何 Worker 读任何其他 Worker 的产出文档 | 直接 Read (文档是公共的) |

### 禁止通道

| 行为 | 原因 |
|------|------|
| Coder 直接要求 UX 改交互设计 | 须经 PM 仲裁 |
| UX 直接要求 Architect 改接口 | 须经 PM 仲裁 |
| 任何"改变设计"的请求绕过 PM | PM 是唯一仲裁者 |
| Worker 间私下达成冲突约定 | 可能导致整体不一致 |

**核心原则**: Worker 可以读任何文档，但只能改自己的产出。任何跨角色的设计变更必须经 PM。

---

## 冲突仲裁

| 冲突类型 | PM 仲裁原则 |
|---------|-----------|
| 接口字段不一致 | 以 Architect 为准，除非改接口成本过高 |
| 交互流程 vs 接口限制 | PM 评估: 改 UX 便宜还是改接口便宜 |
| 两个 Worker 都认为对方该改 | PM 做最终判断，不在 Worker 间来回踢 |
| PM 也无法判断 | 升到 Supervisor，带两选项优劣分析 |

---

## 打回分级处理

Worker 产出被驳回时:

| 级别 | 定义 | 处理方式 | 时限 |
|------|------|---------|------|
| **MINOR** | 缺少 SHOULD 项，或 MUST 项的小缺失 | PM 标注缺失项 → Worker 增量补充 | 同会话 |
| **MAJOR** | MUST 项大面积缺失 | PM 标注所有缺失项 → Worker 重做缺失章节 | 单次重做 |
| **FATAL** | 方向错误，需重新来 | PM 写清"为什么方向错 + 正确方向" → 重派 | 重新完整 |

### Architect 审核 Coder 方案不通过

```
最多 1 轮:
  第 1 轮: Architect 标注问题 + 可执行建议 → Coder 修正方案
  第 2 轮 (仍不通过): Architect 自己写方案关键段，不再打回 Coder
```

### Tester 发现 CRITICAL Bug

```
CRITICAL Bug → 流程阻塞，不可验收

PM 动作:
  1. 暂停验收流程
  2. 分析根因: Coder 实现问题 or 架构设计问题？
     - 实现问题 → 打回 Coder 修复 → 重新跑 Tester
     - 架构问题 → 拉 Architect 评估 → 可能回退到 Phase 2
  3. 更新 current-state.md 标记阻塞
  4. 通知 Supervisor
```

---

## Worker 超时/卡死处理

| 情况 | PM 动作 |
|------|--------|
| 派发后 6 分钟无产出 | 重拉新 Agent，prompt 标注 5 分钟完成 |
| 重拉后仍无产出 | 检查 prompt → 缩减必读文档 → 再重拉 |
| 连续 3 次失败 | PM 自判断: 自己完成或换角色策略 |
| 两个 Worker 产出同一任务 | 取后完成的，丢弃先完成的 |

---

## PM 自保规则 (防死锁)

当流程卡在同一个 Worker 超过 3 轮打回时:

1. **PM 不再打回同一个 Worker** — 避免无限循环
2. **PM 判断**: 跳过此 Worker 继续推进？还是换一个？
3. **如果跳过** → 标注风险: "缺少 X 的正式审核，PM 已自审替代"
4. **通知 Supervisor**: "X 阶段卡住了，我做了 Y 处理，风险是 Z"

---

## Supervisor 决策请求规范

PM 向 Supervisor 请求决策时，标准格式:

```
需要你决策: <一句话描述问题>

选项 A: <方案描述>
  - 优点: ...
  - 缺点: ...
  - 成本/风险: ...

选项 B: <方案描述>
  - 优点: ...
  - 缺点: ...
  - 成本/风险: ...

PM 建议: <选哪个 + 理由>
```

---

## 相关文件

- PM 判级与调度 → 见 `references/workflow.md`
- Worker 定义与 Dispatch → 见 `references/workers.md`
- 质量门禁 → 见 `references/gates.md`
- 跨会话记忆 → 见 `references/memory.md`
