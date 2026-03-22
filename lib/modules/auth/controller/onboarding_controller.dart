import 'package:budgetly/core/import_to_export.dart';

class OnboardingController extends GetxController {
  final RxInt currentPage = 0.obs;
  final PageController pageController = PageController();
  final List<OnboardingPage> pages = [
    OnboardingPage(
      icon: Icons.wallet,
      title: 'Welcome to Budgetly',
      description: 'Your personal finance companion that helps you track every rupee with precision and ease.',
      gradient: [Color(0xFF02060D), Color(0xFF051021)],
    ),
    OnboardingPage(
      icon: Icons.bar_chart,
      title: 'Smart Analytics',
      description: 'Visualize your spending patterns with beautiful charts and insights that make sense.',
      gradient: [Color(0xFF051021), Color(0xFF0A2445)],
    ),
    OnboardingPage(
      icon: Icons.list_rounded,
      title: 'Organize Everything',
      description: 'Create custom categories with emojis and track expenses the way you want.',
      gradient: [Color(0xFF02060D), Color(0xFF051021)],
    ),
    OnboardingPage(
      icon: Icons.savings_rounded,
      title: 'Stay on Budget',
      description: 'Set monthly budgets and get real-time updates on your spending to stay in control.',
      gradient: [Color(0xFF051021), Color(0xFF0A2445)],
    ),
  ];
  void nextPage() {
    pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  void previousPage() {
    pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  void goToPage(int page) {
    pageController.animateToPage(page, duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  void completeOnboarding() {
    Get.toNamed(Routes.LOGIN);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
