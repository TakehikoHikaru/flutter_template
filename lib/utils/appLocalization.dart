import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final String locale;

  static Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale);
  Future<void> load() async {
    String jsonString = await rootBundle.loadString('assets/i18n/$locale.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings =
        jsonMap.map((key, value) => MapEntry(key, value.toString()));
  }

  static String translate(String key, {Map<String, String>? replacements}) {
    String translation = _localizedStrings[key] ?? key;

    // Replace placeholders with values
    if (replacements != null) {
      replacements.forEach((placeholder, value) {
        translation = translation.replaceAll('{$placeholder}', value);
      });
    }

    return translation;
  }

  static Future<String> translateFromLanguage(String key, String locale,
      {List<Map<String, String>>? replacements}) async {
    String jsonString = await rootBundle.loadString('assets/i18n/$locale.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    var _localLocalizedStrings =
        jsonMap.map((key, value) => MapEntry(key, value.toString()));

    String translation = _localizedStrings[key] ?? key;

    // Replace placeholders with values
    if (replacements != null) {
      for (var r in replacements) {
        r.forEach((placeholder, value) {
          translation = translation.replaceAll('{$placeholder}', value);
        });
      }
    }

    return translation;
  }

  static AppLocalizations of(String locale) => AppLocalizations(locale);
}
