import 'package:budgetly/core/import_to_export.dart';

class ProfileController extends GetxController {
  // ─── Reactive State ───────────────────────────────────────────────────────
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    // Initialize with the data from SettingController or PreferenceHelper
    if (Get.isRegistered<SettingController>()) {
      currentUser.value = Get.find<SettingController>().currentUser.value;
    } else {
      currentUser.value = PreferenceHelper.user;
    }
  }

  // ─── Computed Getters ─────────────────────────────────────────────────────

  String get initials {
    final name = currentUser.value?.name ?? '';
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  // ─── Phone Update Logic ───────────────────────────────────────────────────

  void changePhone() {
    HapticFeedback.heavyImpact();
    final controller = TextEditingController(text: currentUser.value?.phone);
    Get.bottomSheet(
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(Get.context!).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Update Phone Number', style: boldText(20)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                style: regularText(16),
                decoration: InputDecoration(
                  hintText: 'Enter phone number',
                  filled: true,
                  fillColor: AppColors.black,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.brand, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Button(
                  onClick: () {
                    Get.back(); // Dismiss sheet
                    updatePhone(controller.text.trim());
                  },
                  child: Text('Save', style: semiBoldText(16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> updatePhone(String phone) async {
    final user = FirebaseHelper.currentUser;
    if (user == null || user.email == null) return;

    // Optional: add country code if missing
    if (phone.isNotEmpty && !phone.startsWith('+91')) {
      if (phone.length == 10) {
        phone = '+91 $phone';
      }
    }

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: AppColors.brand)),
        barrierDismissible: false,
      );

      await FirebaseHelper.updateUserPhone(user.email!, phone);
      Get.back(); // close loading

      if (currentUser.value != null) {
        final updatedUserModel = currentUser.value!.copyWith(phone: phone);
        currentUser.value = updatedUserModel;
        PreferenceHelper.user = updatedUserModel;

        // Sync with SettingController
        if (Get.isRegistered<SettingController>()) {
          Get.find<SettingController>().currentUser.value = updatedUserModel;
        }

        Get.snackbar(
          'Success',
          'Phone number updated successfully!',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      Get.back(); // close loading
      Get.snackbar(
        'Error',
        'Failed to update phone number.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  void handleDeleteAccount() {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Account'),
        content: Text(
          'Are you sure you want to delete your account? You will lose your all data permanently.',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              deleteAccount();
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void deleteAccount() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: AppColors.brand)),
        barrierDismissible: false,
      );
      await FirebaseHelper.deleteUserExpenses();
      await FirebaseHelper.deleteUserBudgets();
      await FirebaseHelper.deleteUserCategories();
      await FirebaseHelper.deleteAccount();

      await PreferenceHelper.clearAll();

      Get.find<HomeController>().currentIndex.value = 0;

      Get.back();
      Get.offAllNamed(Routes.ONBOARDING);
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Failed to delete account.',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}
