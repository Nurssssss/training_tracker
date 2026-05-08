part of 'settings_cubit.dart';

enum WeightUnit { kg, lb }

extension WeightUnitX on WeightUnit {
  String get label => switch (this) {
        WeightUnit.kg => 'кг',
        WeightUnit.lb => 'фунты',
      };
}

class SettingsState extends Equatable {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.weightUnit = WeightUnit.kg,
  });

  final ThemeMode themeMode;
  final WeightUnit weightUnit;

  SettingsState copyWith({
    ThemeMode? themeMode,
    WeightUnit? weightUnit,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      weightUnit: weightUnit ?? this.weightUnit,
    );
  }

  @override
  List<Object?> get props => [themeMode, weightUnit];
}
