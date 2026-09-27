import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'en.dart';
import 'es.dart';
import 'fr.dart';
import 'fr_ca.dart';
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
    Locale('fr', 'CA'),
    Locale('de'),
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': en,
    'es': es,
    'fr': fr,
    'fr_CA': frCA,
    'de': de,
  };

  /// The string for [key] in this locale.
  ///
  /// Looks in the regional table first (`fr_CA`), then the language (`fr`),
  /// then English. A key found nowhere is returned as it is, so a message the
  /// server already wrote in the user's language passes straight through.
  String t(String key) {
    final country = locale.countryCode;
    if (country != null && country.isNotEmpty) {
      final regional =
          _localizedValues['${locale.languageCode}_$country']?[key];
      if (regional != null) return regional;
    }
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  /// [t], with each `{name}` placeholder replaced from [params].
  String tf(String key, Map<String, Object> params) {
    var text = t(key);
    params.forEach((name, value) {
      text = text.replaceAll('{$name}', '$value');
    });
    return text;
  }

  /// A date in the app's locale, e.g. "Sep 27, 2026" or "27 sept. 2026".
  ///
  /// Date names come from intl, which an app's GlobalMaterialLocalizations
  /// loads for its locales. Without them only English is loaded; the date then
  /// falls back to Material's compact form rather than to English words.
  static String formatDate(BuildContext context, DateTime value) {
    final local = value.toLocal();
    try {
      return DateFormat.yMMMd(
        Localizations.localeOf(context).toString(),
      ).format(local);
    } catch (_) {
      return MaterialLocalizations.of(context).formatCompactDate(local);
    }
  }

  /// [formatDate] plus the time of day, in the locale's and the device's
  /// 12/24-hour convention.
  static String formatDateTime(BuildContext context, DateTime value) {
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(value.toLocal()),
      alwaysUse24HourFormat:
          MediaQuery.maybeOf(context)?.alwaysUse24HourFormat ?? false,
    );
    return '${formatDate(context, value)} · $time';
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
