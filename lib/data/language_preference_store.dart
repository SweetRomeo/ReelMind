import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';

class LanguagePreferenceStore {
  static const _key = 'reelmind.language';
  final _preferences = SharedPreferencesAsync();

  Future<Locale?> load() async {
    final preferences = await _preferences.getAll(allowList: {_key});
    final code = preferences[_key];
    return AppLocalizations.supportedLocales
        .where((locale) => locale.languageCode == code)
        .firstOrNull;
  }

  Future<void> save(Locale? locale) {
    if (locale == null || !AppLocalizations.delegate.isSupported(locale)) {
      return _preferences.remove(_key);
    }
    return _preferences.setString(_key, locale.languageCode);
  }
}
