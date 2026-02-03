import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_strings.dart';
import '../../core/globals.dart';
import '../../components/button.dart';
import '../../components/google_signin_button.dart';
import '../../controller/auth_controller.dart';
import '../home.dart';
import 'loginScreen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final authController = Get.put(AuthController());
  final globals = Get.put(Globals());

  final _formKey = GlobalKey<FormState>();

  final RxBool _isLoading = false.obs;
  bool _obscurePassword = true;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    _isLoading.value = true;

    final error = await authController.signUp();

    _isLoading.value = false;

    if (error != null) {
      Get.defaultDialog(
        titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24),
        contentPadding: const EdgeInsets.all(24),
        title: AppStrings.createAccountFailed,
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
            Text(AppStrings.accountCreatedSuccess, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
                children: [
                  const Icon(Icons.wallet, size: 80),
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.createAccountTitle,
                    style: TextStyle(fontFamily: 'BBH Bogle', fontSize: 40),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.signUpSubtitle,
                    style: GoogleFonts.plusJakartaSans(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: authController.nameController,
                    decoration: const InputDecoration(hintText: AppStrings.enterFullName, border: OutlineInputBorder()),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) => authController.nameValidation(value!),
                    enabled: !_isLoading.value,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: authController.emailController,
                    decoration: const InputDecoration(hintText: AppStrings.enterEmail, border: OutlineInputBorder()),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => authController.emailValidation(value!),
                    enabled: !_isLoading.value,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: authController.phoneController,
                    decoration: InputDecoration(
                      hintText: AppStrings.enterPhone,
                      border: OutlineInputBorder(),
                      prefixIcon: Align(
                        widthFactor: 0,
                        alignment: Alignment.centerLeft,
                        child: Text("   ${globals.selectedCountryCode.value}", style: GoogleFonts.plusJakartaSans(fontSize: 17, color: Colors.white)),
                      ),
                      counter: const SizedBox.shrink(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) => authController.phoneValidation(value!),
                    enabled: !_isLoading.value,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    maxLength: 10,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: authController.passwordController,
                    decoration: InputDecoration(
                      hintText: AppStrings.enterPassword,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) => authController.passwordValidation(value!),
                    enabled: !_isLoading.value,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 24),

                  Button(
                    onClick: _isLoading.value ? null : _signUp,
                    child: _isLoading.value
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text(AppStrings.signUpButton),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(AppStrings.alreadyHaveAccount),
                      TextButton(
                        onPressed: () => Get.off(() => LoginScreen()),
                        child: Text(AppStrings.signIn, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
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
