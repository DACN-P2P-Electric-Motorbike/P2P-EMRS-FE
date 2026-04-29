import 'package:flutter/material.dart';

import '../constants/api_constants.dart';
import '../storage/storage_service.dart';

class AppPreferencesController extends ChangeNotifier {
  final StorageService _storageService;

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('vi');
  bool _dataSaverEnabled = false;

  AppPreferencesController(this._storageService);

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get dataSaverEnabled => _dataSaverEnabled;

  Future<void> load() async {
    final storedTheme = await _storageService.getString(StorageKeys.themeMode);
    final storedLocale = await _storageService.getString(
      StorageKeys.localeCode,
    );
    final storedDataSaver = await _storageService.getBool(
      StorageKeys.dataSaverEnabled,
    );

    _themeMode = _themeModeFromString(storedTheme);
    _locale = Locale(storedLocale == 'en' ? 'en' : 'vi');
    _dataSaverEnabled = storedDataSaver;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await _storageService.saveString(StorageKeys.themeMode, mode.name);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    final languageCode = locale.languageCode == 'en' ? 'en' : 'vi';
    if (_locale.languageCode == languageCode) return;
    _locale = Locale(languageCode);
    await _storageService.saveString(StorageKeys.localeCode, languageCode);
    notifyListeners();
  }

  Future<void> setDataSaverEnabled(bool enabled) async {
    if (_dataSaverEnabled == enabled) return;
    _dataSaverEnabled = enabled;
    await _storageService.saveBool(StorageKeys.dataSaverEnabled, enabled);
    notifyListeners();
  }

  ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

class AppPreferencesScope extends InheritedNotifier<AppPreferencesController> {
  const AppPreferencesScope({
    super.key,
    required AppPreferencesController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppPreferencesController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppPreferencesScope>();
    assert(scope != null, 'AppPreferencesScope not found in widget tree');
    return scope!.notifier!;
  }

  static AppPreferencesController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppPreferencesScope>()
        ?.notifier;
  }
}
