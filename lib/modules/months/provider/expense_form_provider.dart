import 'package:budgetly/core/import_to_export.dart';
import 'package:intl/intl.dart';

class ExpenseFormProvider extends ChangeNotifier {
  final Ref ref;

  // ─── Arguments via constructor ───────────────────────────────────────────────────
  final int year;
  final int month;
  final Expense? editingExpense;

  // ─── Text Controllers ─────────────────────────────────────────────────────
  final priceController = TextEditingController();
  final detailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // ─── State ───────────────────────────────────────────────────────
  DateTime? selectedDate;
  String selectedCategoryId = '';
  List<Category> categories = [];
  bool isLoading = true;
  bool isSubmitting = false;

  bool get isEditing => editingExpense != null;

  ExpenseFormProvider(this.ref, Map args)
    : year = args['year'] ?? DateTime.now().year,
      month = args['month'] ?? DateTime.now().month,
      editingExpense = args['expense'] {
    _initState();
  }

  @override
  void dispose() {
    priceController.dispose();
    detailController.dispose();
    super.dispose();
  }

  // ─── Init ─────────────────────────────────────────────────────────────────

  Future<void> _initState() async {
    isLoading = true;
    notifyListeners();
    await _loadCategories();

    if (isEditing) {
      priceController.text = editingExpense!.price.toInt().toString();
      detailController.text = editingExpense!.detail;
      selectedDate = editingExpense!.date;
      selectedCategoryId = editingExpense!.categoryId;
    } else {
      final today = DateTime.now().day;
      final daysInMonth = DateTime(year, month + 1, 0).day;
      selectedDate = DateTime(year, month, today.clamp(1, daysInMonth));
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _loadCategories() async {
    final result = await FirebaseHelper.getCategories();
    categories = result;
    notifyListeners();
  }

  // ─── Field Actions ────────────────────────────────────────────────────────

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: appContext!,
      initialDate: selectedDate ?? DateTime(year, month),
      firstDate: DateTime(year, month, 1),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      selectedDate = picked;
      notifyListeners();
    }
  }

  void setCategory(String id) {
    selectedCategoryId = id;
    notifyListeners();
  }

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

    isSubmitting = true;
    notifyListeners();
    try {
      final expense = Expense(
        id: editingExpense?.id ?? '',
        date: selectedDate!,
        price: double.parse(priceController.text),
        categoryId: selectedCategoryId,
        detail: detailController.text.trim(),
        userId: PreferenceHelper.userId,
      );

      if (isEditing) {
        await FirebaseHelper.updateExpense(editingExpense!.id, expense);
      } else {
        await FirebaseHelper.addExpense(expense);
      }
      ref.read(dashboardProvider).loadData();
      appRouter.pop(true);
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  // ─── Derived Getters ─────────────────────────────────────────────────────

  String get formattedSelectedDate =>
      selectedDate != null ? DateFormat('MMM dd, yyyy').format(selectedDate!) : 'Select date';

  String get title => isEditing ? 'Edit Expense' : 'Add Expense';
  String get submitLabel => isEditing ? 'Update Expense' : 'Add Expense';
}
