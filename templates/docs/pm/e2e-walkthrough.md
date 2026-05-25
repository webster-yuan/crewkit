# 端到端交互示例

> 完整的 L 级需求走一遍，展示每个角色的实际输入输出。

---

## 场景

Supervisor 说: **"我想给后台管理系统加一个操作日志功能，能看到谁在什么时间做了什么操作"**

---

## Phase 0: PM 判级

```
PM: "收到。操作日志涉及新数据表 + 新页面 + 新接口 → L 级，走完整流水线。

先确认一下范围:
- 只是查看日志，还是需要导出？
- 日志保留多久？
- 哪些操作需要被记录？"
```

---

## Phase 1: BA 需求澄清

PM dispatch BA → BA 产出 `docs/ba/operation-log.md`:

```markdown
# 操作日志功能
> 作者: BA | 日期: 2026-05-25 | 状态: 待确认

## 1. 需求概述
为后台管理系统增加操作日志，管理员可查看所有用户的操作记录。

## 2. 用户故事
| # | 角色 | 目标 | 价值 |
|---|------|------|------|
| 1 | 管理员 | 查看谁在什么时间做了什么操作 | 追溯责任、审计合规 |
| 2 | 管理员 | 按用户/时间/操作类型筛选日志 | 快速定位特定操作 |

## 3. 功能范围
### In Scope
- 操作日志列表页（分页、筛选、排序）
- 自动记录关键操作（增删改、登录、权限变更）
- 日志至少保留 90 天

### Out of Scope
- 日志导出（后续迭代）
- 操作回滚/撤销

## 4. 验收标准 (Given-When-Then)
### US-1: 查看操作日志
- Given 有操作记录, When 管理员打开日志页面, Then 看到按时间倒序的日志列表
- Given 无操作记录, When 管理员打开日志页面, Then 显示空态引导
- Given 1000+ 条记录, When 翻到第 3 页, Then 100ms 内加载完成

### US-2: 筛选日志
- Given 日志列表, When 筛选"用户=张三", Then 只显示张三的操作
- Given 日志列表, When 筛选"时间=近 7 天+操作=删除", Then 只显示匹配项

## 5. 边界条件
| 场景 | 预期行为 |
|------|---------|
| 日志过期超过 90 天 | 自动清理 |
| 并发写入 | 全部记录，不丢不重 |
| 筛选无结果 | 显示"无匹配记录" |

## 6. 未决问题
- Q1: 操作类型只有增删改查登录？需不需要"导出"操作？（答案：要加导出）
- Q2: 是否需要记录操作前后的数据变更内容？（答案：不需要）

---
## 下一棒阅读清单
| 优先级 | 文档 | 用途 |
|--------|------|------|
| 必读 | 本文件 | Architect 调研 + 架构设计 |
```

Supervisor 确认 → BA 更新 → 状态改为"已确认"

---

## Phase 2: Architect + UX 并行

**Architect** 产出架构文档，核心内容:

```
数据模型:
  CREATE TABLE operation_logs (
    id BIGSERIAL PRIMARY KEY,
    operator_id INT NOT NULL,
    operator_name VARCHAR(100),
    action_type VARCHAR(20) NOT NULL,
    target_type VARCHAR(50),
    target_id INT,
    ip VARCHAR(45),
    created_at TIMESTAMP DEFAULT NOW()
  );

API:
  GET /api/logs?page=1&size=20&user_id=&action_type=&start=&end=
  出参: { total, page, items: [{ id, operator, action, target, ip, created_at }] }

方案: AOP 中间件拦截（零侵入 vs 手动埋点，推荐 AOP）
可行性: 可行。日活 100 人 × 50 操作 = 5000 条/天，90 天 45 万条，无性能压力
```

**UX** 产出交互文档 + HTML 原型:

```
页面流转: [后台首页] → 侧栏"操作日志" → [日志列表页]
状态矩阵: 正常(表格) / Loading(骨架屏) / Empty("暂无操作记录") / Error(Toast+重试)
交互时序: 进入→默认加载最近 20 条→骨架屏→表格; 筛选→选条件→查询→结果
```

PM alignment: UX 依赖字段 vs Architect 接口边界 → 一致, PASS

---

## Phase 3: Coder 编码

Coder 方案 → Architect 审核 1 轮 → 编码 → 自测通过

```
改动: 新增 5 个文件, 未改动现有代码
- src/middleware/audit-log.ts (AOP 拦截)
- src/modules/operation-log/ (查询服务)
- src/pages/OperationLog/ (列表页)
- src/shared/types/operation-log.ts (类型)
```

---

## Phase 4: Tester 测试

```
6 个用例全部通过:
- 列表加载 ✅
- 空态 ✅
- 分页 ✅
- 筛选 ✅
- 记录写入 ✅
- 过期清理 ✅
Bug: 无 CRITICAL/HIGH
LOW: 小屏幕下表横向溢出 (PM 已知悉)
```

---

## Phase 5: 验收

```
PM: "操作日志功能全部完成。测试通过。新增 5 文件，改动 0 现有文件。
     一个 LOW: 窄屏溢出，建议后续处理。"

Supervisor: "验收通过。溢出那个先放放。"
```

---

## 时间线

| 阶段 | 耗时 | 备注 |
|------|------|------|
| 判级 | 1 min | PM |
| BA | 12 + 3 min | 产出 + 修改 |
| Architect ∥ UX | 15 min | 并行 |
| Coder 方案 + 审核 | 10 + 3 min | — |
| Coder 编码 | 25 min | — |
| PM 自测 + Tester | 5 + 10 min | — |
| Supervisor 验收 | 5 min | — |
| **总计** | **~90 min** | — |
