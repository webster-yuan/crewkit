# 打回与失败分级处理

> 定义 Worker 产出被驳回或流程遇阻时的分级响应。PM 按此执行，不让打回变成死循环。

---

## 打回分级

| 级别 | 定义 | 处理方式 | 时限 |
|------|------|---------|------|
| **MINOR** | 缺少 SHOULD 项，或 MUST 项的小缺失 | PM 标注缺失项 → 原 Worker 增量补充 | 同会话内 |
| **MAJOR** | MUST 项大面积缺失 | PM 标注所有缺失项 → 原 Worker 重做缺失章节 | 单次重做 |
| **FATAL** | 方向错误，需重新来 | PM 写清"为什么方向错 + 正确方向" → 重派 | 重新派发 |

---

## 各阶段打回处理

### BA 需求文档被 Supervisor 打回

```
MINOR: PM 标注问题点 → 打回 BA → BA 增量修改 → PM 再提交
MAJOR: PM 汇总缺失清单 → 打回 BA → BA 重写对应章节 → PM 再提交
FATAL: PM 重新向 Supervisor 确认意图 → 重拉 BA → 重新完整产出
```

### Architect 判定"不可行"

```
Architect 说不可行时 MUST 附带:
  1. 具体原因: 技术限制？资源不够？时间来不及？
  2. 替代路径: "做不到完整版，但能做到什么程度"
  3. 替代路径的成本和风险

PM 动作:
  1. 消化替代路径
  2. 整理成 Supervisor 能理解的选择题
  3. Supervisor 选定后 → 重新规划流程
```

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

## PM 自保规则

当流程卡在同一个 Worker 超过 3 轮打回时:

1. PM 不再打回同一个 Worker
2. PM 判断: 跳过此 Worker 继续推进？还是换一个？
3. 如果跳过 → 标注风险: "缺少 X 的正式审核，PM 已自审替代"
4. 通知 Supervisor: "X 阶段卡住了，我做了 Y 处理，风险是 Z"
