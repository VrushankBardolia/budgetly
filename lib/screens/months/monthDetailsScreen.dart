import 'package:budgetly/components/expenseTile.dart';
import 'package:budgetly/model/Expense.dart';
import 'package:budgetly/screens/months/editExpenseDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../provider/CategoryProvider.dart';
import '../../provider/ExpenseProvider.dart';
import 'addExpenseDialog.dart';

class MonthDetailScreen extends StatefulWidget {
  final int year;
  final int month;

  const MonthDetailScreen({super.key, required this.year, required this.month});

  @override
  State<MonthDetailScreen> createState() => _MonthDetailScreenState();
}

class _MonthDetailScreenState extends State<MonthDetailScreen> {
  final _budgetController = TextEditingController();
  bool _isEditingBudget = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final expenseProvider = context.read<ExpenseProvider>();
      final budget = expenseProvider.getBudgetForMonth(
        widget.year,
        widget.month,
      );
      _budgetController.text = budget > 0 ? budget.toString() : '';

      if (budget == 0) {
        _showBudgetDialog();
      }
    });
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _showBudgetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Set Budget for ${DateFormat('MMMM yyyy').format(DateTime(widget.year, widget.month))}',
          ),
          content: TextField(
            controller: _budgetController,
            decoration: const InputDecoration(
              hintText: 'Budget',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Skip', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                final budget = double.tryParse(_budgetController.text);
                if (budget != null && budget > 0) {
                  context.read<ExpenseProvider>().setBudget(
                    widget.year,
                    widget.month,
                    budget,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text(
                'Save',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addExpense() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AddExpenseDialog(year: widget.year, month: widget.month),
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _deleteExpense(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await context.read<ExpenseProvider>().deleteExpense(id);
    }
  }

  // void _expenseLongPress(Expense expense) {
  //   showPullDownMenu(context: context, items: [], position: );
  //   _deleteExpense(expense.id);
  // }

  Future<void> _editExpense(Expense expense) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) =>
          EditExpenseDialog(expense: expense, year: widget.year, month: widget.month),
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final dateFormatter = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          DateFormat('MMMM yyyy').format(DateTime(widget.year, widget.month)),
        ),
      ),
      body: Consumer2<ExpenseProvider, CategoryProvider>(
        builder: (context, expenseProvider, categoryProvider, _) {
          final budget = expenseProvider.getBudgetForMonth(
            widget.year,
            widget.month,
          );
          final expenses = expenseProvider.getExpensesForMonth(
            widget.year,
            widget.month,
          );
          final totalExpense = expenses.fold(0.0, (sum, e) => sum + e.price);
          final remaining = budget - totalExpense;
          final totalDays = DateTime(widget.year, widget.month + 1, 0).day;
          final remainingDays = totalDays - DateTime.now().day;
          final remainPerDay = remaining / remainingDays;

          final now = DateTime.now();
          final currentMonthDate = DateTime(now.year, now.month);
          final selectedMonthDate = DateTime(widget.year, widget.month);

          final bool isPast = selectedMonthDate.isBefore(currentMonthDate);
          final bool isCurrent =
              selectedMonthDate.year == now.year &&
              selectedMonthDate.month == now.month;

          return Column(
            children: [
              Column(
                children: [
                  GridView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 100,
                          crossAxisSpacing: 12,
                        ),
                    children: [
                      _buildBudgetCard(formatter, budget),
                      _buildSpentCard(formatter, totalExpense),

                      if (isCurrent)
                        _buildDifferenceCard(formatter, remaining, isPast),

                      if (isCurrent)
                        _buildRemainPerDayCard(formatter, remainPerDay),
                    ],
                  ),

                  // 👉 When NOT current month → show full width tile
                  if (!isCurrent)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                      child: _buildDifferenceCard(
                        formatter,
                        remaining,
                        isPast,
                        fullWidth: true,
                      ),
                    ),
                ],
              ),

              Text("Expenses", style: TextStyle(fontSize: 18)),
              Expanded(
                child: expenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 80,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text('No expenses yet'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          final expense = expenses[index];
                          final category = categoryProvider.getCategoryById(
                            expense.categoryId,
                          );

                          return GestureDetector(
                            onLongPressStart: (details) {
                              showPullDownMenu(
                                context: context,
                                routeTheme: PullDownMenuRouteTheme(
                                  backgroundColor: Colors.black,
                                ),
                                items: [
                                  PullDownMenuItem(
                                    onTap:()=> _editExpense(expense),
                                    title: "Edit",
                                    icon: CupertinoIcons.pen,
                                    itemTheme: PullDownMenuItemTheme(
                                      textStyle: TextStyle(
                                        fontFamily:
                                            GoogleFonts.plusJakartaSans()
                                                .fontFamily,
                                      ),
                                    ),
                                  ),
                                  // PullDownMenuDivider.large(color: Theme.of(context).scaffoldBackgroundColor,),
                                  PullDownMenuItem(
                                    onTap: () => _deleteExpense(expense.id),
                                    title: "Delete",
                                    icon: CupertinoIcons.delete,
                                    isDestructive: true,
                                    itemTheme: PullDownMenuItemTheme(
                                      textStyle: TextStyle(
                                        fontFamily:
                                        GoogleFonts.plusJakartaSans()
                                            .fontFamily,
                                      ),
                                    ),
                                  ),
                                ],
                                position: Rect.fromLTRB(
                                  details.globalPosition.dx,
                                  details.globalPosition.dy,
                                  details.globalPosition.dx,
                                  details.globalPosition.dy,
                                ),
                              );
                            },
                            child: ExpenseTile(
                              expense: expense,
                              category: category!,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExpense,
        label: Text("Add Expense"),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
    );
  }

  Widget _buildBudgetCard(NumberFormat formatter, double budget) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Budget', style: TextStyle(fontSize: 16)),
          Text(
            formatter.format(budget),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSpentCard(NumberFormat formatter, double spent) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Spent', style: TextStyle(fontSize: 16)),
          Text(
            formatter.format(spent),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDifferenceCard(
    NumberFormat formatter,
    double remaining,
    bool isPast, {
    bool fullWidth = false,
  }) {
    return SizedBox(
      height: 100,
      width: fullWidth ? double.infinity : null,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isPast ? 'Difference' : 'Remaining',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              formatter.format(remaining),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: remaining >= 0 ? Colors.green : Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemainPerDayCard(NumberFormat formatter, double value) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Remain / Day', style: TextStyle(fontSize: 16)),
          Text(
            formatter.format(value),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
