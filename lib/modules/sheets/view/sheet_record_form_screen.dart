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
                // ── Type Toggle ───────────────────────────────────────
                buildSectionLabel('Type'),
                const SizedBox(height: 8),
                buildTypeToggle(),
                const SizedBox(height: 24),

                // ── Amount ────────────────────────────────────────────
                buildSectionLabel('Amount'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controller.amountController,
                  decoration: InputDecoration(
                    hintText: 'Enter amount',
                    prefixIcon: const Icon(Icons.currency_rupee_rounded, size: 20),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.brand, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.error, width: 2),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: regularText(16),
                  validator: controller.validateAmount,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 24),

                // ── Date ──────────────────────────────────────────────
                buildSectionLabel('Date'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: controller.pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      spacing: 12,
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 18, color: Colors.grey[400]),
                        Text(controller.formattedDate, style: regularText(15)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Detail ────────────────────────────────────────────
                buildSectionLabel('Detail'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controller.detailController,
                  decoration: InputDecoration(
                    hintText: 'Add a note (optional)',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.brand, width: 2),
                    ),
                  ),
                  maxLines: 3,
                  style: regularText(14),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 40),

                // ── Submit ────────────────────────────────────────────
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
