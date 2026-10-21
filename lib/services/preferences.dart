import 'package:shared_preferences/shared_preferences.dart';

/// Small conveniences remembered on the phone. Nothing here is care data;
/// that all lives in the database.
class Preferences {
  static const _kGivenBy = 'last_given_by';
  static const _kClock24 = 'use_24_hour_clock';
  static const _kLanguage = 'language';
  static const _kLanguageInUse = 'language_in_use';

  /// Who gave the last dose logged on this phone, offered next time so a
  /// caregiver doesn't retype their own name.
  static Future<String?> lastGivenBy() async =>
      (await SharedPreferences.getInstance()).getString(_kGivenBy);

  static Future<void> setLastGivenBy(String? name) async {
    final prefs = await SharedPreferences.getInstance();
    if (name == null || name.trim().isEmpty) {
      await prefs.remove(_kGivenBy);
    } else {
      await prefs.setString(_kGivenBy, name.trim());
    }
  }

  /// The phone's 24-hour setting as last seen by the app, for the reminder
  /// isolate, which has no view to ask. Null until the app has started once.
  static Future<bool?> use24HourClock() async =>
      (await SharedPreferences.getInstance()).getBool(_kClock24);

  static Future<void> setUse24HourClock(bool value) async =>
      (await SharedPreferences.getInstance()).setBool(_kClock24, value);

  /// The language picked in Settings, or null to follow the phone.
  static Future<String?> language() async =>
      (await SharedPreferences.getInstance()).getString(_kLanguage);

  static Future<void> setLanguage(String? code) async {
    final prefs = await SharedPreferences.getInstance();
    if (code == null) {
      await prefs.remove(_kLanguage);
    } else {
      await prefs.setString(_kLanguage, code);
    }
  }

  /// The language the app last showed, for the reminder isolate, which
  /// words reminders the same way. Null until the app has started once.
  static Future<String?> languageInUse() async =>
      (await SharedPreferences.getInstance()).getString(_kLanguageInUse);

  static Future<void> setLanguageInUse(String code) async =>
      (await SharedPreferences.getInstance()).setString(_kLanguageInUse, code);

  /// For "Delete all data".
  static Future<void> clear() async =>
      (await SharedPreferences.getInstance()).clear();
}
