import 'package:budgetly/core/import_to_export.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories();
  Future<void> addCategory(String name, String emoji);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
  Future<void> deleteUserCategories();
  Future<double> getCategoryTotal(String categoryId);
  Future<int> getCategoryTransactionCount(String categoryId);
}

class FirebaseCategoryRepository implements CategoryRepository {
  @override
  Future<List<Category>> getCategories() {
    return FirebaseHelper.getCategories();
  }

  @override
  Future<void> addCategory(String name, String emoji) {
    return FirebaseHelper.addCategory(name, emoji);
  }

  @override
  Future<void> updateCategory(Category category) {
    return FirebaseHelper.updateCategory(category);
  }

  @override
  Future<void> deleteCategory(String id) {
    return FirebaseHelper.deleteCategory(id);
  }

  @override
  Future<void> deleteUserCategories() {
    return FirebaseHelper.deleteUserCategories();
  }

  @override
  Future<double> getCategoryTotal(String categoryId) {
    return FirebaseHelper.getCategoryTotal(categoryId);
  }

  @override
  Future<int> getCategoryTransactionCount(String categoryId) {
    return FirebaseHelper.getCategoryTransactionCount(categoryId);
  }
}

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return FirebaseCategoryRepository();
});
