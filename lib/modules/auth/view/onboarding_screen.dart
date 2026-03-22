import 'package:budgetly/core/import_to_export.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: controller.pages[controller.currentPage.value].gradient),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextButton(
                        onPressed: controller.completeOnboarding,
                        style: TextButton.styleFrom(foregroundColor: Colors.white.withValues(alpha: 0.8)),
                        child: Text('Skip', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),

                  Expanded(
                    child: PageView.builder(
                      controller: controller.pageController,
                      onPageChanged: (index) {
                        controller.currentPage.value = index;
                      },
                      itemCount: controller.pages.length,
                      itemBuilder: (context, index) {
                        return _buildPage(controller.pages[index]);
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: controller.currentPage.value == index ? 24 : 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: controller.currentPage.value == index ? 1.0 : 0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Button(
                      onClick: () {
                        if (controller.currentPage.value == controller.pages.length - 1) {
                          controller.completeOnboarding();
                        } else {
                          controller.nextPage();
                        }
                      },
                      variant: ButtonVariant.white,
                      child: Text(controller.currentPage.value == controller.pages.length - 1 ? 'Get Started' : 'Next', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
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
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                      boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.2 * value), blurRadius: 40, spreadRadius: 0)],
                    ),
                    child: Icon(page.icon, size: 80, color: Colors.white),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 60),

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
              page.title,
              style: const TextStyle(fontSize: 48, fontFamily: 'BBH Bogle', fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
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
              page.description,
              style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.white.withValues(alpha: 0.9), height: 1.5, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;

  OnboardingPage({required this.icon, required this.title, required this.description, required this.gradient});
}
