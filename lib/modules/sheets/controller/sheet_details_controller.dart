import 'package:budgetly/core/import_to_export.dart';

class SheetDetailsController extends GetxController {
  // ─── Arguments ────────────────────────────────────────────────────────────
  late final String sheetId;
  late final String sheetName;

  // ─── Reactive State ───────────────────────────────────────────────────────
  final RxList<SheetRecord> records = <SheetRecord>[].obs;
  final RxBool isLoading = true.obs;
  final RxString filterType = 'all'.obs; // 'all' | 'income' | 'expense'

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map? ?? {};
    sheetId = args['sheetId'] ?? '';
    sheetName = args['sheetName'] ?? 'Sheet';
    loadRecords();
  }

  // ─── Data ─────────────────────────────────────────────────────────────────

  Future<void> loadRecords({bool isRefresh = false}) async {
    isRefresh ? null : isLoading.value = true;
    try {
      final snapshot = await FirebaseHelper.getRecords(sheetId);
      records.assignAll(snapshot.docs.map((doc) => SheetRecord.fromFirestore(doc)).toList());
    } finally {
      isRefresh ? null : isLoading.value = false;
    }
  }

  // ─── Filter ───────────────────────────────────────────────────────────────

  void setFilter(String type) => filterType.value = type;

  List<SheetRecord> get filteredRecords {
    if (filterType.value == 'all') return records;
    final type = filterType.value == 'income' ? RecordType.income : RecordType.expense;
    return records.where((r) => r.type == type).toList();
  }

  // ─── Navigation ───────────────────────────────────────────────────────────

  Future<void> goToAddRecord() async {
    final result = await Get.toNamed(Routes.SHEET_RECORD_FORM, arguments: {'sheetId': sheetId});
    if (result == true) await loadRecords();
  }

  Future<void> goToEditRecord(SheetRecord record) async {
    final result = await Get.toNamed(
      Routes.SHEET_RECORD_FORM,
      arguments: {'sheetId': sheetId, 'record': record},
    );
    if (result == true) await loadRecords();
  }

  // ─── Delete ───────────────────────────────────────────────────────────────

  Future<void> showDeleteDialog(String recordId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Record', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete this record?',
          style: GoogleFonts.plusJakartaSans(color: Colors.grey),
        ),
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
      await FirebaseHelper.deleteRecord(sheetId, recordId);
      await loadRecords();
    }
  }

  // ─── Summary Getters ──────────────────────────────────────────────────────

  double get totalIncome => records.where((r) => r.isIncome).fold(0.0, (sum, r) => sum + r.amount);

  double get totalExpense =>
      records.where((r) => r.isExpense).fold(0.0, (sum, r) => sum + r.amount);

  double get netBalance => totalIncome - totalExpense;

  bool get isProfit => netBalance >= 0;
}
