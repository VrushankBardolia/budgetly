import '../../../core/import_to_export.dart';

class SettingController extends GetxController {
  // final Globals globals = Get.put(Globals());

  // ─── Reactive State ───────────────────────────────────────────────────────
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxString usingSince = ''.obs;
  final RxBool isLoading = true.obs;
  final RxBool notificationsEnabled = false.obs;
  final RxBool isNotificationLoading = false.obs;
  final RxBool isBiometricEnabled = false.obs;

  final LocalAuthentication _localAuth = LocalAuthentication();

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    currentUser.value = PreferenceHelper.user;
    isBiometricEnabled.value = PreferenceHelper.isEnabledBiometric;
    loadUserData();
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

  String getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

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

  // ─── Change Phone ─────────────────────────────────────────────────────────

  void changePhone() {
    HapticFeedback.heavyImpact();
    final controller = TextEditingController(text: currentUser.value?.phone);
    Get.bottomSheet(
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      SafeArea(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Change Phone', style: regularText(20)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                style: regularText(14),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => updatePhone(controller.text.trim()),
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updatePhone(String phone) async {
    final user = FirebaseHelper.currentUser;
    if (user == null) return;

    if (!phone.contains('+91 ')) {
      phone = '+91 $phone';
    }
    await FirebaseHelper.updateUserPhone(user.email!, phone);

    if (currentUser.value != null) {
      final updatedUserModel = currentUser.value!.copyWith(phone: phone);
      currentUser.value = updatedUserModel;
      PreferenceHelper.user = updatedUserModel;
      Get.back();
      Get.snackbar('Success', 'Phone number updated successfully!');
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────────

  Future<void> handleSignOut() async {
    HapticFeedback.heavyImpact();
    Get.defaultDialog(
      contentPadding: const EdgeInsets.all(24),
      titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24),
      title: 'Sign Out',
      middleText: 'Are you sure you want to sign out?',
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: signOut,
        child: const Text('Sign Out'),
      ),
      cancel: TextButton(onPressed: Get.back, child: const Text('Cancel')),
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
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wallet,
                size: 60,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text('Budgetly', style: GoogleFonts.staatliches(fontSize: 32)),
            const SizedBox(height: 8),
            Text('Version 1.3.1', style: regularText(14)),
            const SizedBox(height: 24),
            Text(
              'A simple and effective personal expense tracking application designed to help you save money.',
              textAlign: TextAlign.center,
              style: regularText(15, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 32),
            Button(
              onClick: Get.back,
              child: Text('Close', style: regularText(16)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
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
