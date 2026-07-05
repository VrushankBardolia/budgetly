import 'package:budgetly/core/import_to_export.dart';

class SheetRecordFormScreen extends ConsumerWidget {
  const SheetRecordFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    final prov = ref.watch(sheetRecordFormProvider(args));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: appRouter.pop),
        title: Text(prov.title, style: boldText(20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: prov.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildTypeToggle(prov),
              const SizedBox(height: 24),

              buildSectionLabel('Amount'),
              const SizedBox(height: 8),
              AmountField(controller: prov.amountController, validator: prov.validateAmount),
              const SizedBox(height: 24),

              buildSectionLabel('Date'),
              const SizedBox(height: 8),
              DatePickerField(formattedDate: prov.formattedDate, onTap: prov.pickDate),
              const SizedBox(height: 24),

              buildSectionLabel('Detail'),
              const SizedBox(height: 8),
              DetailField(
                controller: prov.detailController,
                validator: prov.validateDetail,
                hintText: 'Add Details',
              ),
              const SizedBox(height: 24),

              Button(onClick: prov.submit, child: Text(prov.submitLabel)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSectionLabel(String label) {
    return Text(label, style: semiBoldText(13, color: AppColors.grey));
  }

  Widget buildTypeToggle(SheetRecordFormProvider prov) {
    final isExpense = prov.selectedType == RecordType.expense;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          buildTypeOption(
            label: 'Expense',
            icon: Icons.arrow_upward_rounded,
            isSelected: isExpense,
            selectedColor: AppColors.error,
            onTap: () => prov.setType(RecordType.expense),
          ),
          buildTypeOption(
            label: 'Income',
            icon: Icons.arrow_downward_rounded,
            isSelected: !isExpense,
            selectedColor: AppColors.success,
            onTap: () => prov.setType(RecordType.income),
          ),
        ],
      ),
    );
  }

  Widget buildTypeOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? selectedColor.withValues(alpha: 0.4) : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? selectedColor : Colors.grey[500]),
              const SizedBox(width: 8),
              Text(
                label,
                style: isSelected
                    ? boldText(14, color: selectedColor)
                    : regularText(14, color: AppColors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
