import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/validators.dart';
import '../../../auth/domain/auth_repository.dart';
import '../bloc/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              _SectionTitle('Внешний вид'),
              _ThemeTile(themeMode: state.themeMode),
              const SizedBox(height: 16),
              _SectionTitle('Единицы измерения'),
              _UnitTile(unit: state.weightUnit),
              const SizedBox(height: 16),
              _SectionTitle('Аккаунт'),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Сменить пароль'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openChangePassword(context),
              ),
              const SizedBox(height: 16),
              _SectionTitle('О приложении'),
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Training Tracker'),
                subtitle: Text('Версия 0.1.0'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openChangePassword(BuildContext context) async {
    final repo = context.read<AuthRepository>();
    final messenger = ScaffoldMessenger.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => _ChangePasswordDialog(repo: repo, messenger: messenger),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({required this.themeMode});

  final ThemeMode themeMode;

  String _label(ThemeMode m) => switch (m) {
        ThemeMode.system => 'Системная',
        ThemeMode.light => 'Светлая',
        ThemeMode.dark => 'Тёмная',
      };

  IconData _icon(ThemeMode m) => switch (m) {
        ThemeMode.system => Icons.brightness_auto,
        ThemeMode.light => Icons.light_mode,
        ThemeMode.dark => Icons.dark_mode,
      };

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_icon(themeMode)),
      title: const Text('Тема'),
      subtitle: Text(_label(themeMode)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final picked = await showModalBottomSheet<ThemeMode>(
          context: context,
          showDragHandle: true,
          builder: (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final mode in ThemeMode.values)
                  RadioListTile<ThemeMode>(
                    value: mode,
                    groupValue: themeMode,
                    onChanged: (v) => Navigator.pop(ctx, v),
                    title: Text(_label(mode)),
                    secondary: Icon(_icon(mode)),
                  ),
              ],
            ),
          ),
        );
        if (picked != null && context.mounted) {
          context.read<SettingsCubit>().setThemeMode(picked);
        }
      },
    );
  }
}

class _UnitTile extends StatelessWidget {
  const _UnitTile({required this.unit});

  final WeightUnit unit;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.straighten),
      title: const Text('Единицы веса'),
      subtitle: Text(unit.label),
      trailing: SegmentedButton<WeightUnit>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(value: WeightUnit.kg, label: Text('кг')),
          ButtonSegment(value: WeightUnit.lb, label: Text('фунты')),
        ],
        selected: {unit},
        onSelectionChanged: (s) =>
            context.read<SettingsCubit>().setWeightUnit(s.first),
      ),
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog({
    required this.repo,
    required this.messenger,
  });

  final AuthRepository repo;
  final ScaffoldMessengerState messenger;

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await widget.repo.updatePassword(_ctrl.text);
      if (!mounted) return;
      Navigator.pop(context);
      widget.messenger.showSnackBar(
        const SnackBar(content: Text('Пароль обновлён')),
      );
    } catch (e) {
      setState(() => _submitting = false);
      widget.messenger.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Сменить пароль'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _ctrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Новый пароль',
                border: OutlineInputBorder(),
              ),
              validator: Validators.password,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Подтвердите',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v != _ctrl.text) return 'Пароли не совпадают';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Сохранить'),
        ),
      ],
    );
  }
}
