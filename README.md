# Training Tracker

Учебный финальный Flutter-проект — мобильное приложение для отслеживания силовых тренировок.

## Возможности

- Регистрация и вход через Supabase Auth.
- Создание тренировок (название + заметка).
- Добавление упражнений и подходов (повторения × вес).
- История тренировок: группировка по месяцам, статистика за всё время и за 30 дней.
- Удаление тренировок, упражнений и подходов.
- Защита данных Row Level Security: каждый пользователь видит только свои тренировки.

## Стек

- **Flutter** + Material 3
- **State management:** `flutter_bloc` (BLoC + Cubit)
- **Навигация:** `go_router` с auth-guard'ом
- **Backend:** Supabase (Auth + Postgres + RLS)
- **Конфиги:** `flutter_dotenv` (`.env` для ключей Supabase)
- **Утилиты:** `equatable`

## Архитектура

```
lib/
├── main.dart              // bootstrap: dotenv → Supabase → runApp
├── app.dart               // MultiRepositoryProvider + MultiBlocProvider + MaterialApp.router
├── core/
│   ├── error/             // Failure
│   ├── router/            // GoRouter с auth-redirect
│   ├── supabase/          // SupabaseConfig (init + client)
│   ├── theme/             // светлая/тёмная темы M3
│   └── utils/             // Validators
└── features/
    ├── auth/              // data → domain → presentation
    ├── workouts/          // workouts + exercises + sets
    └── history/           // экран истории
```

Слои:

- **Presentation** (UI + BLoC/Cubit) → зависит от Domain.
- **Domain** (entities + интерфейсы репозиториев) → не зависит ни от чего.
- **Data** (реализация репозиториев + Supabase DTO) → реализует интерфейсы Domain.

