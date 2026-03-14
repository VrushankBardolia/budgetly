import '../../../core/import_to_export.dart';

class AuthController extends GetxController {

  // ─── Text Controllers ─────────────────────────────────────────────────────
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  // ─── Form Keys ────────────────────────────────────────────────────────────
  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();

  // ─── Reactive State ───────────────────────────────────────────────────────
  RxBool isLoading = true.obs;
  RxBool isLoginLoading = false.obs;
  RxBool isSignupLoading = false.obs;
  RxBool loginObscurePassword = true.obs;
  RxBool signupObscurePassword = true.obs;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
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
        data['uid'] = user.uid; // Ensure uid is populated for json

        final userModel = UserModel.fromJson(data);
        await PreferenceHelper.setUser(userModel);
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  // ─── Toggle Visibility ────────────────────────────────────────────────────

  void toggleLoginPasswordVisibility() => loginObscurePassword.value = !loginObscurePassword.value;

  void toggleSignupPasswordVisibility() => signupObscurePassword.value = !signupObscurePassword.value;

  // ─── Login ────────────────────────────────────────────────────────────────

  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    isLoginLoading.value = true;
    final error = await signIn();
    isLoginLoading.value = false;

    if (error != null) {
      Get.defaultDialog(
        titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24),
        contentPadding: const EdgeInsets.all(24),
        title: "Login Failed",
        middleText: error,
        cancel: TextButton(onPressed: () => Get.back(), child: const Text("Let Me Try Again")),
      );
    } else {
      Get.defaultDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            CircleAvatar(
              backgroundColor: Colors.green.withValues(alpha: 0.1),
              radius: 60,
              child: const Icon(Icons.check, size: 100, color: Colors.green),
            ),
            const Text("Logged In Success", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        Get.back();
        Get.offAllNamed(Routes.HOME);
      });
    }
  }

  // ─── Sign Up ──────────────────────────────────────────────────────────────

  Future<void> signup() async {
    if (!signupFormKey.currentState!.validate()) return;

    isSignupLoading.value = true;
    final error = await signUp();
    isSignupLoading.value = false;

    if (error != null) {
      Get.defaultDialog(
        titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24),
        contentPadding: const EdgeInsets.all(24),
        title: "Create Account Failed",
        middleText: error,
        cancel: TextButton(onPressed: () => Get.back(), child: const Text("Let Me Try Again")),
      );
    } else {
      Get.defaultDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            CircleAvatar(
              backgroundColor: Colors.green.withValues(alpha: 0.1),
              radius: 60,
              child: const Icon(Icons.check, size: 100, color: Colors.green),
            ),
            const Text("Account Created Success", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        Get.back();
        Get.offAllNamed(Routes.HOME);
      });
    }
  }

  // ─── Firebase Auth Methods ────────────────────────────────────────────────

  Future<String?> signUp() async {
    try {
      final credential = await FirebaseHelper.signUpWithEmail(emailController.text.trim(), passwordController.text);

      if (credential.user == null) return 'Failed to create user account';

      await FirebaseHelper.saveUserData(emailController.text.trim(), {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isGoogle': false,
      });

      // globals.userName.value = nameController.text.trim();
      // globals.userEmail.value = emailController.text.trim();
      // globals.userPhone.value = phoneController.text.trim();
      // globals.userID.value = credential.user!.uid;
      // globals.isGoogleUser.value = false;

      return null;
    } on Exception catch (e) {
      return _mapFirebaseError(e);
    }
  }

  Future<String?> signIn() async {
    try {
      final credential = await FirebaseHelper.signInWithEmail(emailController.text.trim(), passwordController.text);

      final user = credential.user;
      if (user != null) {
        await FirebaseHelper.updateUserData(user.email!, {'lastLoginAt': FieldValue.serverTimestamp()});
        await _fetchAndStoreUserData();
      }

      return null;
    } on Exception catch (e) {
      return _mapFirebaseError(e);
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
          'createdAt': FieldValue.serverTimestamp(),
          'email': user.email,
          'lastLoginAt': FieldValue.serverTimestamp(),
          'name': user.displayName ?? 'User',
          'phone': '',
          'isGoogle': true,
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

  // ─── Validation ───────────────────────────────────────────────────────────

  String? nameValidation(String name) {
    if (name.trim().isEmpty) return 'Please enter your name';
    if (name.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? emailValidation(String email) {
    if (email.trim().isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+\-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailRegex.hasMatch(email)) return 'Please enter a valid email';
    return null;
  }

  String? phoneValidation(String phone) {
    if (phone.trim().isEmpty) return 'Please enter your phone number';
    if (phone.length != 10) return 'Please enter a valid phone number';
    return null;
  }

  String? passwordValidation(String password) {
    if (password.trim().isEmpty) return 'Please enter a password';
    if (password.length < 6) return 'Password must be at least 6 characters';
    if (!RegExp(r'(?=.*[a-z])').hasMatch(password)) return 'One lowercase letter required';
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(password)) return 'One uppercase letter required';
    if (!RegExp(r'(?=.*[0-9])').hasMatch(password)) return 'One number required';
    if (!RegExp(r'(?=.*[!@#\$&*~])').hasMatch(password)) return 'One special character required';
    return null;
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _mapFirebaseError(Exception e) {
    final code = e.toString();
    if (code.contains('weak-password')) return 'The password is too weak';
    if (code.contains('email-already-in-use')) return 'Account already exists for this email';
    if (code.contains('invalid-email')) return 'Invalid email address';
    if (code.contains('invalid-credential')) return 'Incorrect email or password';
    if (code.contains('user-disabled')) return 'This account has been disabled';
    if (code.contains('too-many-requests')) return 'Too many failed attempts. Please try again later';
    if (code.contains('network-request-failed')) return 'No internet connection';
    return 'Something went wrong. Please try again.';
  }

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
