import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../model/Expense.dart';
import '../../provider/AuthProvider.dart';
import '../../provider/CategoryProvider.dart';
import '../../provider/ExpenseProvider.dart';

class EditExpenseDialog extends StatefulWidget {
  final Expense expense;
  final int year;
  final int month;

  const EditExpenseDialog({
    super.key,
    required this.expense,
    required this.year,
    required this.month,
  });

  @override
  State<EditExpenseDialog> createState() => _EditExpenseDialogState();
}

class _EditExpenseDialogState extends State<EditExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _detailController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // Pre-fill form with existing expense data
    _priceController.text = widget.expense.price.toString();
    _detailController.text = widget.expense.detail;
    _selectedDate = widget.expense.date;
    _selectedCategoryId = widget.expense.categoryId;
  }

  @override
  void dispose() {
    _priceController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(widget.year, widget.month, 1),
      lastDate: DateTime(widget.year, widget.month + 1, 0),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _updateExpense() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final price = double.parse(_priceController.text);
    final userId = context.read<AuthProvider>().user!.uid;

    final updatedExpense = Expense(
      id: widget.expense.id,
      date: _selectedDate!,
      price: price,
      categoryId: _selectedCategoryId!,
      detail: _detailController.text,
      userId: userId,
    );

    await context.read<ExpenseProvider>().updateExpense(
      widget.expense.id,
      updatedExpense,
    );

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      constraints: BoxConstraints.tightFor(width: MediaQuery.of(context).size.width),
      title: const Text('Edit Expense', textAlign: TextAlign.center,),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(
                  _selectedDate != null
                      ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                      : 'Select date',
                ),
                trailing: HugeIcon(icon: HugeIcons.strokeRoundedCalendar04,),
                onTap: _selectDate,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  hintText: 'Price',
                  prefixText: '₹',
                  prefixStyle: GoogleFonts.plusJakartaSans(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Consumer<CategoryProvider>(
                builder: (context, categoryProvider, _) {
                  if (categoryProvider.categories.isEmpty) {
                    return const Text('No categories. Please add categories first.');
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    style: TextStyle(fontSize: 18),
                    decoration: const InputDecoration(
                      hintText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: categoryProvider.categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Row(
                          children: [
                            Text(category.emoji, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedCategoryId = value);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _detailController,
                decoration: const InputDecoration(
                  hintText: 'Detail (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _updateExpense,
          child: const Text('Update'),
        ),
      ],
    );
  }
}