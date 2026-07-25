# Стиль кода

Правила стиля для кода проекта. Обязательны для всех — людей и AI-агентов.

## Типизация

- Строгая типизация на всём проекте — все функции, методы и переменные с аннотациями типов
- Современный синтаксис: `Type | None`, `list[str]`, `dict[str, int]`
- `Any` — избегать, допустим только при работе с внешними API без типов
- `# type: ignore` — только если нет другого решения, с комментарием причины
- Дженерики и протоколы предпочтительнее ABC и наследования (Duck Typing)

## Иммутабельность

- Доменные модели — `frozen dataclass`
- `tuple` вместо `list` где коллекция не изменяется
- `Final[type]` для константных значений

```python
@dataclass(frozen=True)
class User:
    id: UUID
    email: str
    name: str
```

## Literal + Values (не Enum)

Вместо `Enum` — `Literal` типы с frozen dataclass констант. На usage sites всегда использовать Values-класс, никогда не сравнивать с хардкод-строками.

```python
UserRole = Literal["ADMIN", "USER", "MODERATOR"]

@dataclass(frozen=True)
class UserRoleValues:
    ADMIN: Final = "ADMIN"
    USER: Final = "USER"
    MODERATOR: Final = "MODERATOR"

# Хорошо
if user.role == UserRoleValues.ADMIN: ...

# Плохо
if user.role == "ADMIN": ...
```

## Запрет magic strings и magic values

- Строковые и числовые литералы не должны появляться в коде напрямую
- `Final[type]` для констант, `Literal` для перечислений, frozen dataclass для группировки

```python
# Хорошо
RETRY_LIMIT: Final[int] = 3

# Плохо
if retries > 3: ...
```

## Explicit is Better Than Implicit

- Явные возвраты: `return None` вместо пустого `return`
- Keyword-only аргументы через `*` для функций с 3+ параметрами
- Никаких `**kwargs` без строгой необходимости

```python
# Хорошо
def create_user(*, email: str, name: str, role: UserRole) -> User: ...

# Плохо
def create_user(email, name, role): ...
```

## Параметры функций

- До 2 параметров — допустимы позиционные
- 3 и более — keyword-only через `*`
- Более 5 — сигнал к рефакторингу (выделить dataclass/config)

## Обработка ошибок

- Единая иерархия: базовый `AppError` в `common/`, модули наследуют свои исключения
- Исключения содержат контекст (код ошибки, сообщение)
- Никаких голых `except:` или `except Exception:` — всегда конкретный тип
- `try/except` не содержит бизнес-логику — только перехват и обработка

```python
# common/exceptions.py
class AppError(Exception): ...

# users/exceptions.py
class UserNotFoundError(AppError): ...
class UserAlreadyExistsError(AppError): ...
```

## Логгирование

- `print()` запрещён — использовать модуль `logging`
- Структурированные сообщения с контекстом

## Docstrings

- Google-style формат
- Обязательны для каждой функции, метода и класса
- Публичный API (router, service) — подробные, с описанием параметров и возвращаемых значений
- Внутренние функции — краткое описание в одну строку

## Переиспользование

- Перед добавлением нового — проверить что уже существует в проекте
- Предпочитать переиспользование или расширение существующего
- WET > строгий DRY — дублирование допустимо если абстракция преждевременна

## Именование

- Файлы по назначению: `users_repo.py`, `user_entity.py` (не `repository.py`, `entities.py`)
- Стандартные Python-конвенции: `snake_case` для функций/переменных, `PascalCase` для классов
