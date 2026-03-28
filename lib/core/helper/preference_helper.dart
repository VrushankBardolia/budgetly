import 'package:budgetly/core/import_to_export.dart';

class PreferenceHelper {
  static late SharedPreferences _prefs;

  /// Call this in `main()` before `runApp()`
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ─── Current User ─────────────────────────────────────────────────────────
  static const String _keyUser = 'currentUser';

  static UserModel? get user {
    final userJson = _prefs.getString(_keyUser);
    if (userJson != null) {
      try {
        return UserModel.fromJson(jsonDecode(userJson));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<void> setUser(UserModel? userModel) async {
    if (userModel == null) {
      await _prefs.remove(_keyUser);
    } else {
      await _prefs.setString(_keyUser, jsonEncode(userModel.toJson()));
    }
  }

  // ─── Biometric ────────────────────────────────────────────────────────────
  static const String _keyBiometric = 'isEnabledBiometric';

  static bool get isEnabledBiometric {
    return _prefs.getBool(_keyBiometric) ?? false;
  }

  static Future<void> setEnabledBiometric(bool value) async {
    await _prefs.setBool(_keyBiometric, value);
  }

  // ─── Notification ─────────────────────────────────────────────────────────
  static const String _keyNotification = 'isNotificationEnabled';

  static bool get isNotificationEnabled {
    return _prefs.getBool(_keyNotification) ?? false;
  }

  static Future<void> setNotificationEnabled(bool value) async {
    await _prefs.setBool(_keyNotification, value);
  }

  // ─── Google User ──────────────────────────────────────────────────────────
  static const String _keyGoogleUser = 'isGoogleUser';

  static bool get isGoogleUser {
    return _prefs.getBool(_keyGoogleUser) ?? false;
  }

  static Future<void> setGoogleUser(bool value) async {
    await _prefs.setBool(_keyGoogleUser, value);
  }

  // ─── FCM Token ──────────────────────────────────────────────────────────
  static const String _keyFCMToken = 'fcmToken';

  static String get fcmToken {
    return _prefs.getString(_keyFCMToken) ?? '';
  }

  static Future<void> setFCMToken(String value) async {
    await _prefs.setString(_keyFCMToken, value);
  }

  // ─── Daily Reminder ──────────────────────────────────────────────────────────
  static const String _dailyReminderKey = 'daily_reminder_enabled';

  static bool get isDailyReminderEnabled => _prefs.getBool(_dailyReminderKey) ?? true;

  static Future<void> setDailyReminderEnabled(bool value) async => await _prefs.setBool(_dailyReminderKey, value);

  // ─── Clear All ────────────────────────────────────────────────────────────
  static Future<void> clearAll() async => await _prefs.clear();
}
