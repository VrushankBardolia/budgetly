import 'package:budgetly/core/import_to_export.dart';
import 'package:flutter/cupertino.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: controller.loginFormKey,
            child: Obx(
              () => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wallet, size: 80),
                  const SizedBox(height: 24),
                  const Text("Sign In", style: TextStyle(fontFamily: 'BBH Bogle', fontSize: 40)),
                  const SizedBox(height: 8),
                  const Text(
                    "Sign In to your account",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // ── Email ───────────────────────────────────────────────
                  TextFormField(
                    controller: controller.emailController,
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Enter Email"),
                    cursorColor: Colors.white,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !controller.isLoginLoading.value,
                    validator: (v) => controller.emailValidation(v!),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 20),

                  // ── Password ────────────────────────────────────────────
                  TextFormField(
                    controller: controller.passwordController,
                    decoration: InputDecoration(
                      hintText: "Enter Password",
                      border: const OutlineInputBorder(),
                      enabled: !controller.isLoginLoading.value,
                      suffixIcon: IconButton(
                        icon: Icon(controller.loginObscurePassword.value ? CupertinoIcons.eye_slash : CupertinoIcons.eye),
                        onPressed: controller.toggleLoginPasswordVisibility,
                      ),
                    ),
                    obscureText: controller.loginObscurePassword.value,
                    enabled: !controller.isLoginLoading.value,
                    validator: (v) => controller.passwordValidation(v!),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 20),

                  // ── Login Button ────────────────────────────────────────
                  Button(
                    onClick: controller.isLoginLoading.value ? null : controller.login,
                    child: controller.isLoginLoading.value
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text("Sign In", style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 12),

                  // ── Navigate to Sign Up ─────────────────────────────────
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text("Don't have an account"),
                      TextButton(
                        onPressed: () => Get.offNamed(Routes.SIGNUP),
                        child: Text("Create Account", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),

                  const Text("Or"),
                  const SizedBox(height: 12),
                  const GoogleSigninButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
