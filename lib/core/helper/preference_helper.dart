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

  static set user(UserModel? userModel) {
    if (userModel == null) {
      _prefs.remove(_keyUser);
    } else {
      _prefs.setString(_keyUser, jsonEncode(userModel.toJson()));
    }
  }

  // ─── User ID ─────────────────────────────────────────────────────────
  static const String _keyUserId = 'userId';

  static String get userId => _prefs.getString(_keyUserId) ?? '';

  static set userId(String? userId) {
    if (userId == null) {
      _prefs.remove(_keyUserId);
    } else {
      _prefs.setString(_keyUserId, userId);
    }
  }

  // ─── Biometric ────────────────────────────────────────────────────────────
  static const String _keyBiometric = 'isEnabledBiometric';

  static bool get isEnabledBiometric => _prefs.getBool(_keyBiometric) ?? false;

  static set isEnabledBiometric(bool value) =>
      _prefs.setBool(_keyBiometric, value);

  // ─── Notification ─────────────────────────────────────────────────────────
  static const String _keyNotification = 'isNotificationEnabled';

  static bool get isNotificationEnabled =>
      _prefs.getBool(_keyNotification) ?? false;

  static set isNotificationEnabled(bool value) =>
      _prefs.setBool(_keyNotification, value);

  // ─── Google User ──────────────────────────────────────────────────────────
  static const String _keyGoogleUser = 'isGoogleUser';

  static bool get isGoogleUser => _prefs.getBool(_keyGoogleUser) ?? false;

  static set isGoogleUser(bool value) => _prefs.setBool(_keyGoogleUser, value);

  // ─── FCM Token ──────────────────────────────────────────────────────────
  static const String _keyFCMToken = 'fcmToken';

  static String get fcmToken => _prefs.getString(_keyFCMToken) ?? '';

  static set fcmToken(String value) => _prefs.setString(_keyFCMToken, value);

  // ─── Daily Reminder ──────────────────────────────────────────────────────────
  static const String _dailyReminderKey = 'daily_reminder_enabled';

  static bool get isDailyReminderEnabled =>
      _prefs.getBool(_dailyReminderKey) ?? true;

  static set isDailyReminderEnabled(bool value) =>
      _prefs.setBool(_dailyReminderKey, value);

  // ─── Clear All ────────────────────────────────────────────────────────────
  static Future<void> clearAll() async => await _prefs.clear();
}
