import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final authSettingsProvider = StateNotifierProvider<AuthSettingsNotifier, bool>((ref) {
  return AuthSettingsNotifier();
});

class AuthSettingsNotifier extends StateNotifier<bool> {
  AuthSettingsNotifier() : super(false) {
    _init();
  }

  late Box _box;

  Future<void> _init() async {
    _box = await Hive.openBox('settings');
    state = _box.get('biometricEnabled', defaultValue: false);
  }

  Future<void> toggleBiometric(bool value) async {
    await _box.put('biometricEnabled', value);
    state = value;
  }
}
