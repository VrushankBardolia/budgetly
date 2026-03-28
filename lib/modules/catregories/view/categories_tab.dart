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
          title: Text('Categories', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 24)),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          actions: [
            Tooltip(
              triggerMode: TooltipTriggerMode.tap,
              showDuration: Duration(seconds: 3),
              message: "You can make only 10 categories",
              child: Text(
                "${controller.categoryCount.toString()}/10",
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        body: _buildBody(),
        floatingActionButton: controller.categoryCount >= 10
            ? null
            : FloatingActionButton.extended(onPressed: () => controller.addCategory(context), label: const Text("Add Category"), icon: const Icon(Icons.add)),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    });
  }

  Widget _buildBody() {
    if (controller.categories.isEmpty) return _buildEmptyState();

    final belowPadding = controller.categoryCount == 10 ? 16 : 100;
    final dashboardController = Get.find<DashboardController>();

    final Map<String, double> categoryTotals = {};
    for (var category in controller.categories) {
      categoryTotals[category.id] = 0.0;
    }

    for (var expense in dashboardController.expenses) {
      if (categoryTotals.containsKey(expense.categoryId)) {
        categoryTotals[expense.categoryId] = categoryTotals[expense.categoryId]! + expense.price;
      }
    }

    final sortedCategories = controller.categories.toList()
      ..sort((a, b) {
        final amountA = categoryTotals[a.id] ?? 0.0;
        final amountB = categoryTotals[b.id] ?? 0.0;
        return amountB.compareTo(amountA);
      });

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, 16, 16, belowPadding.toDouble()),
      physics: const BouncingScrollPhysics(),
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        final category = sortedCategories[index];
        final totalAmount = categoryTotals[category.id] ?? 0.0;

        int txCount = 0;
        for (var expense in dashboardController.expenses) {
          if (expense.categoryId == category.id) {
            txCount++;
          }
        }

        final formatter = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);

        return GestureDetector(
          onLongPressStart: (details) {
            HapticFeedback.heavyImpact();
            showPullDownMenu(
              context: context,
              routeTheme: PullDownMenuRouteTheme(backgroundColor: AppColors.surfaceLight, width: 201),
              items: [
                PullDownMenuItem(
                  onTap: () => controller.editCategory(context, category),
                  title: "Edit",
                  icon: CupertinoIcons.pen,
                  itemTheme: PullDownMenuItemTheme(textStyle: GoogleFonts.plusJakartaSans(color: Colors.white)),
                ),
                PullDownMenuItem(
                  onTap: () => controller.deleteCategory(context, category.id, category.name),
                  title: "Delete",
                  icon: CupertinoIcons.delete,
                  isDestructive: true,
                  itemTheme: PullDownMenuItemTheme(textStyle: GoogleFonts.plusJakartaSans()),
                ),
              ],
              position: Rect.fromLTRB(details.globalPosition.dx, details.globalPosition.dy, details.globalPosition.dx, details.globalPosition.dy),
            );
          },
          child: CategoryTile(emoji: category.emoji, name: category.name, showProgress: false, formattedAmount: formatter.format(totalAmount), transactionCount: txCount),
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
            decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
            child: Icon(Icons.category_outlined, size: 60, color: Colors.grey[700]),
          ),
          const SizedBox(height: 24),
          Text(
            'No categories yet',
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Add categories to track expenses', style: GoogleFonts.plusJakartaSans(color: Colors.grey[500])),
        ],
      ),
    );
  }
}
