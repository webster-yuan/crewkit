# docs

> crewkit 所有角色产出文档的根目录。

## 目录按角色

| 目录 | 角色 | 产出内容 |
|------|------|---------|
| `ba/` | BA (需求分析师) | 需求文档 + 原型 (`prototype/`) |
| `architect/` | Architect (架构师) | 架构设计 + 技术调研 (`research/`) + 审核意见 (`review/`) |
| `ux/` | UX Designer (交互设计师) | 用户交互文档 |
| `coder/` | Coder (编码者) | 修改方案 + 调试记录 (`debug/`) |
| `tester/` | Tester (测试者) | 测试方案 + 测试报告 + E2E 代码 (`e2e/`) |
| `pm/` | PM (项目主管) | 进度报表 + 技能分配 + 设计对齐 + Worker 反馈收件 |
| `roles/` | Tech Roles (技术角色库) | 技术开发角色定义模板 (前端/后端/全栈/数据/算法/SDK) |

## 流程与文档关系

```
Supervisor 口头需求
  → ba/<feature>.md                    (BA)
  → architect/<module>.md              (Architect)
  → ux/<module>-journey.md             (UX Designer)
  → coder/<feature>.md                 (Coder 修改方案)
  → tester/<feature>.md                (Tester 测试报告)
```

## 入口

- 下一步该做什么 → 看 [CLAUDE.md](../CLAUDE.md)「工作流状态」表
- 变更走什么流程 → [CLAUDE.md](../CLAUDE.md)「变更分级」表
- 各角色该加载哪些 skills → `pm/skill-allocation.md`
- 项目进度报表 → `pm/progress-report.md`
