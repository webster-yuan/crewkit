# Worker 横向协作协议

> 定义并行 Worker (Architect ↔ UX) 之间的接口对齐方式和冲突仲裁机制。
> PM 是唯一仲裁者，Worker 间不允许私下达成冲突约定。

---

## 协作场景

### 场景 1: Architect ∥ UX (L 级, Phase 2)

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
3. Architect 完成后 PM 做 alignment 检查 (见下方 checklist)

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

### 场景 3: Worker 之间直接确认

少数情况下，Worker 需要直接向另一个 Worker 确认细节。

**允许通道**:
- Coder 可向 Architect 确认技术细节（通过 PM 转达或直接 Read 对方产出文档）
- UX 可向 Architect 确认接口字段含义

**禁止通道**:
- Coder 不能直接向 UX 要求改交互设计（须经 PM）
- UX 不能直接向 Architect 要求改接口（须经 PM）
- 任何"改变设计"的请求必须经过 PM 仲裁

---

## PM Alignment Checklist

PM 在 Architect 和 UX 都完成后，做交叉比对:

| 检查项 | 方法 | 不通过处理 |
|--------|------|-----------|
| UX 依赖的接口字段都在 Architect 接口边界段中 | 逐一比对 UX §5 与 Architect §3 | 缺失字段 → Architect 补 |
| UX 假设的数据结构匹配 Architect 的类型定义 | 比对类型名和字段名 | 不一致 → 成本小方改 |
| UX 的页面流转覆盖所有接口状态 | 检查 Loading/Error/Empty 是否都有 UI | 缺状态 → UX 补 |
| 没有"无主字段" | 搜索 UX 文档中未在 Architect 中定义的字段 | → 要么加，要么删 |

---

## 冲突仲裁

| 冲突类型 | PM 仲裁原则 |
|---------|-----------|
| 接口字段不一致 | 以 Architect 为准，除非改接口成本过高 |
| 交互流程 vs 接口限制 | PM 评估: 改 UX 便宜还是改接口便宜 |
| 两个 Worker 都认为对方该改 | PM 做最终判断，不在 Worker 间来回踢 |
| PM 也无法判断 | 升到 Supervisor，带两选项优劣分析 |

---

## 并行 Coder 分派 (M 级)

触发条件: 改动涉及 ≥3 个文件，且文件间无共享类型/接口变更依赖。

PM 标准动作:
1. 列出每个 Coder 的改动文件清单，确认清单间无交集
2. 预提取共享素材（常量、类型、配置）在分派前备好
3. 涉及共享类型变更 → 先走单人通道，其他 Coder 等合并
4. 并行完成后 PM 亲自集成验证
