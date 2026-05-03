# Архитектура — Training Tracker

## Слои
```
Presentation (UI)  →  widgets, screens, BLoC/Cubit
Domain (логика)    →  entities, use cases, абстрактные репозитории
Data (данные)      →  репозитории (impl), Supabase источники, DTO
```

Правило: верхний слой знает про нижний, обратно — нет.
- `Presentation` зависит от `Domain`.
- `Data` реализует интерфейсы из `Domain`.
- `Domain` ни от чего не зависит, кроме чистого Dart.

## Структура папок
```
lib/
├── main.dart                       // bootstrap, init Supabase
├── app.dart                        // MaterialApp.router + theme
├── core/
│   ├── router/app_router.dart      // GoRouter
│   ├── theme/app_theme.dart
│   └── supabase/supabase_client.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/app_user.dart
│   │   │   └── auth_repository.dart
│   │   └── presentation/
│   │       ├── bloc/auth_bloc.dart
│   │       ├── screens/auth_screen.dart
│   │       └── widgets/
│   ├── workouts/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── history/
└── shared/
    └── widgets/                    // переиспользуемые UI-компоненты
```

## Поток данных
```
UI (Screen) → Bloc (event) → UseCase / Repository → Supabase
                                ↓
UI ← Bloc (state) ← Repository ← Supabase response
```

## Supabase — таблицы
```sql
-- workouts
id            uuid pk
user_id       uuid fk auth.users
title         text
note          text
created_at    timestamptz default now()

-- exercises
id            uuid pk
workout_id    uuid fk workouts
name          text
muscle_group  text

-- sets
id            uuid pk
exercise_id   uuid fk exercises
reps          int
weight        numeric
position      int    -- порядок подхода
```
RLS: пользователь видит только свои `workouts` (и через них — упражнения и подходы).

## Ключевые пакеты
- `flutter_bloc`
- `go_router`
- `supabase_flutter`
- `equatable`
- `formz` (для валидации форм) — опционально

## Принципы
- Один BLoC на одну фичу.
- DTO в `data/` отдельно от entity в `domain/`, mapper между ними.
- Никаких прямых вызовов Supabase из UI.
- Ошибки оборачиваются в `Failure` из `domain/`.
