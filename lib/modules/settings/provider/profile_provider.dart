import 'package:budgetly/core/import_to_export.dart';

final profileControllerProvider = Provider.autoDispose<ProfileController>((ref) {
  return ProfileController(ref);
});

class ProfileController {
  final Ref ref;

  ProfileController(this.ref);

  void changePhone(UserModel user) {
    HapticFeedback.heavyImpact();
    final controller = TextEditingController(text: user.phone);
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
                    updatePhone(user, controller.text.trim());
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

  Future<void> updatePhone(UserModel user, String phone) async {
    final firebaseUser = FirebaseHelper.currentUser;
    if (firebaseUser == null || firebaseUser.email == null) return;

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

      final userRepo = ref.read(userRepositoryProvider);
      await userRepo.updateUserPhone(firebaseUser.email!, phone);
      appRouter.pop(); // close loading

      final updatedUserModel = user.copyWith(phone: phone);
      PreferenceHelper.user = updatedUserModel;

      ref.invalidate(currentUserProvider);
      ref.invalidate(settingStateProvider);

      successSnackbar('Phone number updated successfully!');
    } catch (e) {
      appRouter.pop(); // close loading
      errorSnackbar('Failed to update phone number.');
    }
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
      final expenseRepo = ref.read(expenseRepositoryProvider);
      final budgetRepo = ref.read(budgetRepositoryProvider);
      final categoryRepo = ref.read(categoryRepositoryProvider);
      final userRepo = ref.read(userRepositoryProvider);

      await expenseRepo.deleteUserExpenses();
      await budgetRepo.deleteUserBudgets();
      await categoryRepo.deleteUserCategories();
      await userRepo.deleteAccount();

      await PreferenceHelper.clearAll();

      ref.read(homeProvider).changeIndex(0);

      appRouter.pop();
      appRouter.pushReplacementNamed(Routes.ONBOARDING);
    } catch (e) {
      appRouter.pop();
      errorSnackbar('Failed to delete account.');
    }
  }
}
