import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final DateTime date;
  final double price;
  final String categoryId;
  final String detail;
  final String userId;

  Expense({
    required this.id,
    required this.date,
    required this.price,
    required this.categoryId,
    required this.detail,
    required this.userId,
  });

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      price: (data['price'] as num).toDouble(),
      categoryId: data['categoryId'] as String,
      detail: data['detail'] as String,
      userId: data['userId'] as String,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': Timestamp.fromDate(date),
      'price': price,
      'categoryId': categoryId,
      'detail': detail,
      'userId': userId,
    };
  }
}
