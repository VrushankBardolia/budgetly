import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../provider/ExpenseProvider.dart';
import 'monthDetailsScreen.dart';

class MonthsTab extends StatelessWidget {
  const MonthsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Months')),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, _) {
          final selectedYear = expenseProvider.selectedYear;
          final now = DateTime.now();
          final formatter = NumberFormat.currency(symbol: '₹');

          // return ListView.builder(
          //   padding: const EdgeInsets.all(16),
          //   itemCount: 12,
          //   itemBuilder: (context, index) {
          //     final month = index + 1;
          //     final monthDate = DateTime(selectedYear, month);
          //     final monthName = DateFormat('MMMM').format(monthDate);
          //     final isPast = monthDate.isBefore(DateTime(now.year, now.month));
          //     final isCurrent =
          //         monthDate.year == now.year && monthDate.month == now.month;
          //
          //     final budget = expenseProvider.getBudgetForMonth(
          //       selectedYear,
          //       month,
          //     );
          //     final expense = expenseProvider.getTotalExpenseForMonth(
          //       selectedYear,
          //       month,
          //     );
          //     final difference = budget - expense;
          //
          //     return Card(
          //       margin: const EdgeInsets.only(bottom: 12),
          //       child: ListTile(
          //         title: Text(monthName),
          //         // subtitle:
          //         //     ((isPast && budget > 0) || (isCurrent && expense > 0))
          //         //     ? Text(
          //         //         'Budget: ${formatter.format(budget)} | '
          //         //         'Spent: ${formatter.format(expense)} | '
          //         //         'Difference: ${formatter.format(difference)}',
          //         //       )
          //         //     : null,
          //
          //         trailing: ((isPast && budget > 0) || (isCurrent && expense > 0))
          //             ? Text("₹${difference.ceil().abs()}",
          //                 style: TextStyle(
          //                   color: difference >= 0 ? Colors.green: Colors.redAccent,
          //                   fontWeight: FontWeight.w700,
          //                   fontSize: 16,
          //                 ),
          //               )
          //             : Text("-"),
          //         onTap: () {
          //           Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //               builder: (_) =>
          //                   MonthDetailScreen(year: selectedYear, month: month),
          //             ),
          //           );
          //         },
          //       ),
          //     );
          //   },
          // );
          return GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 100,
              crossAxisSpacing: 12,
            ),
            itemCount: 12,
            itemBuilder: (ctx, index){
              final month = index + 1;
              final monthDate = DateTime(selectedYear, month);
              final monthName = DateFormat('MMMM').format(monthDate);
              final isPast = monthDate.isBefore(DateTime(now.year, now.month));
              final isCurrent =
                  monthDate.year == now.year && monthDate.month == now.month;

              final budget = expenseProvider.getBudgetForMonth(
                selectedYear,
                month,
              );
              final expense = expenseProvider.getTotalExpenseForMonth(
                selectedYear,
                month,
              );
              final difference = budget - expense;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MonthDetailScreen(year: selectedYear, month: month),
                    ),
                  );
                },
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(monthName),
                      if((isPast && budget > 0) || (isCurrent && expense > 0))
                        Text("₹${difference.ceil().abs()}",
                          style: TextStyle(
                            color: difference >= 0 ? Colors.green: Colors.redAccent,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
