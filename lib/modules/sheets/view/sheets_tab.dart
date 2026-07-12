import 'package:budgetly/core/import_to_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class SheetsTab extends ConsumerWidget {
  const SheetsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(sheetsStateProvider);
    final controller = ref.read(sheetsControllerProvider);

    return stateAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text('Sheets', style: serifText(20))),
        body: buildShimmerLoader(),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: Text('Sheets', style: serifText(20))),
        body: Center(child: Text('Error loading sheets: $err')),
      ),
      data: (state) => Scaffold(
        appBar: AppBar(title: Text('Sheets', style: serifText(20))),
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(sheetsListProvider);
            ref.invalidate(totalSheetsBalanceProvider);
          },
          color: AppColors.brand,
          child: state.sheets.isEmpty
              ? buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  physics: const BouncingScrollPhysics(),
                  itemCount: state.sheets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) => buildSheetCard(context, controller, state, state.sheets[index]),
                ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.showCreateSheetDialog,
          backgroundColor: AppColors.brandDark,
          label: Text('New Sheet', style: regularText(14, color: AppColors.surface)),
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.brand.withValues(alpha: 0.03),
                  ),
                ),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.brand.withValues(alpha: 0.06),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.brand.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedFile02,
                    size: 40,
                    color: AppColors.brand,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('No Sheets Yet', style: boldText(22)),
            const SizedBox(height: 12),
            Text(
              'Create a sheet to track your annual\nincome and expenses in one place.',
              textAlign: TextAlign.center,
              style: regularText(15, color: AppColors.grey.withValues(alpha: 0.8), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSheetCard(BuildContext context, SheetsController controller, SheetsState state, Sheet sheet) {
    return GestureDetector(
      onTap: () => appRouter.pushNamed(
        Routes.SHEET_DETAIL,
        extra: {'sheetId': sheet.id, 'sheetName': sheet.name},
      ),
      onLongPressStart: (details) {
        showPullDownMenu(
          context: context,
          routeTheme: const PullDownMenuRouteTheme(
            backgroundColor: AppColors.surfaceLight,
            width: 200,
          ),
          items: [
            PullDownMenuItem(
              onTap: () => controller.showRenameDialog(sheet),
              title: "Rename",
              icon: CupertinoIcons.pen,
              itemTheme: PullDownMenuItemTheme(textStyle: mediumText(14)),
            ),
            PullDownMenuItem(
              onTap: () => controller.showDeleteDialog(sheet),
              title: "Delete",
              icon: CupertinoIcons.delete,
              isDestructive: true,
              itemTheme: PullDownMenuItemTheme(textStyle: mediumText(14)),
            ),
          ],
          position: Rect.fromLTRB(
            details.globalPosition.dx,
            details.globalPosition.dy,
            details.globalPosition.dx,
            details.globalPosition.dy,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppColors.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                HugeIcon(icon: HugeIcons.strokeRoundedFile02, color: AppColors.brand, size: 20),
                const SizedBox(width: 8),

                // Sheet Name
                Expanded(
                  child: Text(
                    sheet.name,
                    style: semiBoldText(18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text("${sheet.year}", style: mediumText(14, color: AppColors.brand)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              spacing: 8,
              children: [
                _buildBalanceText(state.sheetBalances[sheet.id], sheet),
                Text(
                  "TOTAL\nBALANCE",
                  style: mediumText(
                    11,
                    color: AppColors.grey,
                    height: 1,
                  ).copyWith(letterSpacing: 1.2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceText(double? balance, Sheet sheet) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    if (balance == null) {
      return Text(
        formatter.format(0),
        style: boldText(28, color: AppColors.grey).copyWith(letterSpacing: -1),
      );
    }

    final color = balance >= 0 ? AppColors.success : AppColors.error;
    return Text(
      formatter.format(balance),
      style: boldText(28, color: color, height: 1).copyWith(letterSpacing: -1),
    );
  }

  Widget buildShimmerLoader() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => buildShimmerCard(),
    );
  }

  Widget buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceLight,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 50,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 12,
              width: 100,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 32,
              width: 150,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
