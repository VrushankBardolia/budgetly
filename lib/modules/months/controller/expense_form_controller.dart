import 'package:budgetly/core/import_to_export.dart';
import 'package:intl/intl.dart';

class ExpenseFormController extends GetxController {
  // ─── Arguments via GetX ───────────────────────────────────────────────────
  final int year = Get.arguments['year'] ?? DateTime.now().year;
  final int month = Get.arguments['month'] ?? DateTime.now().month;
  final Expense? editingExpense = Get.arguments['expense'];

  // ─── Text Controllers ─────────────────────────────────────────────────────
  final priceController = TextEditingController();
  final detailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // ─── Reactive State ───────────────────────────────────────────────────────
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final RxString selectedCategoryId = ''.obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;

  bool get isEditing => editingExpense != null;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _initState();
  }

  @override
  void onClose() {
    priceController.dispose();
    detailController.dispose();
    super.onClose();
  }

  // ─── Init ─────────────────────────────────────────────────────────────────

  Future<void> _initState() async {
    isLoading.value = true;
    await _loadCategories();

    if (isEditing) {
      priceController.text = editingExpense!.price.toInt().toString();
      detailController.text = editingExpense!.detail;
      selectedDate.value = editingExpense!.date;
      selectedCategoryId.value = editingExpense!.categoryId;
    } else {
      final today = DateTime.now().day;
      final daysInMonth = DateTime(year, month + 1, 0).day;
      selectedDate.value = DateTime(year, month, today.clamp(1, daysInMonth));
    }

    isLoading.value = false;
  }

  Future<void> _loadCategories() async {
    final snapshot = await FirebaseHelper.getCategories();
    categories.assignAll(
      snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList(),
    );
  }

  // ─── Field Actions ────────────────────────────────────────────────────────

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDate.value ?? DateTime(year, month),
      firstDate: DateTime(year, month, 1),
      lastDate: DateTime.now(),
    );
    if (picked != null) selectedDate.value = picked;
  }

  void setCategory(String id) => selectedCategoryId.value = id;

  // ─── Validation ───────────────────────────────────────────────────────────

  String? validatePrice(String? value) {
    if (value == null || value.isEmpty) return 'Please enter price';
    if (double.tryParse(value) == null) return 'Please enter a valid number';
    return null;
  }

  String? validateCategory(String? value) {
    if (value == null || value.isEmpty) return 'Please select a category';
    return null;
  }

  // ─── Submit ───────────────────────────────────────────────────────────────

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    isSubmitting.value = true;
    try {
      final expense = Expense(
        id: editingExpense?.id ?? '',
        date: selectedDate.value!,
        price: double.parse(priceController.text),
        categoryId: selectedCategoryId.value,
        detail: detailController.text.trim(),
        userId: PreferenceHelper.userId,
      );

      if (isEditing) {
        await FirebaseHelper.updateExpense(editingExpense!.id, expense);
      } else {
        await FirebaseHelper.addExpense(expense);
      }
      Get.back(result: true);
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─── Derived Getters ─────────────────────────────────────────────────────

  String get formattedSelectedDate => selectedDate.value != null
      ? DateFormat('MMM dd, yyyy').format(selectedDate.value!)
      : 'Select date';

  String get title => isEditing ? 'Edit Expense' : 'Add Expense';
  String get submitLabel => isEditing ? 'Update Expense' : 'Add Expense';
}
