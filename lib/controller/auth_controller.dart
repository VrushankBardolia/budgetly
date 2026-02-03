import 'package:budgetly/core/globals.dart';
import 'package:budgetly/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Globals globals = Get.put(Globals());

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  final Rx<User?> _user = Rx<User?>(null);
  User? get user => _user.value;

  final RxBool _isLoading = true.obs;
  bool get isLoading => _isLoading.value;

  String? nameValidation(String name) {
    if (name.trim().isEmpty) {
      return 'Please enter your name';
    }
    if (name.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? emailValidation(String email) {
    if (email.trim().isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? phoneValidation(String phone) {
    if (phone.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    if (phone.length != 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? passwordValidation(String password) {
    if (password.trim().isEmpty) {
      return 'Please enter a password';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!RegExp(r'(?=.*[a-z])').hasMatch(password)) {
      return 'one lowercase letter required';
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(password)) {
      return 'one uppercase letter required';
    }
    if (!RegExp(r'(?=.*[0-9])').hasMatch(password)) {
      return 'one number required';
    }
    if (!RegExp(r'(?=.*[!@#\$&*~])').hasMatch(password)) {
      return 'one special character required';
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
  }

  void _initializeAuth() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _fetchUserData(user);
      }
      _user.value = user;
      _isLoading.value = false;
    });
  }

  Future<void> _fetchUserData(User user) async {
    try {
      final doc = await _db.collection('users').doc(user.email).get();
      if (doc.exists) {
        final data = doc.data();
        globals.userName.value = data?['name'] ?? user.displayName ?? "";
        globals.userEmail.value = data?['email'] ?? user.email ?? "";
        globals.userPhone.value = data?['phone'] ?? "";
        globals.userID.value = user.uid;
        globals.isGoogleUser.value = data?['isGoogle'] ?? false;
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

  Future<String?> signUp() async {
    try {
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text);

      if (userCredential.user == null) {
        return 'Failed to create user account';
      }

      // Create user document in Firestore with email as document ID
      await _db.collection('users').doc(emailController.text).set({
        'name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'password': passwordController.text,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
      globals.userName.value = nameController.text;
      globals.userEmail.value = emailController.text;
      globals.userPhone.value = phoneController.text;
      globals.userID.value = userCredential.user!.uid;
      globals.isGoogleUser.value = false;

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'The password is too weak';
        case 'email-already-in-use':
          return 'Account already exists for this email';
        case 'invalid-email':
          return 'Invalid email address';
        default:
          return e.message ?? 'An error occurred during sign up';
      }
    } catch (e) {
      debugPrint('Sign up error: $e');
      return 'Failed to create account. Please try again.';
    }
  }

  Future<String?> signIn() async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text);
      final user = credential.user;
      if (user != null && user.email != null) {
        await _db.collection('users').doc(user.email).set({'lastLoginAt': FieldValue.serverTimestamp()}, SetOptions(merge: true)); // ✅ SAFE

        await _fetchUserData(user);
      }

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
          return 'Incorrect email or password';
        case 'invalid-email':
          return 'Invalid email address';
        case 'user-disabled':
          return 'This account has been disabled';
        case 'too-many-requests':
          return 'Too many failed attempts. Please try again later';
        case 'network-request-failed':
          return 'No internet connection';
        default:
          return 'Sign in failed. Please try again';
      }
    } catch (e) {
      debugPrint('Sign in error: $e');
      return 'Failed to sign in. Please try again.';
    }
  }

  Future<void> googleSignIn() async {
    try {
      _isLoading.value = true;

      Get.dialog(const Center(child: CircularProgressIndicator(color: Colors.white)), barrierDismissible: false);

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      await _auth.signInWithCredential(credential);

      // Check if user document exists
      final userDocRef = _db.collection('users').doc(googleUser.email);
      final userDoc = await userDocRef.get();

      if (!userDoc.exists) {
        // Create new user document
        await userDocRef.set({
          'createdAt': FieldValue.serverTimestamp(),
          'email': googleUser.email,
          'lastLoginAt': FieldValue.serverTimestamp(),
          'name': googleUser.displayName ?? "User",
          'phone': "",
          'isGoogle': true,
        });
      } else {
        // Update last login time
        await userDocRef.update({'lastLoginAt': FieldValue.serverTimestamp()});
      }

      await _fetchUserData(_auth.currentUser!);

      Get.back();
      Get.offAll(() => HomeScreen());
    } on FirebaseAuthException {
      Get.back();
      Get.defaultDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            CircleAvatar(
              backgroundColor: Colors.red.withValues(alpha: 0.1),
              radius: 60,
              child: Icon(Icons.error, size: 100, color: Colors.red),
            ),
            Text("Failed to login!!!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
      );
    } catch (e) {
      Get.back();
      Get.defaultDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            CircleAvatar(
              backgroundColor: Colors.red.withValues(alpha: 0.1),
              radius: 60,
              child: Icon(Icons.error, size: 100, color: Colors.red),
            ),
            Text("Failed to login!!!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      globals.isGoogleUser.value = false;
      _user.value = null;
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }
}
