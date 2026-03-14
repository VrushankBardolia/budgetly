import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../core/app_colors.dart';
import '../helper/firebase_helper.dart';
import '../model/category.dart';
import '../model/expense.dart';
import '../modules/months/add_expense_dialog.dart';
import '../modules/months/edit_expense_dialog.dart';

class MonthDetailController extends GetxController {
  // ─── Arguments via GetX ───────────────────────────────────────────────────
  final int year = Get.arguments['year'] ?? DateTime.now().year;
  final int month = Get.arguments['month'] ?? DateTime.now().month;

  // ─── Reactive State ───────────────────────────────────────────────────────
  final RxList<Expense> expenses = <Expense>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxInt budget = 0.obs;
  final RxBool isLoading = true.obs;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  void checkBudgetAndShowDialog() {
    if (!isLoading.value) {
      if (!hasBudget) showBudgetDialog();
    } else {
      once(isLoading, (bool loading) {
        if (!loading && !hasBudget && Get.isDialogOpen != true) {
          showBudgetDialog();
        }
      });
    }
  }

  // ─── Dialogs ──────────────────────────────────────────────────────────────
  Future<void> showBudgetDialog() async {
    final controllerField = TextEditingController(text: budget.value > 0 ? budget.value.toString() : '');

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Set Budget',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formattedMonth, style: TextStyle(color: AppColors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: controllerField,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 18),
              decoration: InputDecoration(
                hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey.withValues(alpha: 0.5)),
                filled: true,
                fillColor: AppColors.surfaceLight,
                prefixText: '₹',
                hintText: 'Enter amount',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.brand, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(controllerField.text.isEmpty ? 'Skip' : 'Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = int.tryParse(controllerField.text);
              if (value != null && value > 0) {
                await setBudget(value);
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brand,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Save',
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showAddExpenseDialog() async {
    Get.dialog(AddExpenseDialog(year: year, month: month), barrierDismissible: false);
    await loadExpenses();
  }

  Future<void> showEditExpenseDialog(Expense expense) async {
    Get.dialog(EditExpenseDialog(expense: expense, year: year, month: month), barrierDismissible: false);
    await loadExpenses();
  }

  Future<void> showDeleteExpenseDialog(String id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Expense', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
        content: Text('Are you sure you want to delete this expense?', style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Delete', style: GoogleFonts.plusJakartaSans(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await deleteExpense(id);
    }
  }

  // ─── Data Loading ─────────────────────────────────────────────────────────

  Future<void> loadAll() async {
    isLoading.value = true;
    await Future.wait([loadExpenses(), loadBudget(), loadCategories()]);
    isLoading.value = false;
  }

  Future<void> loadExpenses() async {
    final userId = FirebaseHelper.currentUser?.uid;
    if (userId == null) return;

    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);

    final snapshot = await FirebaseHelper.getExpenses(userId, start, end);

    expenses.assignAll(snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList());
  }

  Future<void> loadBudget() async {
    final userId = FirebaseHelper.currentUser?.uid;
    if (userId == null) return;

    final snapshot = await FirebaseHelper.getBudgetForMonth(userId, year, month);

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      budget.value = (data['budget'] as num).toInt();
    }
  }

  Future<void> loadCategories() async {
    final userId = FirebaseHelper.currentUser?.uid;
    if (userId == null) return;

    final snapshot = await FirebaseHelper.getCategories(userId);

    categories.assignAll(snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList());
  }

  // ─── Budget ───────────────────────────────────────────────────────────────

  Future<void> setBudget(int value) async {
    final userId = FirebaseHelper.currentUser?.uid;
    if (userId == null) return;

    final snapshot = await FirebaseHelper.getBudgetForMonth(userId, year, month);

    if (snapshot.docs.isEmpty) {
      Map<String, dynamic> budgetData = {'userId': userId, 'year': year, 'month': month, 'budget': value};
      await FirebaseHelper.addBudget(budgetData);
    } else {
      await FirebaseHelper.updateBudget(snapshot.docs.first.id, value);
    }

    budget.value = value;
  }

  // ─── Expenses CRUD ────────────────────────────────────────────────────────

  Future<void> addExpense(Expense expense) async {
    await FirebaseHelper.addExpense(expense);
    await loadExpenses();
  }

  Future<void> updateExpense(String id, Expense expense) async {
    await FirebaseHelper.updateExpense(id, expense);
    await loadExpenses();
  }

  Future<void> deleteExpense(String id) async {
    await FirebaseHelper.deleteExpense(id);
    await loadExpenses();
  }

  // ─── Category Helper ──────────────────────────────────────────────────────

  Category? getCategoryById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── Derived Getters ──────────────────────────────────────────────────────

  double get totalExpense => expenses.fold(0.0, (sum, e) => sum + e.price);

  double get remaining => budget.value - totalExpense;

  int get totalDays => DateTime(year, month + 1, 0).day;

  int get remainingDays {
    final diff = totalDays - DateTime.now().day + 1;
    return diff > 0 ? diff : 0;
  }

  double get remainPerDay => remainingDays > 0 ? remaining / remainingDays : 0.0;

  bool get hasBudget => budget.value > 0;

  bool get isCurrent {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  bool get isBalanced => remaining == 0;
  bool get isSaved => remaining > 0;

  Color get statusColor {
    if (isBalanced) return AppColors.warning;
    if (isSaved) return AppColors.success;
    return AppColors.error;
  }

  String get statusLabel {
    if (isBalanced) return "On Target";
    if (isSaved) return isCurrent ? "Remaining" : "Saved";
    return "Overspent";
  }

  dynamic get statusIcon {
    if (isBalanced) return HugeIcons.strokeRoundedAlert02;
    if (isSaved) return HugeIcons.strokeRoundedCheckmarkCircle03;
    return HugeIcons.strokeRoundedCancelCircle;
  }

  String get formattedMonth => DateFormat('MMMM yyyy').format(DateTime(year, month));

  NumberFormat get formatter => NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);
}
