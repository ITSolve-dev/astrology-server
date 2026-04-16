# Структура модулей

Проект организован как модульный монолит. Каждый модуль — автономный домен.

## Структура директорий

```
astrology-server/
├── src/
│   ├── common/              # общие модули: UoW, база, конфигурация
│   ├── users/               # модуль пользователей
│   ├── ...                  # другие доменные модули
│   └── main.py              # точка входа приложения
├── tests/                   # зеркальная структура к src/
├── migrations/              # Alembic миграции
└── docs/                    # документация проекта
```

## Структура модуля (на примере `users/`)

```
src/
└── users/
    ├── __init__.py              # публичный API модуля
    ├── router.py                # FastAPI роуты → вызывает ТОЛЬКО service
    ├── schemas.py               # Pydantic request/response контракты
    ├── service.py               # класс-оркестратор, единственная точка входа
    ├── exceptions.py            # модульные исключения
    ├── types.py                 # Literal типы, type aliases, constants
    └── internals/
        ├── __init__.py
        ├── users_repo.py        # репозиторий
        ├── users_db.py          # декларативная таблица + to_domain()/to_dict()
        └── domain/
            ├── __init__.py
            ├── user_entity.py   # dataclass User
            └── role_entity.py   # dataclass Role
```

## Именование файлов

По назначению, а не по типу:

| Хорошо | Плохо |
|--------|-------|
| `users_repo.py` | `repository.py` |
| `user_entity.py` | `entities.py` |
| `users_db.py` | `models.py` |

## Публичный API модуля

- `__init__.py` — единственная точка импорта для внешних модулей
- `internals/` — скрытая реализация, прямой импорт из `internals/` другого модуля запрещён
- Межмодульное взаимодействие только через публичный API

```python
# Хорошо — импорт через публичный API
from src.users import UserService, User

# Плохо — прямой импорт из internals другого модуля
from src.users.internals.users_repo import UsersRepo
from src.users.internals.domain.user_entity import User
```
