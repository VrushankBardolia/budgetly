import 'package:budgetly/core/import_to_export.dart';

class CategoriesState {
  final List<Category> categories;
  final Map<String, double> categoryTotals;
  final Map<String, int> categoryTransactionCounts;

  // Pre-computed fields
  final int categoryCount;
  final List<Category> sortedCategories;

  CategoriesState({
    required this.categories,
    required this.categoryTotals,
    required this.categoryTransactionCounts,
  })  : categoryCount = categories.length,
        sortedCategories = _computeSortedCategories(categories, categoryTotals);

  static List<Category> _computeSortedCategories(
    List<Category> categories,
    Map<String, double> categoryTotals,
  ) {
    return categories.toList()
      ..sort((a, b) {
        final amountA = categoryTotals[a.id] ?? 0.0;
        final amountB = categoryTotals[b.id] ?? 0.0;
        return amountB.compareTo(amountA);
      });
  }

  double getCategoryTotal(String categoryId) {
    return categoryTotals[categoryId] ?? 0.0;
  }

  int getTransactionCount(String categoryId) {
    return categoryTransactionCounts[categoryId] ?? 0;
  }

  Category? getCategoryById(String id) {
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }
}
