import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  static const _keyTheme = 'settings.theme_mode';
  static const _keyUnit = 'settings.weight_unit';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIdx = prefs.getInt(_keyTheme) ?? ThemeMode.system.index;
    final unitName = prefs.getString(_keyUnit) ?? WeightUnit.kg.name;
    emit(state.copyWith(
      themeMode: ThemeMode.values[themeIdx],
      weightUnit: WeightUnit.values.firstWhere(
        (u) => u.name == unitName,
        orElse: () => WeightUnit.kg,
      ),
    ));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(state.copyWith(themeMode: mode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTheme, mode.index);
  }

  Future<void> setWeightUnit(WeightUnit unit) async {
    emit(state.copyWith(weightUnit: unit));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUnit, unit.name);
  }
}
