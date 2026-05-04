import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/auth_repository.dart';
import '../../domain/entities/app_user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repo) : super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthSignOutRequested>(_onSignOut);
  }

  final AuthRepository _repo;
  StreamSubscription<AppUser?>? _sub;

  void _onStarted(AuthStarted e, Emitter<AuthState> emit) {
    final user = _repo.currentUser;
    emit(state.copyWith(
      status: user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      user: user,
      clearUser: user == null,
    ));
    _sub?.cancel();
    _sub = _repo.authStateChanges().listen((u) => add(AuthUserChanged(u)));
  }

  void _onUserChanged(AuthUserChanged e, Emitter<AuthState> emit) {
    emit(state.copyWith(
      status: e.user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      user: e.user,
      clearUser: e.user == null,
      clearError: true,
    ));
  }

  Future<void> _onSignIn(AuthSignInRequested e, Emitter<AuthState> emit) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final user = await _repo.signIn(email: e.email, password: e.password);
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isSubmitting: false,
      ));
    } on Failure catch (f) {
      emit(state.copyWith(isSubmitting: false, errorMessage: f.message));
    }
  }

  Future<void> _onSignUp(AuthSignUpRequested e, Emitter<AuthState> emit) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final user = await _repo.signUp(email: e.email, password: e.password);
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isSubmitting: false,
      ));
    } on Failure catch (f) {
      emit(state.copyWith(isSubmitting: false, errorMessage: f.message));
    }
  }

  Future<void> _onSignOut(AuthSignOutRequested e, Emitter<AuthState> emit) async {
    try {
      await _repo.signOut();
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        clearError: true,
      ));
    } on Failure catch (f) {
      emit(state.copyWith(errorMessage: f.message));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
