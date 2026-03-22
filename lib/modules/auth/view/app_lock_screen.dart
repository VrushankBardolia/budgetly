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
            Text(
              'Budgetly is Locked',
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Verify your identity to proceed.',
              style: GoogleFonts.plusJakartaSans(color: Colors.grey[400], fontSize: 15),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _authenticate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'Tap to Unlock',
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
