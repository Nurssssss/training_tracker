import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/workouts/presentation/screens/workouts_list_screen.dart';

class AppRoutes {
  static const auth = '/auth';
  static const workouts = '/workouts';
}

GoRouter buildRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: AppRoutes.workouts,
    refreshListenable: _BlocRefreshListenable(authBloc.stream),
    redirect: (context, state) {
      final status = authBloc.state.status;
      final loc = state.matchedLocation;
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
        path: AppRoutes.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.workouts,
        builder: (context, state) => const WorkoutsListScreen(),
      ),
    ],
  );
}

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
