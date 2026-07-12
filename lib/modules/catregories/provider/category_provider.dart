import 'package:budgetly/core/import_to_export.dart';

// ─── Asynchronous Data Providers ─────────────────────────────────────────────

/// Fetches and caches the user's categories.
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getCategories();
});

/// Fetches and caches totals spent in each category.
final categoryTotalsProvider = FutureProvider<Map<String, double>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  final categoriesList = await ref.watch(categoriesProvider.future);
  final Map<String, double> totalsMap = {};
  await Future.wait(
    categoriesList.map((category) async {
      final total = await repo.getCategoryTotal(category.id);
      totalsMap[category.id] = total;
    }),
  );
  return totalsMap;
});

/// Fetches and caches transaction counts in each category.
final categoryTransactionCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  final categoriesList = await ref.watch(categoriesProvider.future);
  final Map<String, int> countsMap = {};
  await Future.wait(
    categoriesList.map((category) async {
      final count = await repo.getCategoryTransactionCount(category.id);
      countsMap[category.id] = count;
    }),
  );
  return countsMap;
});

// ─── Combined Categories State Provider ──────────────────────────────────────

final categoriesStateProvider = Provider<AsyncValue<CategoriesState>>((ref) {
  final asyncValues = [
    ref.watch(categoriesProvider),
    ref.watch(categoryTotalsProvider),
    ref.watch(categoryTransactionCountsProvider),
  ];

  for (final value in asyncValues) {
    if (value.isLoading) return const AsyncValue.loading();
    if (value.hasError) return AsyncValue.error(value.error!, value.stackTrace!);
  }

  return AsyncValue.data(
    CategoriesState(
      categories: (asyncValues[0] as AsyncValue<List<Category>>).value ?? [],
      categoryTotals: (asyncValues[1] as AsyncValue<Map<String, double>>).value ?? {},
      categoryTransactionCounts: (asyncValues[2] as AsyncValue<Map<String, int>>).value ?? {},
    ),
  );
});

// ─── Category Action Controller ──────────────────────────────────────────────

final categoryControllerProvider = Provider<CategoryController>((ref) {
  return CategoryController(ref);
});

class CategoryController {
  final Ref ref;
  CategoryController(this.ref);

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
                  final categoryRepo = ref.read(categoryRepositoryProvider);
                  await categoryRepo.addCategory(nameController.text, emojiController.text);
                  _invalidateAll();
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
                  final categoryRepo = ref.read(categoryRepositoryProvider);
                  await categoryRepo.updateCategory(updatedCategory);
                  _invalidateAll();
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
      final categoryRepo = ref.read(categoryRepositoryProvider);
      await categoryRepo.deleteCategory(id);
      _invalidateAll();
    }
  }

  void _invalidateAll() {
    ref.invalidate(categoriesProvider);
    ref.invalidate(categoryTotalsProvider);
    ref.invalidate(categoryTransactionCountsProvider);
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
