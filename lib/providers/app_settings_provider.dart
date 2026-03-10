import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppSettings {
  final bool biometricEnabled;
  final bool isDarkMode;
  final bool staffMode;

  AppSettings({
    required this.biometricEnabled,
    required this.isDarkMode,
    required this.staffMode,
  });

  AppSettings copyWith({bool? biometricEnabled, bool? isDarkMode, bool? staffMode}) {
    return AppSettings(
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      staffMode: staffMode ?? this.staffMode,
    );
  }
}

final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier();
});

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(AppSettings(biometricEnabled: false, isDarkMode: false, staffMode: false)) {
    _init();
  }

  late Box _box;

  Future<void> _init() async {
    _box = Hive.box('settings');
    state = AppSettings(
      biometricEnabled: _box.get('biometricEnabled', defaultValue: false),
      isDarkMode: _box.get('isDarkMode', defaultValue: false),
      staffMode: _box.get('staffMode', defaultValue: false),
    );
  }

  Future<void> toggleBiometric(bool value) async {
    await _box.put('biometricEnabled', value);
    state = state.copyWith(biometricEnabled: value);
  }

  Future<void> toggleDarkMode(bool value) async {
    await _box.put('isDarkMode', value);
    state = state.copyWith(isDarkMode: value);
  }

  Future<void> toggleStaffMode(bool value) async {
    await _box.put('staffMode', value);
    state = state.copyWith(staffMode: value);
  }
}
