import '../../../core/import_to_export.dart';

class SettingsShimmerLoader extends StatelessWidget {
  const SettingsShimmerLoader({super.key});

  final Color _baseColor = AppColors.surface;
  final Color _highlightColor = AppColors.surfaceLight;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.black,
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: _baseColor,
        highlightColor: _highlightColor,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header Shimmer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _baseColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    // Avatar Circle
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 20),
                    // Name and Date lines
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 160, height: 24, color: Colors.white),
                        const SizedBox(height: 8),
                        Container(width: 100, height: 14, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 1: Profile
              _buildSectionTitleShimmer(),
              _buildTileShimmer(),
              _buildTileShimmer(),

              const SizedBox(height: 20),

              // Section 2: Support
              _buildSectionTitleShimmer(),
              _buildTileShimmer(),

              const SizedBox(height: 20),

              // Section 3: Account
              _buildSectionTitleShimmer(),
              _buildTileShimmer(),

              const SizedBox(height: 40),

              // Version Text
              Center(child: Container(width: 80, height: 12, color: _baseColor)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitleShimmer() {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Container(width: 80, height: 16, color: Colors.white),
    );
  }

  Widget _buildTileShimmer() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      height: 64, // Matches approx height of your settings tile
      decoration: BoxDecoration(color: _baseColor, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Icon Box
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(width: 16),
          // Title
          Expanded(child: Container(height: 16, color: AppColors.black)),
          const SizedBox(width: 16),
          // Chevron placeholder
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: AppColors.black, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}
