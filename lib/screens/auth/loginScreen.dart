import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_strings.dart';
import '../../components/google_signin_button.dart';
import '../../controller/auth_controller.dart';
import '../../components/button.dart';
import '../home.dart';
import 'signupScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final authController = Get.find<AuthController>();

  final RxBool _isLoading = false.obs;
  final RxBool _obscurePassword = true.obs;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    _isLoading.value = true;
    final error = await authController.signIn();
    _isLoading.value = false;
    if (error != null) {
      Get.defaultDialog(
        titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24),
        contentPadding: const EdgeInsets.all(24),
        title: AppStrings.loginFailed,
        middleText: error,
        cancel: TextButton(onPressed: () => Get.back(), child: const Text(AppStrings.letMeTryAgain)),
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
              child: Icon(Icons.check, size: 100, color: Colors.green),
            ),
            Text(AppStrings.loggedInSuccess, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
      );
      Future.delayed(Duration(seconds: 2), () {
        Get.back();
        Get.offAll(() => HomeScreen());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Obx(
              () => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wallet, size: 80),
                  const SizedBox(height: 24),
                  Text(AppStrings.signIn, style: TextStyle(fontFamily: 'BBH Bogle', fontSize: 40)),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.signInSubtitle,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: authController.emailController,
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: AppStrings.enterEmail),
                    cursorColor: Colors.white,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isLoading.value,
                    validator: (value) => authController.emailValidation(value!),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: authController.passwordController,
                    decoration: InputDecoration(
                      hintText: AppStrings.enterPassword,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword.value ? CupertinoIcons.eye_slash : CupertinoIcons.eye),
                        onPressed: () => _obscurePassword.value = !_obscurePassword.value,
                      ),
                      enabled: !_isLoading.value,
                    ),
                    obscureText: _obscurePassword.value,
                    validator: (value) => authController.passwordValidation(value!),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 20),

                  Button(
                    onClick: _isLoading.value ? null : _login,
                    child: _isLoading.value
                        ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(AppStrings.signInButton, style: TextStyle(fontSize: 16)),
                  ),

                  SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(AppStrings.dontHaveAccount),
                      TextButton(
                        onPressed: () => Get.off(() => SignupScreen()),
                        child: Text(AppStrings.createAccount, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),

                  Text(AppStrings.or),
                  SizedBox(height: 12),

                  GoogleSigninButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
