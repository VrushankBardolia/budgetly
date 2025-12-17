import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  User? _user;
  bool _isLoading = true;

  User? get user => _user;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });

  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return 'Failed to create user account';
      }

      // Create user document in Firestore with email as document ID
      await _db.collection('users').doc(email).set({
        'name': name,
        'email': email,
        'phone': phone,
        'password':password,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

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

  Future<String?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null && user.email != null) {
        await _db.collection('users').doc(user.email).set({
          'lastLoginAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)); // ✅ SAFE
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

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }
}