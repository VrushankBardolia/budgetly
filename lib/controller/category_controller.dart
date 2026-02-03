import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../model/Category.dart';

class CategoryController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<Category> _categories = <Category>[].obs;

  List<Category> get categories => _categories;
  int get categoryCount => _categories.length;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final snapshot = await _db
        .collection('categories')
        .where('userId', isEqualTo: userId)
        .orderBy('name')
        .get();

    _categories.assignAll(
      snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList(),
    );
  }

  Future<void> addCategory(String name, String emoji) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _db.collection('categories').add({
      'name': name,
      'emoji': emoji,
      'userId': userId,
    });

    await loadCategories();
  }

  Future<void> deleteCategory(String id) async {
    await _db.collection('categories').doc(id).delete();
    await loadCategories();
  }

  Future<void> updateCategory(String id, Category category) async {
    await _db.collection('categories').doc(id).update(category.toFirestore());
    await loadCategories();
  }

  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
