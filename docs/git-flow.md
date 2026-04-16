# Git Flow

Краткое руководство по работе с Git на проекте. Полная версия — в [Notion (Engineering Docs → Git Flow)](https://www.notion.so/34408cbb9e84807baca7d7839d72dd86).

## Принципы

- Линейная история — rebase вместо merge, всегда
- Изолированная разработка — каждая задача в отдельном worktree
- Обязательный code review — прямой push в `main` запрещён
- Conventional Commits — единый формат коммитов

## Worktrees

Предпочтительный способ работы на проекте. Worktree позволяет параллельно работать над несколькими задачами без `git stash` или переключения веток — каждая задача в своей директории.

```bash
# Создать worktree с новой веткой от main
git worktree add .worktrees/<name> -b <branch> origin/main

# Удалить после мержа
git worktree remove .worktrees/<name>
```

Symlinks для `.env`, `.venv` — слинковать из основного проекта.

## Шаблоны

| Что | Шаблон |
|-----|--------|
| Ветка | `<name>/<type>/<number>-<slug>` |
| Коммит | `<type>[scope]: <description> (#<number>)` |
| PR заголовок | `[#<number>] Описание` |

**Пример ветки:** `romanbulgakov/feature/1-server-configure-base-setup`

## Типы коммитов

`feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`

## Правила коммитов

- Язык — только английский
- `type` обязателен, `scope` опционален
- `description` — с маленькой буквы, без точки
- `#issue_number` — обязателен в конце description
- `BREAKING CHANGE` — через `!` или footer

## Pull Request

- PR только на `main` (исключение — под-ветки сложных задач)
- Squash and merge — обязателен
- Минимум 1 human approve
- CI зелёный
- Ветка удаляется после мержа

## Полный цикл задачи

1. Получить задачу → `gh issue view`
2. Обновить main → `git fetch origin && git rebase origin/main main`
3. Создать worktree → `git worktree add .worktrees/<name> -b <branch> origin/main`
4. Валидация — config, актуальность, symlinks, зависимости
5. Работа + коммиты по Conventional Commits
6. Push → `git push -u origin <branch>`
7. PR → `gh pr create`
8. Review → approve → CI зелёный → squash merge
9. Очистка → `git worktree remove .worktrees/<name>`
