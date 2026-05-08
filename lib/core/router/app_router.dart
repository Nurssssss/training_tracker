import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/workouts/domain/entities/workout.dart';
import '../../features/workouts/presentation/screens/workout_detail_screen.dart';
import '../../features/workouts/presentation/screens/workouts_list_screen.dart';
import 'scaffold_with_nav.dart';

class AppRoutes {
  static const splash = '/';
  static const auth = '/auth';
  static const workouts = '/workouts';
  static const history = '/history';
  static const profile = '/profile';
  static const settings = '/settings';
}

GoRouter buildRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: _BlocRefreshListenable(authBloc.stream),
    navigatorKey: _rootNavigatorKey,
    redirect: (context, state) {
      final status = authBloc.state.status;
      final loc = state.matchedLocation;

      if (loc == AppRoutes.splash) return null;

      final goingToAuth = loc == AppRoutes.auth;

      if (status == AuthStatus.unknown) return null;
      if (status == AuthStatus.unauthenticated && !goingToAuth) {
        return AppRoutes.auth;
      }
      if (status == AuthStatus.authenticated && goingToAuth) {
        return AppRoutes.workouts;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ScaffoldWithNav(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.workouts,
                builder: (context, state) => const WorkoutsListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final workout = state.extra as Workout;
                      return WorkoutDetailScreen(workout: workout);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.history,
              builder: (context, state) => const HistoryScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (context, state) => const SettingsScreen(),
            ),
          ]),
        ],
      ),
    ],
  );
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class _BlocRefreshListenable extends ChangeNotifier {
  _BlocRefreshListenable(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
