import 'package:budgetly/core/import_to_export.dart';

class CategoryProvider extends ChangeNotifier {
  final Ref ref;

  List<Category> _categories = [];
  Map<String, double> _categoryTotals = {};
  Map<String, int> _categoryTransactionCounts = {};
  bool _isLoading = true;

  List<Category> get categories => _categories;
  int get categoryCount => _categories.length;
  bool get isLoading => _isLoading;
  Map<String, double> get categoryTotals => _categoryTotals;

  CategoryProvider(this.ref) {
    loadCategories();
  }

  List<Category> get sortedCategories {
    return _categories.toList()..sort((a, b) {
      final amountA = _categoryTotals[a.id] ?? 0.0;
      final amountB = _categoryTotals[b.id] ?? 0.0;
      return amountB.compareTo(amountA);
    });
  }

  int getTransactionCount(String categoryId) {
    return _categoryTransactionCounts[categoryId] ?? 0;
  }

  double getCategoryTotal(String categoryId) {
    return _categoryTotals[categoryId] ?? 0.0;
  }

  // MARK: Public Actions

  Future<void> loadCategories({bool isRefresh = true}) async {
    final user = FirebaseHelper.currentUser;
    if (user == null) return;

    if (isRefresh) {
      _isLoading = true;
      notifyListeners();
    }
    final result = await FirebaseHelper.getCategories();
    final categoriesList = result;
    _categories = result;

    final totalsMap = <String, double>{};
    final countsMap = <String, int>{};

    await Future.wait(
      categoriesList.map((category) async {
        final total = await FirebaseHelper.getCategoryTotal(category.id);
        final count = await FirebaseHelper.getCategoryTransactionCount(category.id);
        totalsMap[category.id] = total;
        countsMap[category.id] = count;
      }),
    );

    _categoryTotals = totalsMap;
    _categoryTransactionCounts = countsMap;

    if (isRefresh) {
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> addCategory(BuildContext context) async {
    final nameController = TextEditingController();
    final emojiController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Category', style: regularText(14)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emojiController,
              style: regularText(14, color: Colors.white),
              decoration: _inputDecoration('Emoji'),
              maxLength: 1,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              style: regularText(14, color: Colors.white),
              decoration: _inputDecoration('Name'),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: appRouter.pop,
            child: Text('Cancel', style: regularText(14, color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && emojiController.text.isNotEmpty) {
                try {
                  await FirebaseHelper.addCategory(nameController.text, emojiController.text);
                  await loadCategories();
                  if (dialogContext.mounted) appRouter.pop();
                } catch (e) {
                  if (dialogContext.mounted) {
                    appRouter.pop();
                    showDialog(
                      context: dialogContext,
                      builder: (context) => AlertDialog(
                        title: const Text("Error"),
                        content: Text(e.toString()),
                        actions: [TextButton(onPressed: appRouter.pop, child: const Text("Okay"))],
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brand,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Add', style: regularText(14, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> editCategory(Category category) async {
    final nameController = TextEditingController(text: category.name);
    final emojiController = TextEditingController(text: category.emoji);
    dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit Category', style: regularText(14, color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emojiController,
              style: regularText(14, color: Colors.white),
              decoration: _inputDecoration('Emoji'),
              maxLength: 1,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              style: regularText(14, color: Colors.white),
              decoration: _inputDecoration('Name'),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: appRouter.pop,
            child: Text('Cancel', style: regularText(14, color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && emojiController.text.isNotEmpty) {
                try {
                  final updatedCategory = Category(
                    id: category.id,
                    name: nameController.text.trim(),
                    emoji: emojiController.text.trim(),
                    userId: category.userId,
                  );
                  appRouter.pop();
                  await FirebaseHelper.updateCategory(updatedCategory);
                  await loadCategories(isRefresh: false);
                } catch (e) {
                  // Error handling
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brand,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Save', style: regularText(14, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> deleteCategory(BuildContext context, String id, String name) async {
    final confirmed = await confirmationDialog(
      context: context,
      title: 'Delete Category',
      message: 'Are you sure you want to delete "$name"?\nThis cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed) {
      await FirebaseHelper.deleteCategory(id);
      await loadCategories();
    }
  }

  // MARK: Helpers

  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      labelStyle: regularText(14, color: Colors.grey),
      hintStyle: regularText(14, color: Colors.grey.withValues(alpha: 0.5)),
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.brand, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
