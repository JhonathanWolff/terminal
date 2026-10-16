---
name: model-routing
description: Use Opus 5.5 for plans and Haiku for simple agent tasks
---

- Plan requested: delegate planning to the `Plan` agent with `model: "opus"` (claude-opus-5-5).
- Spawning agents: simple task (search, lookup, mechanical edit, single-file change) -> `model: "haiku"` (claude-haiku-5-5). Complex tasks keep the default model.
