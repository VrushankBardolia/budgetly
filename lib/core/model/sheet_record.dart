import 'package:cloud_firestore/cloud_firestore.dart';

enum RecordType { income, expense }

class SheetRecord {
  final String id;
  final DateTime date;
  final double amount;
  final RecordType type;
  final String detail;
  final DateTime createdAt;

  const SheetRecord({
    required this.id,
    required this.date,
    required this.amount,
    required this.type,
    required this.detail,
    required this.createdAt,
  });

  bool get isIncome => type == RecordType.income;
  bool get isExpense => type == RecordType.expense;

  // Changed to fromFirestore to handle standalone documents
  factory SheetRecord.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return SheetRecord(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      amount: (data['amount'] as num).toDouble(),
      type: data['type'] == 'income' ? RecordType.income : RecordType.expense,
      detail: data['detail'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'date': Timestamp.fromDate(date),
    'amount': amount,
    'type': type.name,
    'detail': detail,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
