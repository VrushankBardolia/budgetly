import 'package:budgetly/core/import_to_export.dart';

class OnboardingProvider extends ChangeNotifier {
  final Ref ref;

  // ─── Reactive State ───────────────────────────────────────────────────────
  bool isCheckingAuth = true;
  bool isLoading = false;
  UserModel? currentUser;

  OnboardingProvider(this.ref) {
    _initializeAuth();
  }

  // ─── Auth State ───────────────────────────────────────────────────────────
  void _initializeAuth() {
    FirebaseHelper.authStateChanges.listen((user) async {
      if (user != null) {
        await _fetchAndStoreUserData();
        _loadDataForControllers();
      } else {
        currentUser = null; // Clear data if user logs out
      }
      isCheckingAuth = false;
      notifyListeners();
    });
  }

  void _loadDataForControllers() {
    ref.read(dashboardProvider).loadData();
    ref.read(categoryProvider).loadCategories();
    ref.read(sheetsProvider).loadSheets();
    ref.read(settingProvider).loadUserData();
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

        // Update the variable so the UI can display the data
        currentUser = userModel;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  Future<void> googleSignIn() async {
    try {
      isLoading = true;
      notifyListeners();
      dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
      );

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
        final userData = UserInputModel(
          name: user.displayName ?? 'User',
          email: user.email!,
          lastLoginAt: DateTime.now(),
          createdAt: DateTime.now(),
        );
        await FirebaseHelper.saveUserData(user.email!, userData);
      } else {
        await FirebaseHelper.updateUserLastLogin(user.email!);
      }

      await _fetchAndStoreUserData();

      _closeDialogIfOpen();

      // Navigate to Home only if we successfully have user data
      if (currentUser != null) {
        _loadDataForControllers();
        appRouter.pushReplacementNamed(Routes.HOME);
      }
    } catch (e) {
      _closeDialogIfOpen();
      _showErrorDialog();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseHelper.signOut();
      PreferenceHelper.user = null;
      currentUser = null; // Clear the user from memory
      notifyListeners();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  // Safe helper to close the loading dialog without accidentally popping screens
  void _closeDialogIfOpen() {
    if (isDialogOpen) {
      appRouter.pop();
    }
  }

  void _showErrorDialog() {
    defaultDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: Colors.red.withValues(alpha: 0.1),
            radius: 60,
            child: const Icon(Icons.error, size: 100, color: Colors.red),
          ),
          const SizedBox(height: 12),
          const Text(
            'Failed to sign in',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
