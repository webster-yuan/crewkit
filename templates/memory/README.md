# memory

> Worker 跨会话记忆持久化系统。每个 Worker 角色有专属的记忆文件，用于在多次会话间积累和复用知识。

## 设计原则

- **角色隔离**: 每个 Worker 写自己的记忆，不跨角色改写
- **追加式更新**: 新发现追加到对应章节，不覆盖历史
- **PM 只读汇总**: PM 启动新 Worker 前读取对应记忆文件，注入到 Worker 上下文
- **定期清理**: 每个记忆文件标注"知识半衰期"，过期条目由 PM 在下个会话清理

## 目录结构

```
memory/
├── README.md                        # 本文件
├── roles/                           # 各 Worker 角色的知识积累
│   ├── architect.memory.md          # 技术调研缓存、架构约束、已知限制
│   ├── ba.memory.md                 # 领域术语表、Supervisor 偏好
│   ├── ux.memory.md                 # 设计决策、组件库约定
│   ├── coder.memory.md              # 代码约定积累、踩坑记录
│   └── tester.memory.md             # 测试模式、常见回归点
├── session/
│   └── current-state.md             # 当前会话状态（谁在等什么、阻塞项）
└── decisions/                       # 架构决策记录
    └── <ADR-0001>-<title>.md
```

## 记忆写入规则

每个 Worker 完成任务后，在写 `from-<role>/done.md` 的同时，追加更新自己的记忆文件：

```markdown
## <YYYY-MM-DD> — <本次任务简述>

### 新发现
- 发现了什么约束/限制
- 学到了什么模式

### 可复用
- 本次产出的可复用部分（调研结论/代码片段/测试用例）

### 需要关注
- 潜在风险、未完事项、下次需要确认的问题
```

## PM 读取时机

- **派发 Worker 前**: 读取对应 `memory/roles/<role>.memory.md` 的最近 3 条记录，注入 prompt
- **新会话启动**: 读取 `memory/session/current-state.md` 恢复上下文
- **做同类需求**: 搜索关键词匹配的历史记忆条目
