import 'package:budgetly/core/import_to_export.dart';

class ProfileProvider extends ChangeNotifier {
  final Ref ref;

  // ─── State ───────────────────────────────────────────────────────
  UserModel? currentUser;

  ProfileProvider(this.ref) {
    // Initialize with the data from SettingProvider or PreferenceHelper
    currentUser = ref.read(settingProvider).currentUser ?? PreferenceHelper.user;
  }

  // ─── Computed Getters ─────────────────────────────────────────────────────

  String get initials {
    final name = currentUser?.name ?? '';
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
    final controller = TextEditingController(text: currentUser?.phone);
    bottomSheet(
      SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(appContext!).viewInsets.bottom + 24,
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
                    appRouter.pop(); // Dismiss sheet
                    updatePhone(controller.text.trim());
                  },
                  child: Text('Save', style: semiBoldText(16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
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
      dialog(
        const Center(child: CircularProgressIndicator(color: AppColors.brand)),
        barrierDismissible: false,
      );

      await FirebaseHelper.updateUserPhone(user.email!, phone);
      appRouter.pop(); // close loading

      if (currentUser != null) {
        final updatedUserModel = currentUser!.copyWith(phone: phone);
        currentUser = updatedUserModel;
        PreferenceHelper.user = updatedUserModel;

        // Sync with SettingProvider
        ref.read(settingProvider).currentUser = updatedUserModel;
        ref.read(settingProvider).loadUserData(); // Reload/update settings

        successSnackbar('Phone number updated successfully!');
      }
    } catch (e) {
      appRouter.pop(); // close loading
      errorSnackbar('Failed to update phone number.');
    }
    notifyListeners();
  }

  void handleDeleteAccount() async {
    final confirmed = await confirmationDialog(
      title: 'Delete Account',
      message:
          'Are you sure you want to delete your account? You will lose all your data permanently.',
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (confirmed) {
      deleteAccount();
    }
  }

  void deleteAccount() async {
    try {
      dialog(
        const Center(child: CircularProgressIndicator(color: AppColors.brand)),
        barrierDismissible: false,
      );
      await FirebaseHelper.deleteUserExpenses();
      await FirebaseHelper.deleteUserBudgets();
      await FirebaseHelper.deleteUserCategories();
      await FirebaseHelper.deleteAccount();

      await PreferenceHelper.clearAll();

      ref.read(homeProvider).currentIndex = 0;

      appRouter.pop();
      appRouter.pushReplacementNamed(Routes.ONBOARDING);
    } catch (e) {
      appRouter.pop();
      errorSnackbar('Failed to delete account.');
    }
  }
}
