# crewkit Demo — 操作日志功能

> 一个完整的 L 级需求演练，展示 crewkit 从需求到验收的全流程。

## 快速开始

```bash
# 1. 确保 crewkit 已安装
ls ~/.claude/skills/crewkit/

# 2. 进入 demo 项目
cd examples/demo

# 3. 初始化 crewkit
# 在 Claude Code 中运行: /crewkit:init

# 4. 提出需求
# 在 Claude Code 中说: "我想给后台管理系统加一个操作日志功能"
```

## 你会看到什么

crewkit 的 PM 会自动:

```
PM: "收到。操作日志涉及新数据表 + 新页面 + 新接口 → L 级，走完整流水线。

先确认一下范围:
- 只是查看日志，还是需要导出？
- 日志保留多久？
- 哪些操作需要被记录？"
```

然后:
1. **BA** 产出 `docs/ba/operation-log.md` — 你确认需求
2. **Architect ∥ UX** 并行设计 — 互相对齐
3. **Coder** 写方案 → Architect 审核 → 编码
4. **Tester** 独立测试 → 报告
5. **PM** 汇总 → 你最终验收

查看进度: `/crewkit:status`
查看帮助: `/crewkit:help`

## 示例产出

本目录下的 `sample-output/` 包含一次完整运行的产出文件预览:
- `sample-output/ba-operation-log.md` — BA 需求文档
- `sample-output/architect-operation-log.md` — 架构设计文档
- `sample-output/ux-operation-log-journey.md` — 交互文档
- `sample-output/coder-operation-log.md` — 实现方案
- `sample-output/tester-operation-log.md` — 测试报告
- `sample-output/current-state.md` — 会话状态追踪

## 项目结构 (初始化后)

```
demo/
├── CLAUDE.md              # crewkit 项目配置
├── docs/                   # Worker 产出目录
│   ├── ba/
│   ├── architect/
│   ├── ux/
│   ├── coder/
│   ├── tester/
│   └── pm/from-*/
├── memory/                 # 跨会话记忆
│   ├── roles/              # 各 Worker 经验积累
│   ├── session/            # 会话状态
│   └── decisions/          # 架构决策记录
└── src/                    # 你的项目代码
    └── ... (你自己的代码)
```

## 试试这些命令

```
/crewkit:help     — 查看所有命令
/crewkit:status   — 查看当前进度
/crewkit:resume   — 恢复上次会话
```

## 换个需求试试

crewkit 支持三级别:

- **S 级**: "修复登录按钮在 Safari 下不显示的 bug" → Coder 直接改 (5min)
- **M 级**: "给用户列表加个导出 CSV 的功能" → Architect + Coder + Tester (30min)
- **L 级**: "新建一个消息通知系统" → 完整 7 阶段流水线 (~90min)
