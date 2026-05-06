import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';

class AddSetDialog extends StatefulWidget {
  const AddSetDialog({super.key});

  @override
  State<AddSetDialog> createState() => _AddSetDialogState();
}

class _AddSetDialogState extends State<AddSetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _repsCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  @override
  void dispose() {
    _repsCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop({
      'reps': int.parse(_repsCtrl.text.trim()),
      'weight':
          double.parse(_weightCtrl.text.trim().replaceAll(',', '.')),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Новый подход'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _repsCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Повторения',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  Validators.positiveInt(v, label: 'Повторения'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _weightCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Вес, кг',
                border: OutlineInputBorder(),
              ),
              validator: (v) => Validators.nonNegativeNumber(v, label: 'Вес'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Добавить')),
      ],
    );
  }
}
