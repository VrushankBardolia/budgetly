import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../provider/ExpenseProvider.dart';
import 'monthDetailsScreen.dart';

class MonthsTab extends StatelessWidget {
  const MonthsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color(0xFF121212);
    final Color cardColor = const Color(0xFF1E1E1E);
    final Color primaryColor = const Color(0xFF2196F3);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text('Monthly Overview',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, _) {
          final selectedYear = expenseProvider.selectedYear;
          final now = DateTime.now();

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.3, // Slightly adjusted for better fit
            ),
            itemCount: 12,
            itemBuilder: (ctx, index) {
              final month = index + 1;
              final monthDate = DateTime(selectedYear, month);
              final monthName = DateFormat('MMMM').format(monthDate);

              final isCurrent = monthDate.year == now.year && monthDate.month == now.month;
              final isPast = monthDate.isBefore(DateTime(now.year, now.month));

              final budget = expenseProvider.getBudgetForMonth(selectedYear, month);
              final expense = expenseProvider.getTotalExpenseForMonth(selectedYear, month);

              // --- LOGIC FOR 3 STATES ---
              final difference = budget - expense;
              final isBalanced = difference == 0;
              final isSaved = difference > 0;

              // Define Styles based on state
              Color statusColor;
              String statusLabel;
              IconData statusIcon;

              if (isBalanced) {
                statusColor = Colors.orangeAccent;
                statusLabel = "On Target";
                statusIcon = CupertinoIcons.nosign;
              } else if (isSaved) {
                statusColor = Colors.greenAccent;
                statusLabel = "Saved";
                statusIcon = CupertinoIcons.check_mark;
              } else {
                statusColor = Colors.redAccent;
                statusLabel = "Overspent";
                statusIcon = CupertinoIcons.exclamationmark;
              }

              final hasData = (isPast && budget > 0) || (isCurrent && (budget > 0 || expense > 0));

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MonthDetailScreen(year: selectedYear, month: month),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: isCurrent
                        ? Border.all(color: primaryColor, width: 2)
                        : Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(monthName,
                              style: TextStyle(
                                color: isCurrent ? primaryColor : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (hasData)
                              Icon(statusIcon, color: statusColor, size: 20)
                          ],
                        ),

                        const Spacer(),

                        if (hasData) ...[
                          Text(statusLabel, style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text('₹${difference.abs().toStringAsFixed(0)}',
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              // If balanced, fill it 100% (1.0)
                              value: budget > 0 ? (expense / budget).clamp(0.0, 1.0) : 0,
                              backgroundColor: Colors.grey[800],
                              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Spent: ₹${expense.toStringAsFixed(0)}',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ] else ...[
                          Center(
                            child: Icon(CupertinoIcons.calendar,
                              color: Colors.white.withValues(alpha: 0.1),
                              size: 40,
                            ),
                          ),
                          const Spacer(),
                          Text("No Data",
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
                          )
                        ],
                      ],
                    ),
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