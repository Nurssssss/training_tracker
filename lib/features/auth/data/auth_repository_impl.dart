import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/failure.dart';
import '../../../core/supabase/supabase_client.dart';
import '../domain/auth_repository.dart';
import '../domain/entities/app_user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  AppUser? _toAppUser(User? user) {
    if (user == null) return null;
    return AppUser(id: user.id, email: user.email ?? '');
  }

  @override
  AppUser? get currentUser => _toAppUser(_client.auth.currentUser);

  @override
  Stream<AppUser?> authStateChanges() {
    return _client.auth.onAuthStateChange.map(
      (event) => _toAppUser(event.session?.user),
    );
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = _toAppUser(res.user);
      if (user == null) {
        throw const Failure('Не удалось войти. Попробуйте ещё раз.');
      }
      return user;
    } on AuthException catch (e) {
      throw Failure(e.message);
    } catch (_) {
      throw const Failure('Что-то пошло не так. Проверьте подключение.');
    }
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
      );
      final user = _toAppUser(res.user);
      if (user == null) {
        throw const Failure('Не удалось создать аккаунт.');
      }
      return user;
    } on AuthException catch (e) {
      throw Failure(e.message);
    } catch (_) {
      throw const Failure('Что-то пошло не так. Проверьте подключение.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw Failure(e.message);
    }
  }
}
