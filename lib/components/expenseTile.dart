import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/Expense.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final Category category;

  const ExpenseTile({super.key, required this.expense, required this.category});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final dateFormatter = DateFormat('dd MMM');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Text(
          category.emoji ?? '📦',
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(expense.detail.isEmpty ? category.name : expense.detail,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Row(
          children: [
            Text(dateFormatter.format(expense.date),),
            if(expense.detail.isNotEmpty)
             Text(" | "),
            if(expense.detail.isNotEmpty)
             Text(" ${category.name}", style: TextStyle(fontWeight: FontWeight.w700),)
          ],
        ),
        trailing: Text(
          formatter.format(expense.price),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
