import 'package:budgetly/core/import_to_export.dart';

class SignupScreen extends GetView<AuthController> {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: controller.signupFormKey,
            child: Obx(
              () => Column(
                children: [
                  Icon(Icons.wallet, size: 80),
                  SizedBox(height: 24),
                  Text(
                    "Create Account",
                    style: TextStyle(fontFamily: 'BBH Bogle', fontSize: 40),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Sign Up to your account",
                    style: GoogleFonts.plusJakartaSans(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),

                  // ── Name ────────────────────────────────────────────────
                  TextFormField(
                    controller: controller.nameController,
                    decoration: InputDecoration(hintText: "Enter Full Name", border: OutlineInputBorder()),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => controller.nameValidation(v!),
                    enabled: !controller.isSignupLoading.value,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: 16),

                  // ── Email ───────────────────────────────────────────────
                  TextFormField(
                    controller: controller.emailController,
                    decoration: InputDecoration(hintText: "Enter Email", border: OutlineInputBorder()),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => controller.emailValidation(v!),
                    enabled: !controller.isSignupLoading.value,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: 16),

                  // ── Phone ───────────────────────────────────────────────
                  TextFormField(
                    controller: controller.phoneController,
                    decoration: InputDecoration(
                      hintText: "Enter Phone",
                      border: OutlineInputBorder(),
                      prefixIcon: Align(
                        widthFactor: 0,
                        alignment: Alignment.centerLeft,
                        child: Text('${FirebaseHelper.currentUser?.phoneNumber}', style: GoogleFonts.plusJakartaSans(fontSize: 17, color: Colors.white)),
                      ),
                      counter: SizedBox.shrink(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (v) => controller.phoneValidation(v!),
                    enabled: !controller.isSignupLoading.value,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    maxLength: 10,
                  ),
                  SizedBox(height: 16),

                  // ── Password ────────────────────────────────────────────
                  TextFormField(
                    controller: controller.passwordController,
                    decoration: InputDecoration(
                      hintText: "Enter Password",
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(controller.signupObscurePassword.value ? Icons.visibility_off : Icons.visibility),
                        onPressed: controller.toggleSignupPasswordVisibility,
                      ),
                    ),
                    obscureText: controller.signupObscurePassword.value,
                    validator: (v) => controller.passwordValidation(v!),
                    enabled: !controller.isSignupLoading.value,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: 24),

                  // ── Sign Up Button ──────────────────────────────────────
                  Button(
                    onClick: controller.isSignupLoading.value ? null : controller.signup,
                    child: controller.isSignupLoading.value
                        ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text("Sign Up"),
                  ),
                  SizedBox(height: 12),

                  // ── Navigate to Login ───────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account"),
                      TextButton(
                        onPressed: () => Get.offNamed(Routes.LOGIN),
                        child: Text("Sign In", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),

                  Text("Or"),
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
