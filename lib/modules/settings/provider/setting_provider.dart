import '../../../core/import_to_export.dart';

class SettingProvider extends ChangeNotifier {
  final Ref ref;

  // ─── State ───────────────────────────────────────────────────────
  UserModel? currentUser;
  String usingSince = '';
  bool isLoading = true;
  bool notificationsEnabled = false;
  bool isNotificationLoading = false;
  bool isBiometricEnabled = false;
  String version = '1.0.0';

  final LocalAuthentication _localAuth = LocalAuthentication();

  SettingProvider(this.ref) {
    currentUser = PreferenceHelper.user;
    isBiometricEnabled = PreferenceHelper.isEnabledBiometric;
    loadUserData();
    loadVersionInfo();
  }

  // ─── User Data ────────────────────────────────────────────────────────────

  Future<void> loadUserData() async {
    final user = FirebaseHelper.currentUser;
    if (user?.uid == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final doc = await FirebaseHelper.getUserData(user!.email!);

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['uid'] = user.uid;

        final userModel = UserModel.fromJson(data);
        currentUser = userModel;
        PreferenceHelper.user = userModel;

        final Timestamp? ts = data['createdAt'];
        usingSince = ts != null
            ? 'Using since ${_monthName(ts.toDate().month)} ${ts.toDate().year}'
            : '';
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String get initials => currentUser?.name.isNotEmpty == true
      ? currentUser!.name.trim().split(' ').length > 1
            ? '${currentUser!.name.trim().split(' ')[0][0]}${currentUser!.name.trim().split(' ')[1][0]}'
                  .toUpperCase()
            : currentUser!.name.trim().split(' ')[0][0].toUpperCase()
      : 'U';

  // ─── Biometric ────────────────────────────────────────────────────────────

  Future<void> toggleBiometric(bool value) async {
    if (value) {
      // Trying to enable
      try {
        final canCheck = await _localAuth.canCheckBiometrics;
        final isDeviceSupported = await _localAuth.isDeviceSupported();

        if (!canCheck && !isDeviceSupported) {
          errorSnackbar('Biometric authentication is not supported on this device.');
          return;
        }
        isBiometricEnabled = true;
        PreferenceHelper.isEnabledBiometric = true;
      } catch (e) {
        debugPrint('Biometric Error: $e');
        errorSnackbar('Failed to authenticate.');
      }
    } else {
      isBiometricEnabled = false;
      PreferenceHelper.isEnabledBiometric = false;
    }
    notifyListeners();
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────────

  Future<void> handleSignOut() async {
    HapticFeedback.heavyImpact();
    final confirmed = await confirmationDialog(
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
      isDestructive: true,
    );
    if (confirmed) {
      signOut();
    }
  }

  void signOut() async {
    await NotificationService.disable();
    PreferenceHelper.clearAll();
    await FirebaseHelper.signOut();
    WidgetHelper.updateRemainingBudgetWidget();
    ref.read(homeProvider).currentIndex = 0;
    appRouter.pushReplacementNamed(Routes.ONBOARDING);
  }

  // ─── About ────────────────────────────────────────────────────────────────

  void showAboutAppDialog() {
    HapticFeedback.heavyImpact();
    AboutSheet.show(version);
  }

  Future<void> loadVersionInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      version = info.version;
    } catch (e) {
      debugPrint('Error loading package info: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
