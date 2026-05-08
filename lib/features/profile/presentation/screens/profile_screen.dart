import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../workouts/domain/workouts_repository.dart';
import '../bloc/profile_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (context) =>
          ProfileCubit(context.read<WorkoutsRepository>())..load(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  Future<void> _editName(BuildContext context, String? current) async {
    final ctrl = TextEditingController(text: current ?? '');
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Имя пользователя'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Имя',
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if ((v ?? '').trim().isEmpty) return 'Введите имя';
              if ((v ?? '').trim().length > 40) return 'Слишком длинно';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, ctrl.text.trim());
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    if (result != null && context.mounted) {
      context.read<AuthBloc>().add(AuthDisplayNameUpdateRequested(result));
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<AuthBloc>().add(const AuthSignOutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final user = authState.user;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final initials = (user.displayName?.trim().isNotEmpty == true
                  ? user.displayName!
                  : user.email)
              .characters
              .first
              .toUpperCase();
          return RefreshIndicator(
            onRefresh: () => context.read<ProfileCubit>().load(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      initials,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    user.displayName ?? 'Без имени',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    user.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: const Text('Имя пользователя'),
                    subtitle: Text(user.displayName ?? 'Не указано'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: authState.isSubmitting
                        ? null
                        : () => _editName(context, user.displayName),
                  ),
                ),
                const SizedBox(height: 16),
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                    final stats = state.stats;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            _StatTile(
                              label: 'Тренировок',
                              value: stats?.workouts.toString() ?? '—',
                            ),
                            _buildDivider(theme),
                            _StatTile(
                              label: 'Упражнений',
                              value: stats?.exercises.toString() ?? '—',
                            ),
                            _buildDivider(theme),
                            _StatTile(
                              label: 'Подходов',
                              value: stats?.sets.toString() ?? '—',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                FilledButton.tonalIcon(
                  onPressed: () => _confirmLogout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Выйти из аккаунта'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Widget _buildDivider(ThemeData theme) => Container(
      width: 1,
      height: 36,
      color: theme.colorScheme.outlineVariant,
    );

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
