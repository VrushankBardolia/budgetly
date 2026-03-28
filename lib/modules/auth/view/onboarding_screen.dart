import 'package:budgetly/core/import_to_export.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF02060D), Color(0xFF051021)]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.5 + (value * 0.5),
                            child: Opacity(
                              opacity: value,
                              child: Container(
                                padding: EdgeInsets.all(24),
                                decoration: BoxDecoration(color: AppColors.brandDark, shape: BoxShape.circle),
                                child: Icon(Icons.wallet, size: 120),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: Text(
                          'Welcome to Budgetly',
                          style: GoogleFonts.staatliches(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white, height: 1),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: Text(
                          'Your personal finance companion that helps you track every rupee with precision and ease.',
                          style: regularText(16, color: AppColors.grey, height: 1.2),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(padding: const EdgeInsets.all(24), child: GoogleSigninButton()),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
