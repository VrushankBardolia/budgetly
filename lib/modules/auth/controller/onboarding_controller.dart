import 'package:budgetly/core/import_to_export.dart';

class OnboardingController extends GetxController {
  // ─── Reactive State ───────────────────────────────────────────────────────
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
  }

  // ─── Auth State ───────────────────────────────────────────────────────────

  void _initializeAuth() {
    FirebaseHelper.authStateChanges.listen((user) async {
      if (user != null) await _fetchAndStoreUserData();
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
        await PreferenceHelper.setUser(userModel);
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
        Get.back();
        return;
      }

      final user = credential.user;
      if (user == null) {
        Get.back();
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

      Get.back();
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      Get.back();
      _showErrorDialog();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseHelper.signOut();
      await PreferenceHelper.setUser(null);
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _showErrorDialog() {
    Get.defaultDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          CircleAvatar(
            backgroundColor: Colors.red.withValues(alpha: 0.1),
            radius: 60,
            child: const Icon(Icons.error, size: 100, color: Colors.red),
          ),
          const Text('Failed to sign in', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
