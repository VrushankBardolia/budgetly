import 'package:flutter/cupertino.dart';

import '../../../core/import_to_export.dart';

class SettingsTab extends GetView<SettingController> {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        title: Text('Settings', style: boldText(24)),
      ),
      body: Obx(() {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeIn,
          child: controller.isLoading.value
              ? buildSettingShimmer()
              : _buildMainContent(),
        );
      }),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProfileHeader(),
          Obx(
            () => _buildSettingsTile(
              icon: HugeIcons.strokeRoundedMail02,
              title: controller.currentUser.value?.email ?? "",
            ),
          ),

          Obx(
            () => _buildSettingsTile(
              icon: HugeIcons.strokeRoundedCall02,
              title: controller.currentUser.value?.phone.isNotEmpty == true
                  ? controller.currentUser.value!.phone
                  : "Add Phone",
              onTap: () => controller.changePhone(),
            ),
          ),
          // buildBiometricTile(),
          _buildSettingsTile(
            icon: HugeIcons.strokeRoundedNotification02,
            title: "Notifications",
            onTap: () => Get.toNamed(Routes.NOTIFICATIONS),
          ),

          // const SizedBox(height: 20),
          // _buildSectionTitle("Support"),
          _buildSettingsTile(
            icon: HugeIcons.strokeRoundedFile02,
            title: "About Budgetly",
            onTap: () => controller.showAboutAppDialog(),
          ),

          // const SizedBox(height: 20),
          // _buildSectionTitle("Account"),
          _buildSettingsTile(
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

  Widget _buildProfileHeader() {
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
                radius: 28,
                backgroundColor: Theme.of(Get.context!).colorScheme.secondary,
                child: Obx(
                  () => Text(
                    controller.getInitials(
                      controller.currentUser.value?.name ?? "",
                    ),
                    style: customText(
                      24,
                      FontWeight.w900,
                      color: AppColors.brandDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.currentUser.value?.name ?? "",
                      style: boldText(24),
                    ),
                    Text(controller.usingSince.value),
                  ],
                ),
              ),
            ],
          ),
          // SizedBox(height: 12),
          // Divider(height: 1),
          // SizedBox(height: 8),
          // Text("Manage Profile", style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required dynamic icon,
    required String title,
    VoidCallback? onTap,
    Color? color,
    bool isDestructive = false,
  }) {
    final iconColor = color ?? Colors.white;
    final textColor = isDestructive ? AppColors.error : Colors.white;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        splashColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive
                ? AppColors.error.withValues(alpha: 0.1)
                : AppColors.black,
            borderRadius: BorderRadius.circular(10),
          ),
          child: HugeIcon(icon: icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: semiBoldText(16, color: textColor)),
        trailing: onTap != null
            ? Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey[600],
                size: 24,
              )
            : null,
      ),
    );
  }

  Widget buildBiometricTile() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        splashColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(10),
          ),
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedFingerPrintScan,
            color: Colors.white,
            size: 22,
          ),
        ),
        title: Text("Use biometric", style: semiBoldText(16)),
        trailing: Transform.scale(
          scale: 0.9,
          alignment: Alignment.centerRight,
          child: Obx(
            () => CupertinoSwitch(
              value: controller.isBiometricEnabled.value,
              onChanged: (value) => controller.toggleBiometric(value),
              activeTrackColor: AppColors.brand,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSettingShimmer() {
    Color baseColor = AppColors.surface;
    Color highlightColor = AppColors.surfaceLight;
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
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
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
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
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
            decoration: BoxDecoration(
              color: AppColors.black,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
