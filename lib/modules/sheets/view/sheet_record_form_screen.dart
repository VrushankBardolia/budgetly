import 'package:budgetly/core/import_to_export.dart';

class SheetRecordFormScreen extends GetView<SheetRecordFormController> {
  const SheetRecordFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: Get.back),
        title: Text(controller.title, style: boldText(20)),
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildTypeToggle(),
                const SizedBox(height: 24),

                buildSectionLabel('Amount'),
                const SizedBox(height: 8),
                AmountField(
                  controller: controller.amountController,
                  validator: controller.validateAmount,
                ),
                const SizedBox(height: 24),

                buildSectionLabel('Date'),
                const SizedBox(height: 8),
                DatePickerField(
                  formattedDate: controller.formattedDate,
                  onTap: controller.pickDate,
                ),
                const SizedBox(height: 24),

                buildSectionLabel('Detail'),
                const SizedBox(height: 8),
                DetailField(
                  controller: controller.detailController,
                  validator: controller.validateDetail,
                  hintText: 'Add Details',
                ),
                const SizedBox(height: 24),

                Button(onClick: controller.submit, child: Text(controller.submitLabel)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSectionLabel(String label) {
    return Text(label, style: semiBoldText(13, color: AppColors.grey));
  }

  Widget buildTypeToggle() {
    return Obx(() {
      final isExpense = controller.selectedType.value == RecordType.expense;

      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            buildTypeOption(
              label: 'Expense',
              icon: Icons.arrow_upward_rounded,
              isSelected: isExpense,
              selectedColor: AppColors.error,
              onTap: () => controller.setType(RecordType.expense),
            ),
            buildTypeOption(
              label: 'Income',
              icon: Icons.arrow_downward_rounded,
              isSelected: !isExpense,
              selectedColor: AppColors.success,
              onTap: () => controller.setType(RecordType.income),
            ),
          ],
        ),
      );
    });
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
