import 'package:budgetly/core/import_to_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class CategoriesTab extends ConsumerWidget {
  const CategoriesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prov = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Categories', style: boldText(24, color: Colors.white)),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        actions: [
          Tooltip(
            triggerMode: TooltipTriggerMode.tap,
            showDuration: const Duration(seconds: 3),
            message: "You can make only 10 categories",
            child: Text("${prov.categoryCount}/10", style: semiBoldText(14, color: Colors.white)),
          ),
        ],
      ),
      body: _buildBody(context, prov),
      floatingActionButton: prov.categoryCount >= 10
          ? null
          : FloatingActionButton.extended(
              onPressed: () => prov.addCategory(context),
              label: const Text("Add Category"),
              icon: const Icon(Icons.add),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBody(BuildContext context, CategoryProvider prov) {
    if (prov.categories.isEmpty) return _buildEmptyState();
    if (prov.isLoading) return _buildShimmer();
    final belowPadding = prov.categoryCount == 10 ? 16.0 : 100.0;
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, 16, 16, belowPadding),
      physics: const BouncingScrollPhysics(),
      itemCount: prov.sortedCategories.length,
      itemBuilder: (context, index) {
        final category = prov.sortedCategories[index];
        final formatter = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);

        return GestureDetector(
          onLongPressStart: (details) {
            HapticFeedback.heavyImpact();
            showPullDownMenu(
              context: context,
              routeTheme: const PullDownMenuRouteTheme(
                backgroundColor: AppColors.surfaceLight,
                width: 201,
              ),
              items: [
                PullDownMenuItem(
                  onTap: () => prov.editCategory(category),
                  title: "Edit",
                  icon: CupertinoIcons.pen,
                  itemTheme: PullDownMenuItemTheme(textStyle: regularText(14, color: Colors.white)),
                ),
                PullDownMenuItem(
                  onTap: () => prov.deleteCategory(context, category.id, category.name),
                  title: "Delete",
                  icon: CupertinoIcons.delete,
                  isDestructive: true,
                  itemTheme: PullDownMenuItemTheme(textStyle: regularText(14, color: Colors.white)),
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
          child: CategoryTile(
            emoji: category.emoji,
            name: category.name,
            showProgress: false,
            formattedAmount: formatter.format(prov.getCategoryTotal(category.id)),
            transactionCount: prov.getTransactionCount(category.id),
            onTap: () =>
                appRouter.pushNamed(Routes.CATEGORY_DETAILS, extra: {'category': category}),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
            child: Icon(Icons.category_outlined, size: 60, color: Colors.grey[700]),
          ),
          const SizedBox(height: 24),
          Text('No categories yet', style: boldText(18, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Add categories to track expenses', style: regularText(14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("", style: semiBoldText(16)),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 50,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
