import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';

class AddExerciseSheet extends StatefulWidget {
  const AddExerciseSheet({super.key});

  @override
  State<AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends State<AddExerciseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _muscleCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _muscleCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop({
      'name': _nameCtrl.text.trim(),
      'muscleGroup': _muscleCtrl.text.trim().isEmpty
          ? null
          : _muscleCtrl.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Новое упражнение',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Название',
                  hintText: 'Например: Жим лёжа',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => Validators.notEmpty(v, label: 'Название'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _muscleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Группа мышц (необязательно)',
                  hintText: 'Грудь, спина, ноги…',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Добавить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
