import 'package:budgetly/core/import_to_export.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final controller = ref.read(profileControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text("Manage Profile", style: serifText(20)), centerTitle: true),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brand)),
        error: (err, stack) => Center(child: Text('Error loading profile: $err')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('No user logged in'));
          }

          final initials = user.name.isNotEmpty == true
              ? user.name.trim().split(' ').length > 1
                  ? '${user.name.trim().split(' ')[0][0]}${user.name.trim().split(' ')[1][0]}'
                      .toUpperCase()
                  : user.name.trim().split(' ')[0][0].toUpperCase()
              : 'U';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.accent,
                    child: Text(
                      initials,
                      style: customText(48, FontWeight.w800, color: AppColors.brand),
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                buildProfileField(
                  label: "Name",
                  value: user.name.isNotEmpty ? user.name : "Unknown",
                  icon: HugeIcons.strokeRoundedUserCircle,
                ),

                buildProfileField(
                  label: "Email",
                  value: user.email.isNotEmpty ? user.email : "Unknown",
                  icon: HugeIcons.strokeRoundedMail02,
                ),

                buildProfileField(
                  label: "Phone Number",
                  value: user.phone.isNotEmpty ? user.phone : "Add Phone Number",
                  icon: HugeIcons.strokeRoundedCall02,
                  showEdit: true,
                  onEdit: () => controller.changePhone(user),
                  valueColor: user.phone.isEmpty ? AppColors.grey : AppColors.textPrimary,
                ),

                buildDeleteAccountButton(controller),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildProfileField({
    required String label,
    required String value,
    required dynamic icon,
    bool showEdit = false,
    VoidCallback? onEdit,
    Color valueColor = AppColors.textPrimary,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          HugeIcon(icon: icon, color: AppColors.textPrimary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: mediumText(12, color: AppColors.grey)),
                Text(value, style: semiBoldText(16, color: valueColor)),
              ],
            ),
          ),
          if (showEdit)
            IconButton(
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedEdit04,
                color: AppColors.brand,
                size: 20,
              ),
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }

  Widget buildDeleteAccountButton(ProfileController controller) {
    return GestureDetector(
      onTap: controller.handleDeleteAccount,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
        ),
        child: Text(
          "Delete Account",
          style: semiBoldText(16, color: AppColors.error),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
