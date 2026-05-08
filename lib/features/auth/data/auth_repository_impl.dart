import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/failure.dart';
import '../../../core/supabase/supabase_client.dart';
import '../domain/auth_repository.dart';
import '../domain/entities/app_user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  AppUser? _toAppUser(User? user) {
    if (user == null) return null;
    final meta = user.userMetadata;
    final name = (meta?['display_name'] as String?)?.trim();
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      displayName: (name == null || name.isEmpty) ? null : name,
    );
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

  @override
  Future<AppUser> updateDisplayName(String displayName) async {
    try {
      final res = await _client.auth.updateUser(
        UserAttributes(data: {'display_name': displayName}),
      );
      final user = _toAppUser(res.user);
      if (user == null) throw const Failure('Не удалось обновить профиль');
      return user;
    } on AuthException catch (e) {
      throw Failure(e.message);
    } catch (_) {
      throw const Failure('Что-то пошло не так');
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw Failure(e.message);
    } catch (_) {
      throw const Failure('Не удалось сменить пароль');
    }
  }
}
