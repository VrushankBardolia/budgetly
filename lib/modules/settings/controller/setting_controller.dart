import 'package:flutter/cupertino.dart';

import '../../../core/import_to_export.dart';

class SettingController extends GetxController {
  // ─── Reactive State ───────────────────────────────────────────────────────
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxString usingSince = ''.obs;
  final RxBool isLoading = true.obs;
  final RxBool notificationsEnabled = false.obs;
  final RxBool isNotificationLoading = false.obs;
  final RxBool isBiometricEnabled = false.obs;
  final RxString version = '1.0.0'.obs;

  final LocalAuthentication _localAuth = LocalAuthentication();

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    currentUser.value = PreferenceHelper.user;
    isBiometricEnabled.value = PreferenceHelper.isEnabledBiometric;
    loadUserData();
    loadVersionInfo();
  }

  // ─── User Data ────────────────────────────────────────────────────────────

  Future<void> loadUserData() async {
    final user = FirebaseHelper.currentUser;
    if (user?.uid == null) {
      isLoading.value = false;
      return;
    }

    try {
      final doc = await FirebaseHelper.getUserData(user?.email!);

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['uid'] = user?.uid;

        final userModel = UserModel.fromJson(data);
        currentUser.value = userModel;
        PreferenceHelper.user = userModel;

        final Timestamp? ts = data['createdAt'];
        usingSince.value = ts != null
            ? 'Using since ${_monthName(ts.toDate().month)} ${ts.toDate().year}'
            : '';
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String get initials => currentUser.value?.name.isNotEmpty == true
      ? currentUser.value!.name.trim().split(' ').length > 1
            ? '${currentUser.value!.name.trim().split(' ')[0][0]}${currentUser.value!.name.trim().split(' ')[1][0]}'
                  .toUpperCase()
            : currentUser.value!.name.trim().split(' ')[0][0].toUpperCase()
      : 'U';

  // ─── Biometric ────────────────────────────────────────────────────────────

  Future<void> toggleBiometric(bool value) async {
    if (value) {
      // Trying to enable
      try {
        final canCheck = await _localAuth.canCheckBiometrics;
        final isDeviceSupported = await _localAuth.isDeviceSupported();

        if (!canCheck && !isDeviceSupported) {
          Get.snackbar(
            'Error',
            'Biometric authentication is not supported on this device.',
            backgroundColor: AppColors.error,
            colorText: Colors.white,
          );
          return;
        }
        isBiometricEnabled.value = true;
        PreferenceHelper.isEnabledBiometric = true;
      } catch (e) {
        debugPrint('Biometric Error: $e');
        Get.snackbar(
          'Error',
          'Failed to authenticate.',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } else {
      isBiometricEnabled.value = false;
      PreferenceHelper.isEnabledBiometric = false;
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────────

  Future<void> handleSignOut() async {
    HapticFeedback.heavyImpact();
    Get.dialog(
      AlertDialog(
        title: Text('Sign Out'),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: Get.back, child: Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              signOut();
            },
            child: Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void signOut() async {
    await NotificationService.disable();
    PreferenceHelper.clearAll();
    await FirebaseHelper.signOut();
    Get.find<HomeController>().currentIndex.value = 0;
    Get.offAllNamed(Routes.ONBOARDING);
  }

  // ─── About ────────────────────────────────────────────────────────────────

  void showAboutAppDialog() {
    HapticFeedback.heavyImpact();
    AboutSheet.show(version.value);
  }

  Future<void> loadVersionInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      version.value = info.version;
    } catch (e) {
      debugPrint('Error loading package info: $e');
    } finally {
      isLoading.value = false;
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
