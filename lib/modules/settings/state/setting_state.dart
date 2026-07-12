import 'package:budgetly/core/import_to_export.dart';

class SettingState {
  final UserModel? currentUser;
  final String usingSince;
  final bool isBiometricEnabled;
  final String version;
  final bool notificationsEnabled;

  // Pre-computed fields
  final String initials;

  SettingState({
    required this.currentUser,
    required this.usingSince,
    required this.isBiometricEnabled,
    required this.version,
    required this.notificationsEnabled,
  }) : initials = _computeInitials(currentUser);

  static String _computeInitials(UserModel? currentUser) {
    if (currentUser == null || currentUser.name.isEmpty) return 'U';
    final name = currentUser.name.trim();
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
