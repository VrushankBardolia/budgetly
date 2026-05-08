import 'package:budgetly/core/import_to_export.dart';

class ExpenseFormScreen extends GetView<ExpenseFormController> {
  const ExpenseFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(controller.title, style: boldText(20))),
      body: Obx(() {
        if (controller.isLoading.value) {
          return buildShimmerLoader();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildSectionLabel('Date'),
                DatePickerField(
                  formattedDate: controller.formattedSelectedDate,
                  onTap: controller.pickDate,
                ),
                const SizedBox(height: 16),

                buildSectionLabel('Amount'),
                AmountField(
                  controller: controller.priceController,
                  validator: controller.validatePrice,
                ),
                const SizedBox(height: 16),

                buildSectionLabel('Category'),
                buildCategoryDropdown(),
                const SizedBox(height: 16),

                buildSectionLabel('Details'),
                DetailField(
                  controller: controller.detailController,
                  hintText: 'Add a note (optional)',
                ),
                const SizedBox(height: 40),

                buildSubmitButton(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(label, style: mediumText(13, color: AppColors.grey)),
    );
  }

  Widget buildCategoryDropdown() {
    return Obx(() {
      if (controller.categories.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'No categories found. Please add categories first.',
            style: regularText(14, color: Colors.grey),
          ),
        );
      }

      return DropdownButtonFormField<String>(
        initialValue: controller.selectedCategoryId.value.isEmpty
            ? null
            : controller.selectedCategoryId.value,
        decoration: InputDecoration(
          hintText: 'Select a category',
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
        dropdownColor: AppColors.surfaceLight,
        items: controller.categories.map((category) {
          return DropdownMenuItem(
            value: category.id,
            child: Row(
              children: [
                Text(category.emoji, style: regularText(16)),
                const SizedBox(width: 12),
                Text(category.name, style: regularText(14)),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) controller.setCategory(value);
        },
        validator: controller.validateCategory,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      );
    });
  }

  Widget buildSubmitButton() {
    return Obx(
      () => Button(
        onClick: controller.isSubmitting.value ? null : controller.submit,
        child: controller.isSubmitting.value
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(controller.submitLabel, style: semiBoldText(16)),
      ),
    );
  }

  Widget buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceLight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildShimmerSection(56),
            const SizedBox(height: 16),
            _buildShimmerSection(56),
            const SizedBox(height: 16),
            _buildShimmerSection(56),
            const SizedBox(height: 16),
            _buildShimmerSection(120),
            const SizedBox(height: 40),
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerSection(double height) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 8,
          width: 80,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(height: 8),
        Container(
          height: height,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        ),
      ],
    );
  }
}
