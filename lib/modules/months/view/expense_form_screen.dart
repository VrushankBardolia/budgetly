import 'package:budgetly/core/import_to_export.dart';

class ExpenseFormScreen extends ConsumerWidget {
  const ExpenseFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    final prov = ref.watch(expenseFormProvider(args));

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(prov.title, style: boldText(20))),
      body: prov.isLoading
          ? buildShimmerLoader()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: prov.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildSectionLabel('Date'),
                    DatePickerField(
                      formattedDate: prov.formattedSelectedDate,
                      onTap: prov.pickDate,
                    ),
                    const SizedBox(height: 16),

                    buildSectionLabel('Amount'),
                    AmountField(controller: prov.priceController, validator: prov.validatePrice),
                    const SizedBox(height: 16),

                    buildSectionLabel('Category'),
                    buildCategoryDropdown(prov),
                    const SizedBox(height: 16),

                    buildSectionLabel('Details'),
                    DetailField(
                      controller: prov.detailController,
                      hintText: 'Add a note (optional)',
                    ),
                    const SizedBox(height: 40),

                    buildSubmitButton(prov),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(label, style: mediumText(13, color: AppColors.grey)),
    );
  }

  Widget buildCategoryDropdown(ExpenseFormProvider prov) {
    if (prov.categories.isEmpty) {
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
      initialValue: prov.selectedCategoryId.isEmpty ? null : prov.selectedCategoryId,
      decoration: const InputDecoration(
        hintText: 'Select a category',
        border: OutlineInputBorder(borderSide: BorderSide.none),
      ),
      dropdownColor: AppColors.surfaceLight,
      items: prov.categories.map((category) {
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
        if (value != null) prov.setCategory(value);
      },
      validator: prov.validateCategory,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildSubmitButton(ExpenseFormProvider prov) {
    return Button(
      onClick: prov.isSubmitting ? null : prov.submit,
      child: prov.isSubmitting
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Text(prov.submitLabel, style: semiBoldText(16)),
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
