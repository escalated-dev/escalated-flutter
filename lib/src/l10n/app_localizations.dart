import 'package:flutter/material.dart';
import 'en.dart';
import 'es.dart';
import 'fr.dart';
import 'de.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': en,
    'es': es,
    'fr': fr,
    'de': de,
  };

  String t(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  // Convenience getters for common strings
  String get tickets => t('tickets');
  String get knowledgeBase => t('knowledge_base');
  String get settings => t('settings');
  String get login => t('login');
  String get register => t('register');
  String get logout => t('logout');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'fr', 'de'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
