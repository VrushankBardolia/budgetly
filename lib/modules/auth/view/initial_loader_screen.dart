import 'package:budgetly/core/import_to_export.dart';

class InitialLoaderScreen extends StatefulWidget {
  const InitialLoaderScreen({super.key});

  @override
  State<InitialLoaderScreen> createState() => _InitialLoaderScreenState();
}

class _InitialLoaderScreenState extends State<InitialLoaderScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this)..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.2, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.brandDark,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.brand.withValues(alpha: 0.5), width: 2),
                    boxShadow: [BoxShadow(color: AppColors.brand.withValues(alpha: _animation.value), blurRadius: 30, spreadRadius: 12)],
                  ),
                  child: child,
                );
              },
              child: const Icon(Icons.wallet, size: 72, color: Colors.white),
            ),
            const SizedBox(height: 40),
            Text('Hold on while BUDGETLY\nis getting ready...', style: mediumText(18), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
