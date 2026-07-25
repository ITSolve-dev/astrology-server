# Astrology Server

REST API сервер для астрологических сервисов. Модульный монолит на FastAPI.

## Стек

- **Python 3.14+**, **FastAPI**, **SQLAlchemy**, **Alembic**
- **PostgreSQL** (Supabase)
- **uv** — менеджер пакетов, **ruff** — линтер/форматтер, **ty** — тайп-чекер, **pytest** — тесты

## Установка

```bash
git clone git@github.com:ITSolve-dev/astrology-server.git
cd astrology-server

make install        # установить все зависимости
make install-hooks  # установить pre-commit хуки
```

Требуется [uv](https://docs.astral.sh/uv/).

## Разработка

```bash
make server         # запуск dev сервера
make check          # все проверки (lint + format + typecheck)
make test           # запуск тестов
```

Все доступные команды — `make help`:

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
| `make worktree-create ISSUE=N` | Создать worktree из GitHub issue |
| `make worktree-create BRANCH=...` | Создать worktree с явной веткой |
| `make worktree-cleanup` | Удалить текущий worktree |
| `make pr-create` | Создать PR (описание из коммитов) |

## Структура проекта

```
src/              # исходный код приложения
├── common/       # общие модули (UoW, конфигурация, базовые классы)
└── <module>/     # доменные модули (users, billing, ...)
tests/            # тесты (зеркальная структура к src/)
migrations/       # Alembic миграции
docs/             # документация проекта
```

## Документация

- [`docs/`](docs/) — полная документация проекта (архитектура, стиль кода, решения)
- [`CLAUDE.md`](CLAUDE.md) — инструкции для AI-агентов (карта проекта)

## AI-агенты

Разработка ведётся в связке с AI-агентами. Точка входа для агентов — [`CLAUDE.md`](CLAUDE.md).
