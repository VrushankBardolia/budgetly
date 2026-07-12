import 'package:flutter/cupertino.dart';
import '../../../core/import_to_export.dart';

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(settingStateProvider);
    final controller = ref.read(settingsControllerProvider);

    return Scaffold(
      appBar: AppBar(elevation: 0, title: Text('Settings', style: serifText(20))),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeIn,
        child: stateAsync.when(
          loading: () => buildSettingShimmer(),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (state) => _buildMainContent(context, ref, state, controller),
        ),
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    WidgetRef ref,
    SettingState state,
    SettingsController controller,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          buildProfileHeader(context, state),

          buildSettingsTile(
            icon: HugeIcons.strokeRoundedNotification02,
            title: "Notifications",
            onTap: () => appRouter.pushNamed(Routes.NOTIFICATIONS),
          ),

          buildSettingsTile(
            icon: HugeIcons.strokeRoundedFingerPrintScan,
            title: "Use biometric",
            trailing: Transform.scale(
              scale: 0.8,
              alignment: Alignment.centerRight,
              child: CupertinoSwitch(
                value: state.isBiometricEnabled,
                onChanged: controller.toggleBiometric,
                activeTrackColor: AppColors.brand,
              ),
            ),
          ),

          buildSettingsTile(
            icon: HugeIcons.strokeRoundedPdf02,
            title: "Export PDF",
            onTap: () => appRouter.pushNamed(Routes.EXPORT_PDF),
          ),

          buildSettingsTile(
            icon: HugeIcons.strokeRoundedInformationCircle,
            title: "About Budgetly",
            onTap: () => controller.showAboutAppDialog(state.version),
          ),

          buildSettingsTile(
            icon: HugeIcons.strokeRoundedLogoutSquare01,
            title: "Sign Out",
            color: AppColors.error,
            isDestructive: true,
            onTap: controller.handleSignOut,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget buildProfileHeader(BuildContext context, SettingState state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.surfaceLight,
                child: Text(
                  state.initials,
                  style: customText(32, FontWeight.w900, color: AppColors.brand),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.currentUser?.name ?? "",
                      style: boldText(22),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(state.usingSince, style: regularText(14, color: AppColors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => appRouter.pushNamed(Routes.PROFILE),
            child: Text("Manage Profile", style: semiBoldText(16, color: AppColors.brand)),
          ),
        ],
      ),
    );
  }

  Widget buildSettingsTile({
    required dynamic icon,
    required String title,
    VoidCallback? onTap,
    Color? color,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    final iconColor = color ?? AppColors.textPrimary;
    final textColor = isDestructive ? AppColors.error : AppColors.textPrimary;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        splashColor: Colors.transparent,
        contentPadding: const EdgeInsets.fromLTRB(12, 0, 8, 0),
        leading: HugeIcon(icon: icon, color: iconColor, size: 22),
        title: Text(title, style: semiBoldText(16, color: textColor)),
        trailing:
            trailing ??
            (onTap != null
                ? Icon(Icons.chevron_right_rounded, color: Colors.grey[600], size: 24)
                : null),
      ),
    );
  }

  Widget buildSettingShimmer() {
    const baseColor = AppColors.surface;
    const highlightColor = AppColors.surfaceLight;
    return Container(
      color: AppColors.black,
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header Shimmer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: baseColor,
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
              Center(child: Container(width: 80, height: 12, color: baseColor)),
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
      height: 64,
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Container(height: 16, color: AppColors.black)),
          const SizedBox(width: 16),
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
