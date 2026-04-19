import 'package:budgetly/core/import_to_export.dart';
import 'package:intl/intl.dart';

class SheetsTab extends GetView<SheetsController> {
  const SheetsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sheets', style: boldText(24))),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.sheets.isEmpty) {
          return buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadSheets(isRefresh: true),
          color: AppColors.brand,
          backgroundColor: AppColors.surface,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            itemCount: controller.sheets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) => buildSheetCard(controller.sheets[index]),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.showCreateSheetDialog,
        backgroundColor: AppColors.brandDark,
        label: Text('New Sheet', style: regularText(14)),
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.brand.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedFile02,
                size: 56,
                color: AppColors.brand,
              ),
            ),
            const SizedBox(height: 28),
            Text('No Sheets Yet', style: boldText(22)),
            const SizedBox(height: 10),
            Text(
              'Create a sheet to track your annual\nincome and expenses in one place.',
              textAlign: TextAlign.center,
              style: regularText(14, color: AppColors.grey, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSheetCard(Sheet sheet) {
    return GestureDetector(
      onTap: () => controller.goToSheet(sheet),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.brand.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: HugeIcon(icon: HugeIcons.strokeRoundedFile02, color: AppColors.brand),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sheet.name, style: semiBoldText(15)),
                  const SizedBox(height: 3),
                  Text(
                    '${sheet.year}  ·  Created ${DateFormat('dd MMM yyyy').format(sheet.createdAt)}',
                    style: regularText(12, color: AppColors.grey),
                  ),
                ],
              ),
            ),

            // Menu
            PopupMenuButton<String>(
              color: AppColors.surfaceLight,
              icon: Icon(Icons.more_vert_rounded, color: Colors.grey[500], size: 20),
              onSelected: (value) {
                HapticFeedback.lightImpact();
                if (value == 'rename') {
                  controller.showRenameDialog(sheet);
                } else if (value == 'delete') {
                  controller.showDeleteDialog(sheet);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'rename',
                  child: Row(
                    children: [
                      const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                      const SizedBox(width: 10),
                      Text('Rename', style: regularText(14)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_rounded, size: 16, color: AppColors.error),
                      const SizedBox(width: 10),
                      Text('Delete', style: regularText(14, color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
