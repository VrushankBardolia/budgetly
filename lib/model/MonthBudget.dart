import 'package:cloud_firestore/cloud_firestore.dart';

class MonthBudget {
  final String id;
  final int year;
  final int month;
  final double budget;
  final String userId;

  MonthBudget({
    required this.id,
    required this.year,
    required this.month,
    required this.budget,
    required this.userId,
  });

  factory MonthBudget.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MonthBudget(
      id: doc.id,
      year: data['year'] as int,
      month: data['month'] as int,
      budget: (data['budget'] as num).toDouble(),
      userId: data['userId'] as String,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'year': year, 'month': month, 'budget': budget, 'userId': userId};
  }
}
