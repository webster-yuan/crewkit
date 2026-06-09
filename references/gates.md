# Quality Gates — 各阶段质量门禁

> PM 收到每个 Worker 产出后，按此 checklist 判断 PASS / 打回。
> **PASS**: 所有 MUST 项满足。**打回**: 任一 MUST 项不满足 → 附带缺失项退回原 Worker。

---

## BA 产出门禁 (`docs/ba/<feature>.md`)

### MUST (缺一即打回)

- [ ] 需求概述能用一句话说清"为谁解决什么问题"
- [ ] 用户故事有 Who / What / Why 三要素
- [ ] In scope / Out of scope 边界明确
- [ ] 验收标准用 Given-When-Then 格式，每条可测试
- [ ] 覆盖至少 3 个异常/边界场景
- [ ] 未决问题明确标注"等待 Supervisor 确认"

### SHOULD (建议但不打回)

- [ ] 有优先级标注 (P0/P1/P2)
- [ ] 引用了相关的已有需求文档
- [ ] 术语首次出现时有定义

---

## Architect 产出门禁 (`docs/architect/<module>.md`)

### MUST (缺一即打回)

- [ ] 候选方案 ≥ 2 个，且各有明确的优缺点矩阵
- [ ] 推荐方案有量化的选择理由 (非"感觉这个好")
- [ ] 接口定义完整 (API 签名含入参/出参类型；数据表含字段+类型+索引)
- [ ] 标注了"给 UX 的接口边界"段落
- [ ] 影响分析覆盖: 改哪些现有代码、破坏哪些既有接口、迁移成本
- [ ] 可行性结论明确: 可行 / 可行但需前置 / 不可行+替代路径

### SHOULD

- [ ] 含架构关系图 (Mermaid 或 ASCII)
- [ ] 风险评估有概率和影响面量化 (高/中/低)
- [ ] 调研死胡同也记录 (避免下次重复)

---

## UX 产出门禁 (`docs/ux/<feature>-journey.md`)

### MUST (缺一即打回)

- [ ] 页面流转图完整 (正常路径 + 返回路径)
- [ ] 每个页面的状态矩阵: 正常 / Loading / Empty / Error / 边界
- [ ] 交互时序覆盖核心操作 (≥1 happy path + ≥1 error path)
- [ ] HTML 原型可浏览器打开并点击流转 (M/L 级强制)
- [ ] 原型中的文案与实际一致 (不能出现 Lorem ipsum)

### SHOULD

- [ ] 标注了与 Architect 接口边界的对应关系
- [ ] 有移动端/响应式考虑 (如适用)
- [ ] 有无障碍考虑 (键盘操作、屏幕阅读器)

---

## Coder 方案门禁 (`docs/coder/<feature>.md`)

### MUST (缺一即打回)

- [ ] 改动范围精确到文件路径和函数/方法名
- [ ] 实现步骤有序号、每步有预期产出、有依赖标注
- [ ] 不确定项用 `[?]` 标记，包含"需要谁决策什么"
- [ ] 自测计划覆盖 happy path + ≥2 个 error/edge cases
- [ ] L 级: 方案已通过 Architect 审核 (标注审核人和日期)

### SHOULD

- [ ] 标注了每步预计耗时
- [ ] 引用了架构/交互文档的具体章节

---

## Coder 代码门禁 (编码完成后)

### MUST (缺一即打回)

- [ ] 所有改动在方案文档列出的范围内 (无范围蔓延)
- [ ] typecheck / lint 通过
- [ ] 自测计划中全部 case 通过
- [ ] 无 console.log / 调试代码残留
- [ ] 无硬编码密钥/凭据

### SHOULD

- [ ] 新增代码有测试覆盖
- [ ] 函数 < 50 行，文件 < 800 行

---

## Tester 产出门禁 (`docs/tester/<feature>.md`)

### MUST (缺一即打回)

- [ ] 用例矩阵覆盖: 架构文档中所有接口 + 交互文档中所有状态
- [ ] 每个用例有: 名称 + 场景 + 前置条件 + 操作步骤 + 预期 + 实际
- [ ] 涉及系统 API / 权限 / 外部服务时标注 [需人工验证]
- [ ] Bug 有严重级别 (CRITICAL/HIGH/MEDIUM/LOW) + 复现步骤
- [ ] 有回归检查清单 (改了 X，验证 Y 没坏)

### SHOULD

- [ ] E2E 可执行代码在 `docs/tester/e2e/` 下
- [ ] 性能基准对比 (如有性能要求)

---

## Architect ↔ UX Alignment 门禁

PM 在 Architect 和 UX 都完成后，做交叉比对:

| 检查项 | 方法 | 不通过处理 |
|--------|------|-----------|
| UX 依赖的接口字段都在 Architect 接口边界段中 | 逐一比对 UX 接口映射表与 Architect §3 | 缺失字段 → Architect 补 |
| UX 假设的数据结构匹配 Architect 的类型定义 | 比对类型名和字段名 | 不一致 → 成本小方改 |
| UX 的页面流转覆盖所有接口状态 | 检查 Loading/Error/Empty 是否都有 UI | 缺状态 → UX 补 |
| 没有"无主字段" | 搜索 UX 文档中未在 Architect 中定义的字段 | → 要么加，要么删 |

---

## PM 自检门禁

PM 在通知 Supervisor 验收前自查:

- [ ] 所有角色 MUST 门禁已通过
- [ ] Architect ↔ UX 一致性 alignment 已做
- [ ] 工作流状态表已更新
- [ ] `memory/session/current-state.md` 已更新
- [ ] 有阻塞项时已同步 Supervisor

---

## 门禁执行原则

1. **非生产者审核** — Coder 的方案由 Architect 审核，Coder 的代码由 Tester 验证，避免自审盲区
2. **打回带缺失项** — 不通过时必须列出具体缺失项，不能说"不行"就结束
3. **最多 3 轮** — 同一阶段打回超过 3 轮 → PM 自判: 跳过 or 换人或自审替代
4. **记录风险** — 跳过的门禁标注风险: "缺少 X 的正式审核，PM 已自审替代"

---

## 相关文件

- PM 判级与调度 → 见 `references/workflow.md`
- Worker 定义与 Dispatch → 见 `references/workers.md`
- 打回与冲突仲裁 → 见 `references/collaboration.md`
