import 'package:budgetly/core/import_to_export.dart';

abstract class SheetRepository {
  Future<List<Sheet>> getSheets();
  Future<void> addSheet(Map<String, dynamic> sheetData);
  Future<void> updateSheet(String sheetId, Map<String, dynamic> sheetData);
  Future<void> deleteSheet(String sheetId);
  Future<List<SheetRecord>> getRecords(String sheetId);
  Future<void> addRecord(String sheetId, Map<String, dynamic> record);
  Future<void> updateRecord(String sheetId, String recordId, Map<String, dynamic> data);
  Future<void> deleteRecord(String sheetId, String recordId);
}

class FirebaseSheetRepository implements SheetRepository {
  @override
  Future<List<Sheet>> getSheets() {
    return FirebaseHelper.getSheets();
  }

  @override
  Future<void> addSheet(Map<String, dynamic> sheetData) {
    return FirebaseHelper.addSheet(sheetData);
  }

  @override
  Future<void> updateSheet(String sheetId, Map<String, dynamic> sheetData) {
    return FirebaseHelper.updateSheet(sheetId, sheetData);
  }

  @override
  Future<void> deleteSheet(String sheetId) {
    return FirebaseHelper.deleteSheet(sheetId);
  }

  @override
  Future<List<SheetRecord>> getRecords(String sheetId) {
    return FirebaseHelper.getRecords(sheetId);
  }

  @override
  Future<void> addRecord(String sheetId, Map<String, dynamic> record) {
    return FirebaseHelper.addRecord(sheetId, record);
  }

  @override
  Future<void> updateRecord(String sheetId, String recordId, Map<String, dynamic> data) {
    return FirebaseHelper.updateRecord(sheetId, recordId, data);
  }

  @override
  Future<void> deleteRecord(String sheetId, String recordId) {
    return FirebaseHelper.deleteRecord(sheetId, recordId);
  }
}

final sheetRepositoryProvider = Provider<SheetRepository>((ref) {
  return FirebaseSheetRepository();
});
