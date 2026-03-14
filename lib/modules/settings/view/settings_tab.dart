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
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
      ),
      body: Obx(() {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeIn,
          child: controller.isLoading.value ? const SettingsShimmerLoader() : _buildMainContent(),
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
          // const SizedBox(height: 20),

          // _buildSectionTitle("Profile"),
          Obx(() => _buildSettingsTile(icon: HugeIcons.strokeRoundedMail02, title: controller.currentUser.value?.email ?? "")),

          Obx(
            () => _buildSettingsTile(
              icon: HugeIcons.strokeRoundedCall02,
              title: controller.currentUser.value?.phone.isNotEmpty == true ? controller.currentUser.value!.phone : "Add Phone",
              onTap: () => controller.changePhone(),
            ),
          ),

          _buildSettingsTile(icon: HugeIcons.strokeRoundedNotification02, title: "Notifications", onTap: () => Get.toNamed(Routes.NOTIFICATIONS)),

          // const SizedBox(height: 20),
          // _buildSectionTitle("Support"),
          _buildSettingsTile(icon: HugeIcons.strokeRoundedFile02, title: "About Budgetly", onTap: () => controller.showAboutAppDialog()),

          // const SizedBox(height: 20),
          // _buildSectionTitle("Account"),
          _buildSettingsTile(icon: HugeIcons.strokeRoundedLogoutSquare01, title: "Sign Out", color: AppColors.error, isDestructive: true, onTap: controller.handleSignOut),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Theme.of(Get.context!).colorScheme.secondary,
            child: Obx(
              () => Text(
                controller.getInitials(controller.currentUser.value?.name ?? ""),
                style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900, color: Theme.of(Get.context!).colorScheme.primary),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Text(
                  controller.currentUser.value?.name ?? "",
                  style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),

              /// Only keep Obx where Rx is used
              Obx(() => Text(controller.usingSince.value)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(color: AppColors.brand, fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({required dynamic icon, required String title, VoidCallback? onTap, Color? color, bool isDestructive = false}) {
    final iconColor = color ?? Colors.white;
    final textColor = isDestructive ? AppColors.error : Colors.white;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        splashColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: isDestructive ? AppColors.error.withValues(alpha: 0.1) : AppColors.black, borderRadius: BorderRadius.circular(10)),
          child: HugeIcon(icon: icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        trailing: onTap != null ? Icon(Icons.chevron_right_rounded, color: Colors.grey[600], size: 24) : null,
      ),
    );
  }
}
