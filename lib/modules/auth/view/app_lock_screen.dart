import 'package:budgetly/core/import_to_export.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);
    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to unlock Budgetly',
        // options: const AuthenticationOptions(stickyAuth: true, biometricOnly: false),
      );
      if (didAuthenticate) {
        Get.offAll(() => const HomeScreen());
      }
    } catch (e) {
      debugPrint('Biometric Error: $e');
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(color: AppColors.brand.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: const HugeIcon(icon: HugeIcons.strokeRoundedFingerPrintScan, size: 64, color: AppColors.brand),
            ),
            const SizedBox(height: 32),
            Text('Budgetly is Locked', style: boldText(24, color: Colors.white)),
            const SizedBox(height: 16),
            Text('Verify your identity to proceed.', style: regularText(15, color: Colors.grey)),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _authenticate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Tap to Unlock', style: semiBoldText(16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
