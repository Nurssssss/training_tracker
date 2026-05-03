# Конвенции — Training Tracker

## Правило №1 — кто пишет код
Весь код **набирает пользователь вручную**. Claude только показывает блоки кода в чате с кратким объяснением. Это учебный проект — задача прокачать скилл и честно сдать.

## Именование
- Файлы: `snake_case.dart`.
- Классы: `PascalCase`.
- Переменные/функции: `camelCase`.
- BLoC: `<Feature>Bloc`, события `<Feature>Event`, состояния `<Feature>State`.
- Repository interface — в `domain/`, реализация — в `data/` с суффиксом `Impl`.

## Структура файла
1. imports (dart → flutter → packages → project, разделять пустой строкой).
2. Класс / виджет.
3. Один публичный класс на файл (по возможности).

## State management (BLoC)
- Один Bloc на одну фичу.
- События — глаголы: `LoadWorkouts`, `CreateWorkout`.
- Состояния — существительные: `WorkoutsLoading`, `WorkoutsLoaded`, `WorkoutsError`.
- Все события и состояния extends `Equatable`.

## Формы и валидация
- Использовать `Form` + `TextFormField` + `GlobalKey<FormState>`.
- Валидаторы — отдельные функции (`validators.dart`), не инлайн.
- Минимум: непустое поле, формат email, длина пароля ≥ 6.

## Git / коммиты
- Conventional commits: `feat:`, `fix:`, `refactor:`, `chore:`, `style:`, `docs:`.
- На английском.
- Один коммит = одна значимая фича (по ТЗ).
- Пример: `feat: workouts list with create/delete`.

## Supabase
- URL и ключи — НЕ коммитить. Хранить в `--dart-define` или `.env` (через `flutter_dotenv`), `.env` в `.gitignore`.
- Все запросы — через repository, не из UI.
- RLS включена на всех таблицах.

## Импорты
- Относительные пути внутри одной фичи.
- Абсолютные (`package:training_tracker/...`) между фичами и из `core`/`shared`.

## Виджеты
- Stateless по умолчанию, Stateful — только если есть локальный state.
- Большие билдеры разбивать на отдельные виджеты, а не private методы.
- Никакой бизнес-логики в виджетах.
