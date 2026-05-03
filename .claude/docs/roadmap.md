# Roadmap — Training Tracker

Каждый этап = один значимый коммит (по требованию ТЗ).

## Этап 0 — Подготовка
- [ ] Создать проект Supabase, получить `url` и `anon key`.
- [ ] SQL: создать таблицы `workouts`, `exercises`, `sets` + RLS политики.
- [ ] Подключить пакеты: `flutter_bloc`, `go_router`, `supabase_flutter`, `equatable`.
- [ ] Создать структуру папок `lib/core`, `lib/features`, `lib/shared`.

## Этап 1 — Bootstrap и тема
- [ ] `main.dart` — инициализация Supabase.
- [ ] `app.dart` — MaterialApp.router + тема.
- [ ] `core/router/app_router.dart` — заглушка маршрутов.

**Commit:** `chore: bootstrap project, theme, router skeleton`

## Этап 2 — Аутентификация
- [ ] Domain: `AppUser`, `AuthRepository` (interface).
- [ ] Data: `AuthRepositoryImpl` через Supabase.
- [ ] BLoC: `AuthBloc` (events: SignIn, SignUp, SignOut; states: Authenticated, Unauthenticated, Loading, Error).
- [ ] UI: `AuthScreen` с формой и валидацией (email/password).
- [ ] Router: редирект на /auth если нет сессии.

**Commit:** `feat: supabase auth (sign in / sign up)`

## Этап 3 — Список тренировок
- [ ] Domain: `Workout` entity, `WorkoutsRepository`.
- [ ] Data: реализация через Supabase.
- [ ] BLoC: `WorkoutsBloc` (Load, Create, Delete).
- [ ] UI: `WorkoutsListScreen` + FAB для создания.
- [ ] Форма создания тренировки (валидация title).

**Commit:** `feat: workouts list with create/delete`

## Этап 4 — Детали тренировки + упражнения и подходы
- [ ] `Exercise`, `ExerciseSet` entities.
- [ ] `WorkoutDetailBloc`.
- [ ] UI: добавление упражнения, добавление подхода (reps/weight).

**Commit:** `feat: exercises and sets inside workout`

## Этап 5 — История
- [ ] `HistoryScreen` — список прошлых тренировок, группировка по дате.
- [ ] (Опц.) Простая статистика: всего тренировок, всего подходов.

**Commit:** `feat: history screen`

## Этап 6 — Полировка
- [ ] Loading / error состояния везде.
- [ ] Пустые состояния (empty list).
- [ ] Иконка приложения, splash.

**Commit:** `style: polish ui states and assets`

## Этап 7 — Защита
- [ ] Презентация 5–7 слайдов (problem, solution, stack, architecture, what to improve).
- [ ] Прогон демо на эмуляторе.

## Что улучшить (если будет время)
- Графики прогресса (`fl_chart`).
- Темплейты тренировок.
- Экспорт истории в CSV.
- Оффлайн-режим (кеш в Hive).
