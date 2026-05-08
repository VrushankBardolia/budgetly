import 'package:budgetly/core/import_to_export.dart';

class Sheet {
  final String id;
  final String userId;
  final String name;
  final int year;
  final List<SheetRecord> records;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Sheet({
    required this.id,
    required this.userId,
    required this.name,
    required this.year,
    required this.records,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Sheet.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, [
    List<SheetRecord>? injectedRecords,
  ]) {
    final data = doc.data()!;
    return Sheet(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      year: data['year'] ?? DateTime.now().year,
      records:
          injectedRecords ??
          (data['records'] as List<dynamic>?)?.map((r) => SheetRecord.fromFirestore(r)).toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'name': name,
    'year': year,
    'records': records.map((r) => r.toFirestore()).toList(),
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
