import 'package:budgetly/core/import_to_export.dart';

class SheetsState {
  final List<Sheet> sheets;

  // Pre-computed fields
  final Map<String, double> sheetBalances;

  SheetsState({
    required this.sheets,
  }) : sheetBalances = _computeSheetBalances(sheets);

  static Map<String, double> _computeSheetBalances(List<Sheet> sheets) {
    final balances = <String, double>{};
    for (var sheet in sheets) {
      double balance = 0;
      for (var record in sheet.records) {
        if (record.type == RecordType.income) {
          balance += record.amount;
        } else if (record.type == RecordType.expense) {
          balance -= record.amount;
        }
      }
      balances[sheet.id] = balance;
    }
    return balances;
  }
}
