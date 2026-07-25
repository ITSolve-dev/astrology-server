# Astrology Server — AI Agent Guide

Главный файл инструкций для AI-агентов. Читай перед любым действием.

## Проект

Модульный монолит на FastAPI + SQLAlchemy + PostgreSQL. DDD + Hexagonal Architecture.

## Карта документации

| Что | Где |
|-----|-----|
| Архитектура, слои, модули | [`docs/architecture/`](docs/architecture/) |
| Архитектурные правила | [`docs/architecture/rules.md`](docs/architecture/rules.md) |
| Стиль кода | [`docs/styleguide.md`](docs/styleguide.md) |
| Решения (ADR) | [`docs/decisions/`](docs/decisions/) |
| Git flow, коммиты, PR | [`docs/git-flow.md`](docs/git-flow.md) |
| Тестирование | [`docs/testing.md`](docs/testing.md) |
| Навигация по docs/ | [`docs/README.md`](docs/README.md) |

## Критичные правила

- Роутер → только сервис. Сервис — оркестратор, не содержит бизнес-логики
- Доменные сущности — frozen dataclass, иммутабельность по умолчанию
- Module boundary: импорт только через `__init__.py`, `internals/` закрыт
- Literal + Values вместо Enum, Final[type] для констант, запрет magic strings
- `print()` запрещён — только `logging`
- Перед созданием нового — проверить что уже существует

## Стек и инструменты

- Python 3.14+, FastAPI, SQLAlchemy, Alembic, PostgreSQL
- uv (пакеты), ruff (линт/формат), ty (типы), pytest (тесты), prek (хуки)

## Команды

**Используй `make` команды вместо прямых вызовов `uv run ...` когда доступен Makefile.**

| Команда | Описание |
|---------|----------|
| `make install` | Установить все зависимости |
| `make install-dev` | Только dev зависимости |
| `make install-test` | Только test зависимости |
| `make install-hooks` | Установить pre-commit хуки |
| `make lint` | Ruff linter с auto-fix |
| `make format` | Ruff formatter |
| `make typecheck` | Ty type checker |
| `make check` | Все проверки (lint + format + typecheck) |
| `make server` | Dev сервер |
| `make test` | Запуск тестов |
| `make worktree-create ISSUE=N` | Создать worktree из issue (auto-derive ветки) |
| `make worktree-create BRANCH=...` | Создать worktree с явным именем ветки |
| `make worktree-cleanup` | Удалить текущий worktree и ветку |
| `make worktree-cleanup NAME=...` | Удалить конкретный worktree |
| `make pr-create` | Создать PR с автогенерацией описания из коммитов |

## Рабочий процесс

Design Doc → Implementation Plan → Реализация → Самопроверка → Human Review → PR → AI Code Review → Approval
