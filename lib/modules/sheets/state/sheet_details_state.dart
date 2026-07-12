import 'package:budgetly/core/import_to_export.dart';
import 'package:intl/intl.dart';

class SheetDetailsState {
  final String sheetId;
  final String sheetName;
  final List<SheetRecord> records;
  final String filterType;

  // Pre-computed fields
  final List<SheetRecord> filteredRecords;
  final Map<String, List<SheetRecord>> groupedRecords;
  final double totalIncome;
  final double totalExpense;
  final double netBalance;
  final bool isProfit;

  SheetDetailsState({
    required this.sheetId,
    required this.sheetName,
    required this.records,
    required this.filterType,
  })  : filteredRecords = _computeFilteredRecords(records, filterType),
        groupedRecords = _computeGroupedRecords(records, filterType),
        totalIncome = _computeTotalIncome(records),
        totalExpense = _computeTotalExpense(records),
        netBalance = _computeTotalIncome(records) - _computeTotalExpense(records),
        isProfit = (_computeTotalIncome(records) - _computeTotalExpense(records)) >= 0;

  static List<SheetRecord> _computeFilteredRecords(List<SheetRecord> records, String filterType) {
    if (filterType == 'all') return records;
    final type = filterType == 'income' ? RecordType.income : RecordType.expense;
    return records.where((r) => r.type == type).toList();
  }

  static Map<String, List<SheetRecord>> _computeGroupedRecords(List<SheetRecord> records, String filterType) {
    final filtered = _computeFilteredRecords(records, filterType);
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

  static double _computeTotalIncome(List<SheetRecord> records) {
    double total = 0.0;
    for (final r in records) {
      if (r.isIncome) total += r.amount;
    }
    return total;
  }

  static double _computeTotalExpense(List<SheetRecord> records) {
    double total = 0.0;
    for (final r in records) {
      if (r.isExpense) total += r.amount;
    }
    return total;
  }
}
