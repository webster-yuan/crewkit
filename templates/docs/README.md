# docs — 项目文档

> crewkit 工作流产出目录。每个 Worker 按角色分目录输出结构化文档。

## 目录说明

```
docs/
├── README.md                    # 本文件
├── ba/                          # BA: 需求文档
│   └── <feature>.md             #   需求概述、用户故事、验收标准、边界条件
├── architect/                   # Architect: 架构文档
│   └── <module>.md              #   候选方案、接口设计、数据模型、影响分析
├── ux/                          # UX: 交互文档
│   └── <feature>-journey.md     #   页面流转、状态矩阵、交互时序
├── coder/                       # Coder: 实现方案
│   └── <feature>.md             #   改动范围、实现步骤、自测计划
├── tester/                      # Tester: 测试报告
│   ├── <feature>.md             #   用例矩阵、Bug 清单、回归检查
│   └── e2e/                     #   E2E 测试代码
├── pm/                          # PM: 调度与通知
│   ├── from-ba/                 #   BA 完成通知
│   ├── from-architect/          #   Architect 完成通知
│   ├── from-ux/                 #   UX 完成通知
│   ├── from-coder/              #   Coder 完成通知
│   └── from-tester/             #   Tester 完成通知
└── roles/                       # 技术角色定义 (按需)
    ├── frontend.md
    ├── backend.md
    └── data.md
```

## 文档命名约定

- BA/UX/Coder/Tester: 用 feature 名，如 `user-feedback.md`
- Architect: 用 module 名，如 `audit-system.md`
- PM 通知: 用日期前缀，如 `2026-06-09-done.md`

## 文档生命周期

1. **草稿** — Worker 产出初稿，状态标注"草稿"
2. **已审核** — PM 通过门禁检查，状态改为"已审核"或"已确认"
3. **归档** — 功能上线后保留，用于后续参考和新人 onboarding

## 阅读建议

- **新成员**: 从 `docs/architect/` 开始了解系统设计
- **接手需求**: 从 `docs/ba/<feature>.md` 开始理解上下文
- **排查问题**: 查看 `docs/tester/` 中的回归检查清单
- **了解全局**: 浏览 `docs/pm/from-*/` 中的完成通知了解进度
