import 'package:budgetly/core/import_to_export.dart';

class GoogleSigninButton extends StatelessWidget {
  const GoogleSigninButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.find<AuthController>().googleSignIn(),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.brandDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.3)),
        ),
        child: Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Continue with", style: semiBoldText(16)),
            SvgPicture.asset("assets/logo/google.svg"),
          ],
        ),
      ),
    );
  }
}
