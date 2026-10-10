import 'package:shared_preferences/shared_preferences.dart';

/// Small conveniences remembered on the phone. Nothing here is care data;
/// that all lives in the database.
class Preferences {
  static const _kPatient = 'last_patient_id';
  static const _kGivenBy = 'last_given_by';
  static const _kClock24 = 'use_24_hour_clock';

  /// Whose medications were on screen last.
  static Future<String?> lastPatient() async =>
      (await SharedPreferences.getInstance()).getString(_kPatient);

  static Future<void> setLastPatient(String id) async =>
      (await SharedPreferences.getInstance()).setString(_kPatient, id);

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

  /// For "Delete all data".
  static Future<void> clear() async =>
      (await SharedPreferences.getInstance()).clear();
}
