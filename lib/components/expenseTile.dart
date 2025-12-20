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
    final dateFormatter = DateFormat('MMM dd');

    // Logic: If user added a detail note, that becomes the title,
    // and Category name moves to subtitle.
    // If no note, Category name is the title.
    final hasDetail = expense.detail.isNotEmpty;
    final title = hasDetail ? expense.detail : category.name;

    // Theme Colors (Matching your app)
    final cardColor = const Color(0xFF1E1E1E);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Emoji Badge
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color(0xFF121212),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(category.emoji, style: const TextStyle(fontSize: 24)),
          ),

          const SizedBox(width: 16),

          // 2. Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    // fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      dateFormatter.format(expense.date),
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (hasDetail) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(Icons.circle, size: 4, color: Colors.grey),
                      ),
                      Flexible(
                        child: Text(category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // 3. Price
          Text(formatter.format(expense.price),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.white,
              // Option: Use primaryColor if you want the price to pop more
              // color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}