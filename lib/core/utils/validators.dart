class Validators {
  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Введите email';
    if (!_emailRegex.hasMatch(v)) return 'Некорректный email';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Введите пароль';
    if (v.length < 6) return 'Минимум 6 символов';
    return null;
  }

  static String? notEmpty(String? value, {String label = 'Поле'}) {
    if ((value ?? '').trim().isEmpty) return '$label не может быть пустым';
    return null;
  }

  static String? positiveInt(String? value, {String label = 'Число'}) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return '$label обязательно';
    final n = int.tryParse(v);
    if (n == null || n <= 0) return '$label должно быть > 0';
    return null;
  }

  static String? nonNegativeNumber(String? value, {String label = 'Число'}) {
    final v = (value ?? '').trim().replaceAll(',', '.');
    if (v.isEmpty) return '$label обязательно';
    final n = double.tryParse(v);
    if (n == null || n < 0) return '$label не может быть отрицательным';
    return null;
  }
}
