import 'package:budgetly/core/import_to_export.dart';

class OnboardingController extends GetxController {
  // ─── Reactive State ───────────────────────────────────────────────────────
  RxBool isLoading = true.obs;

  // Add a reactive variable to hold the logged-in user's data
  Rxn<UserModel> currentUser = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
  }

  // ─── Auth State ───────────────────────────────────────────────────────────
  void _initializeAuth() {
    FirebaseHelper.authStateChanges.listen((user) async {
      if (user != null) {
        await _fetchAndStoreUserData();
      } else {
        currentUser.value = null; // Clear data if user logs out
      }
      isLoading.value = false;
    });
  }

  Future<void> _fetchAndStoreUserData() async {
    try {
      final user = FirebaseHelper.currentUser;
      if (user == null) return;

      final doc = await FirebaseHelper.getUserData(user.email);
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['uid'] = user.uid;

        final userModel = UserModel.fromJson(data);
        PreferenceHelper.user = userModel;

        // Update the reactive variable so the UI can display the data
        currentUser.value = userModel;
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  Future<void> googleSignIn() async {
    try {
      isLoading.value = true;
      Get.dialog(const Center(child: CircularProgressIndicator(color: Colors.white)), barrierDismissible: false);

      final credential = await FirebaseHelper.signInWithGoogle();
      if (credential == null) {
        _closeDialogIfOpen();
        return;
      }

      final user = credential.user;
      if (user == null) {
        _closeDialogIfOpen();
        return;
      }

      final doc = await FirebaseHelper.getUserData(user.email);
      if (!doc.exists) {
        await FirebaseHelper.saveUserData(user.email!, {
          'name': user.displayName ?? 'User',
          'email': user.email,
          'profileUrl': user.photoURL,
          'lastLoginAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await FirebaseHelper.updateUserData(user.email!, {'lastLoginAt': FieldValue.serverTimestamp()});
      }

      await _fetchAndStoreUserData();

      _closeDialogIfOpen();

      // Navigate to Home only if we successfully have user data
      if (currentUser.value != null) {
        // The dashboard controller was instantiated before the user logged in,
        // so we must manually tell it to load data now that we have a valid userId.
        Get.find<DashboardController>().loadData();
        Get.offAllNamed(Routes.HOME);
      }
    } catch (e) {
      _closeDialogIfOpen();
      _showErrorDialog();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseHelper.signOut();
      PreferenceHelper.user = null;
      currentUser.value = null; // Clear the user from memory
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  // Safe helper to close the loading dialog without accidentally popping screens
  void _closeDialogIfOpen() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  void _showErrorDialog() {
    Get.defaultDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: Colors.red.withValues(alpha: 0.1),
            radius: 60,
            child: const Icon(Icons.error, size: 100, color: Colors.red),
          ),
          const SizedBox(height: 12),
          const Text('Failed to sign in', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
