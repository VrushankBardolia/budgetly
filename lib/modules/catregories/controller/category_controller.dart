import 'package:budgetly/core/import_to_export.dart';

class CategoryController extends GetxController {
  final RxList<Category> _categories = <Category>[].obs;
  final RxMap<String, double> _categoryTotals = <String, double>{}.obs;
  final RxMap<String, int> _categoryTransactionCounts = <String, int>{}.obs;

  final RxBool _isLoading = true.obs;

  List<Category> get categories => _categories;
  int get categoryCount => _categories.length;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Map<String, double> get categoryTotals => _categoryTotals;

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

  Future<void> loadCategories() async {
    _isLoading.value = true;
    final snapshot = await FirebaseHelper.getCategories();
    final categoriesList = snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
    _categories.assignAll(categoriesList);

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

    _categoryTotals.assignAll(totalsMap);
    _categoryTransactionCounts.assignAll(countsMap);

    _isLoading.value = false;
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
            onPressed: Get.back,
            child: Text('Cancel', style: regularText(14, color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && emojiController.text.isNotEmpty) {
                try {
                  await FirebaseHelper.addCategory(nameController.text, emojiController.text);
                  await loadCategories();
                  if (dialogContext.mounted) Get.back();
                } catch (e) {
                  if (dialogContext.mounted) {
                    Get.back();
                    showDialog(
                      context: dialogContext,
                      builder: (context) => AlertDialog(
                        title: Text("Error"),
                        content: Text(e.toString()),
                        actions: [TextButton(onPressed: Get.back, child: Text("Okay"))],
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

  Future<void> editCategory(BuildContext context, Category category) async {
    final nameController = TextEditingController(text: category.name);
    final emojiController = TextEditingController(text: category.emoji);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            onPressed: Get.back,
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
                  await FirebaseHelper.updateCategory(updatedCategory);
                  await loadCategories();
                  if (dialogContext.mounted) Get.back();
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
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Category', style: regularText(14, color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "$name"?\nThis cannot be undone.',
          style: regularText(14, color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('Cancel', style: regularText(14, color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseHelper.deleteCategory(id);
              await loadCategories();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Delete', style: regularText(14, color: Colors.white)),
          ),
        ],
      ),
    );
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
