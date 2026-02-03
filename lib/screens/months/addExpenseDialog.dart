import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../../model/Expense.dart';
import '../../controller/expense_controller.dart';
import '../../controller/category_controller.dart';
import '../../controller/auth_controller.dart';

class AddExpenseDialog extends StatefulWidget {
  final int year;
  final int month;

  const AddExpenseDialog({super.key, required this.year, required this.month});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _detailController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(widget.year, widget.month, DateTime.now().day);
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    final price = double.parse(_priceController.text);
    final userId = Get.find<AuthController>().user!.uid;

    final expense = Expense(
      id: '',
      date: _selectedDate!,
      price: price,
      categoryId: _selectedCategoryId!,
      detail: _detailController.text,
      userId: userId,
    );

    await Get.find<ExpenseController>().addExpense(expense);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      constraints: BoxConstraints.tightFor(
        width: MediaQuery.of(context).size.width,
      ),
      title: const Text('Add Expense', textAlign: TextAlign.center),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Date'),
                subtitle: Text(
                  _selectedDate != null
                      ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                      : 'Select date',
                ),
                trailing: HugeIcon(icon: HugeIcons.strokeRoundedCalendar04),
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
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              Obx(() {
                final categoryController = Get.find<CategoryController>();
                if (categoryController.categories.isEmpty) {
                  return const Text(
                    'No categories. Please add categories first.',
                  );
                }

                return DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(
                    hintText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categoryController.categories.map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Row(
                        children: [
                          Text(
                            category.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
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
              }),
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
        ElevatedButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}
