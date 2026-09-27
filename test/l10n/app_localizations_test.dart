import 'package:dio/dio.dart';
import 'package:escalated/src/l10n/app_localizations.dart';
import 'package:escalated/src/l10n/de.dart';
import 'package:escalated/src/l10n/en.dart';
import 'package:escalated/src/l10n/es.dart';
import 'package:escalated/src/l10n/fr.dart';
import 'package:escalated/src/l10n/fr_ca.dart';
import 'package:escalated/src/providers/error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLocalizations.t', () {
    test('uses the language table', () {
      final l10n = AppLocalizations(const Locale('fr'));
      expect(
        l10n.t('failed_to_load_tickets'),
        'Impossible de charger les tickets.',
      );
    });

    test('prefers the regional table, then falls back to the language', () {
      final l10n = AppLocalizations(const Locale('fr', 'CA'));
      expect(l10n.t('email'), 'Courriel');
      // Not in fr_CA, so from fr rather than English.
      expect(
        l10n.t('failed_to_load_tickets'),
        'Impossible de charger les tickets.',
      );
    });

    test('falls back to English for an unsupported language', () {
      final l10n = AppLocalizations(const Locale('pt'));
      expect(l10n.t('failed_to_load_tickets'), 'Failed to load tickets.');
    });

    test('passes text that is not a key through unchanged', () {
      final l10n = AppLocalizations(const Locale('fr'));
      expect(
        l10n.t('Le ticket est introuvable.'),
        'Le ticket est introuvable.',
      );
    });

    test('tf fills placeholders', () {
      final l10n = AppLocalizations(const Locale('es'));
      expect(
        l10n.tf('field_required', {'field': l10n.t('subject')}),
        'Asunto es obligatorio',
      );
    });

    test('supports fr_CA alongside fr, es and en', () {
      expect(
        AppLocalizations.supportedLocales,
        containsAll(const [
          Locale('en'),
          Locale('fr'),
          Locale('fr', 'CA'),
          Locale('es'),
        ]),
      );
      expect(
        AppLocalizations.delegate.isSupported(const Locale('fr', 'CA')),
        isTrue,
      );
    });
  });

  group('translation tables', () {
    for (final entry in {'fr': fr, 'es': es, 'de': de}.entries) {
      test('${entry.key} has every English key', () {
        final missing = en.keys.where((k) => !entry.value.containsKey(k));
        expect(missing, isEmpty);
      });
    }

    test('fr_CA only overrides keys that exist', () {
      expect(frCA.keys.where((k) => !en.containsKey(k)), isEmpty);
    });

    // UI copy is sentence case: only the first word of each sentence is
    // capitalised, plus acronyms such as SLA. German is left out because its
    // nouns are capitalised by grammar.
    bool startsUpper(String word) =>
        word.isNotEmpty &&
        word[0] != word[0].toLowerCase() &&
        word != word.toUpperCase();

    final sentenceCase = {'en': en, 'fr': fr, 'fr_CA': frCA, 'es': es};
    for (final entry in sentenceCase.entries) {
      test('${entry.key} uses sentence case', () {
        final offenders = <String>[];
        entry.value.forEach((key, value) {
          final sentences = value.split(RegExp(r'(?<=[.!?])\s+'));
          final titleCased = sentences.any(
            (sentence) =>
                sentence.split(RegExp("[\\s'’]+")).skip(1).any(startsUpper),
          );
          if (titleCased) offenders.add('$key: $value');
        });
        expect(offenders, isEmpty);
      });
    }

    test('keeps the strings hosts show most in sentence case', () {
      expect(
        AppLocalizations(const Locale('en')).t('new_ticket'),
        'New ticket',
      );
      expect(
        AppLocalizations(const Locale('fr')).t('attachments'),
        'Pièces jointes',
      );
      expect(
        AppLocalizations(const Locale('fr', 'CA')).t('create_ticket'),
        'Créer un ticket',
      );
      expect(
        AppLocalizations(const Locale('de')).t('not_helpful'),
        'Nicht hilfreich',
      );
    });
  });

  group('serverMessageOr', () {
    DioException failure({int? status, Object? data}) {
      final options = RequestOptions(path: '/tickets');
      return DioException(
        requestOptions: options,
        response: status == null
            ? null
            : Response(requestOptions: options, statusCode: status, data: data),
      );
    }

    test('keeps the message of a request the server refused', () {
      expect(
        serverMessageOr(
          failure(status: 422, data: {'message': 'Sujet requis.'}),
          'k',
        ),
        'Sujet requis.',
      );
    });

    test('uses the key when there was no response', () {
      expect(
        serverMessageOr(failure(), 'failed_to_load_tickets'),
        'failed_to_load_tickets',
      );
    });

    test('uses the key for a server fault, whatever it said', () {
      expect(
        serverMessageOr(
          failure(status: 500, data: {'message': 'Server Error'}),
          'k',
        ),
        'k',
      );
    });

    test('uses the key when the body is not a JSON object', () {
      expect(serverMessageOr(failure(status: 404, data: '<html>'), 'k'), 'k');
    });
  });
}
