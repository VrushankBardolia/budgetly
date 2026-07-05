import 'package:budgetly/core/import_to_export.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prov = ref.watch(profileProvider);
    final user = prov.currentUser;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: const Text(
          "Manage Profile",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.black,
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.brand))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.brandDark,
                      child: Text(
                        prov.initials,
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
                    onEdit: prov.changePhone,
                    valueColor: user.phone.isEmpty ? AppColors.grey : AppColors.white,
                  ),

                  buildDeleteAccountButton(prov),
                ],
              ),
            ),
    );
  }

  Widget buildProfileField({
    required String label,
    required String value,
    required dynamic icon,
    bool showEdit = false,
    VoidCallback? onEdit,
    Color valueColor = Colors.white,
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
          HugeIcon(icon: icon, color: Colors.white, size: 24),
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

  Widget buildDeleteAccountButton(ProfileProvider prov) {
    return GestureDetector(
      onTap: prov.handleDeleteAccount,
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
          style: semiBoldText(16, color: AppColors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
