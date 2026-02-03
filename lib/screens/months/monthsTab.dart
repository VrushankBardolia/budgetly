import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../../controller/expense_controller.dart';
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
        title: const Text(
          'Monthly Overview',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: Obx(() {
        final expenseController = Get.find<ExpenseController>();
        final selectedYear = expenseController.selectedYear;
        final now = DateTime.now();

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemCount: 12,
          itemBuilder: (ctx, index) {
            final month = index + 1;
            final monthDate = DateTime(selectedYear, month);
            final monthName = DateFormat('MMMM').format(monthDate);

            final isCurrent =
                monthDate.year == now.year && monthDate.month == now.month;
            final isPast = monthDate.isBefore(DateTime(now.year, now.month));

            final budget = expenseController.getBudgetForMonth(
              selectedYear,
              month,
            );
            final expense = expenseController.getTotalExpenseForMonth(
              selectedYear,
              month,
            );

            final difference = budget - expense;
            final isBalanced = difference == 0;
            final isSaved = difference > 0;

            Color statusColor;
            String statusLabel;
            dynamic statusIcon;

            if (isBalanced) {
              statusColor = Colors.orangeAccent;
              statusLabel = "On Target";
              statusIcon = HugeIcons.strokeRoundedAlert02;
            } else if (isSaved) {
              statusColor = Colors.greenAccent;
              statusLabel = isCurrent ? "Remaining" : "Saved";
              statusIcon = HugeIcons.strokeRoundedCheckmarkCircle03;
            } else {
              statusColor = Colors.redAccent;
              statusLabel = "Overspent";
              statusIcon = HugeIcons.strokeRoundedCancelCircle;
            }

            final hasData =
                (isPast && budget > 0) ||
                (isCurrent && (budget > 0 || expense > 0));

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
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          monthName,
                          style: GoogleFonts.plusJakartaSans(
                            color: isCurrent ? primaryColor : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (hasData)
                          HugeIcon(
                            icon: statusIcon,
                            color: statusColor,
                            size: 20,
                          ),
                      ],
                    ),

                    const Spacer(),

                    if (hasData) ...[
                      Text(
                        statusLabel,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '₹${difference.abs().toStringAsFixed(0)}',
                        style: GoogleFonts.plusJakartaSans(
                          color: statusColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: budget > 0
                              ? (expense / budget).clamp(0.0, 1.0)
                              : 0,
                          backgroundColor: Colors.grey[800],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            statusColor,
                          ),
                          minHeight: 4,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Spent: ₹${expense.toStringAsFixed(0)}',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ] else ...[
                      Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedCalendarMinus02,
                          strokeWidth: 1.5,
                          color: Colors.grey.shade800,
                          size: 36,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "No Data",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
