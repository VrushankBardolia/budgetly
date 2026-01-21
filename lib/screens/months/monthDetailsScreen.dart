import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../model/Expense.dart';
import '../../provider/CategoryProvider.dart';
import '../../provider/ExpenseProvider.dart';
import '../../components/expenseTile.dart';
import 'editExpenseDialog.dart';
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

  final Color _backgroundColor = const Color(0xFF121212);
  final Color _cardColor = const Color(0xFF1E1E1E);
  final Color _primaryColor = const Color(0xFF2196F3);

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
          backgroundColor: _cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Set Budget',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('MMMM yyyy',).format(DateTime(widget.year, widget.month)),
                style: TextStyle(color: Colors.grey[400]),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _budgetController,
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey.withValues(alpha: 0.5)),
                  filled: true,
                  fillColor: const Color(0xFF2C2C2C),
                  prefixText: '₹',
                  prefixStyle: GoogleFonts.plusJakartaSans(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _primaryColor, width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_budgetController.text.isEmpty? 'Skip' :'Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
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
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Expense', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this expense?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await context.read<ExpenseProvider>().deleteExpense(id);
    }
  }

  Future<void> _editExpense(Expense expense) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditExpenseDialog(
        expense: expense,
        year: widget.year,
        month: widget.month,
      ),
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          DateFormat('MMMM yyyy').format(DateTime(widget.year, widget.month)),
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedEdit04, size: 20,),
            tooltip: "Edit Budget",
            onPressed: _showBudgetDialog,
          ),
        ],
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
          final remainPerDay = remainingDays > 0
              ? remaining / remainingDays
              : 0.0;

          final now = DateTime.now();
          final selectedMonthDate = DateTime(widget.year, widget.month);

          final bool isCurrent =
              selectedMonthDate.year == now.year &&
              selectedMonthDate.month == now.month;

          final difference = remaining;
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

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              "Budget",
                              formatter.format(budget),
                              Colors.white,
                              icon: HugeIcons.strokeRoundedWallet01,
                              onTap: _showBudgetDialog,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              "Spent",
                              formatter.format(totalExpense),
                              Colors.white,
                              icon: HugeIcons.strokeRoundedMoney01,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (isCurrent) ...[
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(statusLabel,
                                formatter.format(remaining),
                                statusColor,
                                icon: statusIcon,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoCard(
                                "Safe / Day",
                                formatter.format(remainPerDay),
                                Colors.blueAccent,
                                icon: HugeIcons.strokeRoundedCoins01,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        _buildInfoCard(statusLabel,
                          formatter.format(remaining),
                          statusColor,
                          icon: statusIcon,
                          isFullWidth: true,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Transactions",
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey[400],
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        "${expenses.length} entries",
                        style: GoogleFonts.plusJakartaSans(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),

              if (expenses.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _cardColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.receipt_long_rounded,
                            size: 50,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('No transactions',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final expense = expenses[index];
                    final category = categoryProvider.getCategoryById(
                      expense.categoryId,
                    );

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GestureDetector(
                        onLongPressStart: (details) {
                          HapticFeedback.heavyImpact();
                          showPullDownMenu(
                            context: context,
                            routeTheme: PullDownMenuRouteTheme(
                              backgroundColor: const Color(0xFF2C2C2C),
                              width: 200,
                            ),
                            items: [
                              PullDownMenuItem(
                                onTap: () => _editExpense(expense),
                                title: "Edit",
                                icon: CupertinoIcons.pen,
                                itemTheme: PullDownMenuItemTheme(
                                  textStyle: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              PullDownMenuItem(
                                onTap: () => _deleteExpense(expense.id),
                                title: "Delete",
                                icon: CupertinoIcons.delete,
                                isDestructive: true,
                                itemTheme: PullDownMenuItemTheme(
                                  textStyle: GoogleFonts.plusJakartaSans(),
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
                      ),
                    );
                  }, childCount: expenses.length),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 150)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExpense,
        label: const Text("Add Expense"),
        icon: HugeIcon(icon: HugeIcons.strokeRoundedMoneyAdd01)
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    Color valueColor, {
    dynamic icon,
    VoidCallback? onTap,
    bool isFullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
                HugeIcon(icon: icon, size: 20, color: valueColor),
              ],
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value,
                style: GoogleFonts.plusJakartaSans(
                  color: valueColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
