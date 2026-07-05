import 'package:budgetly/core/import_to_export.dart';
import 'package:intl/intl.dart';

class SheetDetailsProvider extends ChangeNotifier {
  final Ref ref;

  // ─── Arguments ────────────────────────────────────────────────────────────
  final String sheetId;
  final String sheetName;

  // ─── State ───────────────────────────────────────────────────────
  List<SheetRecord> records = [];
  bool isLoading = true;
  String filterType = 'all'; // 'all' | 'income' | 'expense'

  SheetDetailsProvider(this.ref, Map args)
    : sheetId = args['sheetId'] ?? '',
      sheetName = args['sheetName'] ?? 'Sheet' {
    loadRecords();
  }

  // ─── Data ─────────────────────────────────────────────────────────────────

  Future<void> loadRecords({bool isRefresh = false}) async {
    if (!isRefresh) {
      isLoading = true;
      notifyListeners();
    }
    try {
      final recordsList = await FirebaseHelper.getRecords(sheetId);
      records = recordsList;
    } finally {
      if (!isRefresh) {
        isLoading = false;
      }
      notifyListeners();
    }
  }

  // ─── Filter ───────────────────────────────────────────────────────────────

  void setFilter(String type) {
    filterType = type;
    notifyListeners();
  }

  List<SheetRecord> get filteredRecords {
    if (filterType == 'all') return records;
    final type = filterType == 'income' ? RecordType.income : RecordType.expense;
    return records.where((r) => r.type == type).toList();
  }

  Map<String, List<SheetRecord>> get groupedRecords {
    final filtered = filteredRecords;
    final map = <String, List<SheetRecord>>{};
    for (var record in filtered) {
      final monthStr = DateFormat('MMMM').format(record.date);
      if (!map.containsKey(monthStr)) {
        map[monthStr] = [];
      }
      map[monthStr]!.add(record);
    }
    return map;
  }

  // ─── Navigation ───────────────────────────────────────────────────────────

  Future<void> goToAddRecord() async {
    final result = await appRouter.pushNamed(Routes.SHEET_RECORD_FORM, extra: {'sheetId': sheetId});
    if (result == true) await loadRecords();
  }

  Future<void> goToEditRecord(SheetRecord record) async {
    final result = await appRouter.pushNamed(
      Routes.SHEET_RECORD_FORM,
      extra: {'sheetId': sheetId, 'record': record},
    );
    if (result == true) await loadRecords();
  }

  // ─── Delete ───────────────────────────────────────────────────────────────

  Future<void> showDeleteDialog(String recordId) async {
    final confirmed = await confirmationDialog(
      title: 'Delete Record',
      message: 'Are you sure you want to delete this record?',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed) {
      await FirebaseHelper.deleteRecord(sheetId, recordId);
      await loadRecords();
    }
  }

  // ─── Summary Getters ──────────────────────────────────────────────────────

  double get totalIncome =>
      records.where((r) => r.isIncome).fold(0.0, (total, r) => total + r.amount);

  double get totalExpense =>
      records.where((r) => r.isExpense).fold(0.0, (total, r) => total + r.amount);

  double get netBalance => totalIncome - totalExpense;

  bool get isProfit => netBalance >= 0;
}
