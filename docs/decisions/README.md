# Architecture Decision Records (ADR)

Значимые архитектурные решения фиксируются здесь. Каждый ADR описывает контекст, решение и его последствия.

## Формат

Нумерация последовательная: `NNNN-short-slug.md`.

Примеры: `0001-ddd-hexagonal-architecture.md`, `0002-literal-over-enum.md`.

## Шаблон

```markdown
# Title
Date: YYYY-MM-DD

## Context
What prompted this decision.

## Decision
What we decided and why.

## Consequences
Tradeoffs — what we gain and what we give up.
```

Каждый ADR — ~20 строк. Кратко, по существу.

## Когда создавать ADR

- Выбор технологии или фреймворка
- Изменение архитектурного паттерна
- Отказ от ранее принятого решения
- Любое решение, которое повлияет на структуру проекта
