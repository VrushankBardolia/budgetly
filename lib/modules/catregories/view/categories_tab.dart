import 'package:budgetly/core/import_to_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class CategoriesTab extends GetView<CategoryController> {
  const CategoriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: AppColors.black,
        appBar: AppBar(
          backgroundColor: AppColors.black,
          elevation: 0,
          title: Text('Categories', style: boldText(24, color: Colors.white)),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),
          actions: [
            Tooltip(
              triggerMode: TooltipTriggerMode.tap,
              showDuration: Duration(seconds: 3),
              message: "You can make only 10 categories",
              child: Text(
                "${controller.categoryCount.toString()}/10",
                style: semiBoldText(14, color: Colors.white),
              ),
            ),
          ],
        ),
        body: _buildBody(),
        floatingActionButton: controller.categoryCount >= 10
            ? null
            : FloatingActionButton.extended(
                onPressed: () => controller.addCategory(context),
                label: const Text("Add Category"),
                icon: const Icon(Icons.add),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    });
  }

  Widget _buildBody() {
    if (controller.categories.isEmpty) return _buildEmptyState();
    final belowPadding = controller.categoryCount == 10 ? 16.0 : 100.0;
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, 16, 16, belowPadding),
      physics: const BouncingScrollPhysics(),
      itemCount: controller.sortedCategories.length,
      itemBuilder: (context, index) {
        final category = controller.sortedCategories[index];
        final formatter = NumberFormat.simpleCurrency(
          locale: 'en_IN',
          decimalDigits: 0,
        );

        return GestureDetector(
          onLongPressStart: (details) {
            HapticFeedback.heavyImpact();
            showPullDownMenu(
              context: context,
              routeTheme: PullDownMenuRouteTheme(
                backgroundColor: AppColors.surfaceLight,
                width: 201,
              ),
              items: [
                PullDownMenuItem(
                  onTap: () => controller.editCategory(context, category),
                  title: "Edit",
                  icon: CupertinoIcons.pen,
                  itemTheme: PullDownMenuItemTheme(
                    textStyle: regularText(14, color: Colors.white),
                  ),
                ),
                PullDownMenuItem(
                  onTap: () => controller.deleteCategory(
                    context,
                    category.id,
                    category.name,
                  ),
                  title: "Delete",
                  icon: CupertinoIcons.delete,
                  isDestructive: true,
                  itemTheme: PullDownMenuItemTheme(
                    textStyle: regularText(14, color: Colors.white),
                  ),
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
            formattedAmount: formatter.format(
              controller.getCategoryTotal(category.id),
            ),
            transactionCount: controller.getTransactionCount(category.id),
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
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.category_outlined,
              size: 60,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 24),
          Text('No categories yet', style: boldText(18, color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            'Add categories to track expenses',
            style: regularText(14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
