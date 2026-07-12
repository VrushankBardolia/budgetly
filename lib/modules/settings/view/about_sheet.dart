import 'package:budgetly/core/import_to_export.dart';

class AboutSheet {
  static void show(String version) {
    bottomSheet(
      AboutSheetContent(version: version),
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    );
  }
}

class AboutSheetContent extends StatelessWidget {
  final String version;
  const AboutSheetContent({super.key, required this.version});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Hero ─────────────────────────────────────────────────
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.brandDark,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: AppColors.brand.withValues(alpha: 0.3), blurRadius: 24)],
            ),
            child: const Icon(Icons.wallet_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),

          // App name
          Text('Budgetly', style: serifText(32).copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),

          // Tagline
          Text('Simple. Smart. Savings.', style: semiBoldText(14, color: AppColors.brand)),
          const SizedBox(height: 12),

          // Description
          Text(
            'A personal finance tracker designed to help you understand where your money goes and stay within budget every month.',
            textAlign: TextAlign.center,
            style: regularText(14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // ── Footer ────────────────────────────────────────────────
          FittedBox(
            child: Text(
              'Made with 𖹭 from Surat',
              style: GoogleFonts.staatliches(color: AppColors.hintColor, fontSize: 40),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          Text('v$version', style: semiBoldText(14, color: AppColors.grey)),
        ],
      ),
    );
  }
}
