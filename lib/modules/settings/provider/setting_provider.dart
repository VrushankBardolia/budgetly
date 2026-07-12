import 'package:budgetly/core/import_to_export.dart';

// ─── Asynchronous Data Providers ─────────────────────────────────────────────

/// Fetches and caches the current logged-in user model from Firestore.
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final user = FirebaseHelper.currentUser;
  if (user?.uid == null) {
    return PreferenceHelper.user;
  }

  try {
    final repo = ref.watch(userRepositoryProvider);
    final userModel = await repo.getUserData(user!.email!);

    if (userModel != null) {
      PreferenceHelper.user = userModel;
      return userModel;
    }
  } catch (e) {
    debugPrint('Error loading user data: $e');
  }
  return PreferenceHelper.user;
});

/// Fetches and caches the app version.
final appVersionProvider = FutureProvider<String>((ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  } catch (e) {
    debugPrint('Error loading package info: $e');
    return '1.0.0';
  }
});

// ─── Local UI State Providers ────────────────────────────────────────────────

/// Holds whether biometric lock is enabled.
final biometricEnabledProvider = StateProvider<bool>((ref) {
  return PreferenceHelper.isEnabledBiometric;
});

// ─── Combined Settings State Provider ────────────────────────────────────────

final settingStateProvider = Provider<AsyncValue<SettingState>>((ref) {
  final asyncValues = [ref.watch(currentUserProvider), ref.watch(appVersionProvider)];

  for (final value in asyncValues) {
    if (value.isLoading) return const AsyncValue.loading();
    if (value.hasError) return AsyncValue.error(value.error!, value.stackTrace!);
  }

  final user = (asyncValues[0] as AsyncValue<UserModel?>).value;
  final isBiometricEnabled = ref.watch(biometricEnabledProvider);
  final version = (asyncValues[1] as AsyncValue<String>).value ?? '1.0.0';

  String usingSince = '';
  if (user != null && user.createdAt != null) {
    usingSince = 'Using since ${_monthName(user.createdAt!.month)} ${user.createdAt!.year}';
  }

  return AsyncValue.data(
    SettingState(
      currentUser: user,
      usingSince: usingSince,
      isBiometricEnabled: isBiometricEnabled,
      version: version,
      notificationsEnabled: PreferenceHelper.isNotificationEnabled,
    ),
  );
});

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

// ─── Settings Action Controller ──────────────────────────────────────────────

final settingsControllerProvider = Provider<SettingsController>((ref) {
  return SettingsController(ref);
});

class SettingsController {
  final Ref ref;
  final LocalAuthentication _localAuth = LocalAuthentication();

  SettingsController(this.ref);

  Future<void> toggleBiometric(bool value) async {
    if (value) {
      try {
        final canCheck = await _localAuth.canCheckBiometrics;
        final isDeviceSupported = await _localAuth.isDeviceSupported();

        if (!canCheck && !isDeviceSupported) {
          errorSnackbar('Biometric authentication is not supported on this device.');
          return;
        }
        ref.read(biometricEnabledProvider.notifier).state = true;
        PreferenceHelper.isEnabledBiometric = true;
      } catch (e) {
        debugPrint('Biometric Error: $e');
        errorSnackbar('Failed to authenticate.');
      }
    } else {
      ref.read(biometricEnabledProvider.notifier).state = false;
      PreferenceHelper.isEnabledBiometric = false;
    }
  }

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
    ref.read(homeProvider).changeIndex(0);
    appRouter.pushReplacementNamed(Routes.ONBOARDING);
  }

  void showAboutAppDialog(String version) {
    HapticFeedback.heavyImpact();
    AboutSheet.show(version);
  }
}
