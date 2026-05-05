import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_repository_impl.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/workouts/data/workouts_repository_impl.dart';
import 'features/workouts/domain/workouts_repository.dart';
import 'features/workouts/presentation/bloc/workouts_bloc.dart';

class TrainingTrackerApp extends StatelessWidget {
  const TrainingTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(),
        ),
        RepositoryProvider<WorkoutsRepository>(
          create: (_) => WorkoutsRepositoryImpl(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(context.read<AuthRepository>())
              ..add(const AuthStarted()),
          ),
          BlocProvider<WorkoutsBloc>(
            create: (context) =>
                WorkoutsBloc(context.read<WorkoutsRepository>()),
          ),
        ],
        child: const _AppView(),
      ),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  late final _router = buildRouter(context.read<AuthBloc>());

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Training Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
