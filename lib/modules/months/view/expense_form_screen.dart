import 'package:budgetly/core/import_to_export.dart';

class ExpenseFormScreen extends GetView<ExpenseFormController> {
  const ExpenseFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(controller.title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 20)),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: Get.back),
      ),
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
                // ── Date ─────────────────────────────────────────────────
                buildSectionLabel('Date'),
                buildDatePickerTile(),
                const SizedBox(height: 16),

                // ── Price ─────────────────────────────────────────────────
                buildSectionLabel('Amount'),
                buildPriceField(),
                const SizedBox(height: 16),

                // ── Category ──────────────────────────────────────────────
                buildSectionLabel('Category'),
                buildCategoryDropdown(),
                const SizedBox(height: 16),

                // ── Detail ────────────────────────────────────────────────
                buildSectionLabel('Details'),
                buildDetailField(),
                const SizedBox(height: 40),

                // ── Submit ────────────────────────────────────────────────
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
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(color: AppColors.grey, fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.5),
      ),
    );
  }

  Widget buildDatePickerTile() {
    return Obx(
      () => GestureDetector(
        onTap: controller.pickDate,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              HugeIcon(icon: HugeIcons.strokeRoundedCalendar04, size: 20, color: AppColors.grey),
              const SizedBox(width: 12),
              Text(controller.formattedSelectedDate, style: GoogleFonts.plusJakartaSans(color: AppColors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPriceField() {
    return TextFormField(
      controller: controller.priceController,
      decoration: InputDecoration(hintText: 'Enter amount', prefixIcon: const Icon(Icons.currency_rupee, size: 20), border: OutlineInputBorder()),
      keyboardType: TextInputType.number,
      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16),
      validator: controller.validatePrice,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onTapOutside: (event) => FocusScope.of(Get.context!).unfocus(),
    );
  }

  Widget buildCategoryDropdown() {
    return Obx(() {
      if (controller.categories.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
          child: Text('No categories found. Please add categories first.', style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 14)),
        );
      }

      return DropdownButtonFormField<String>(
        initialValue: controller.selectedCategoryId.value.isEmpty ? null : controller.selectedCategoryId.value,
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
                Text(category.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
                Text(category.name, style: GoogleFonts.plusJakartaSans(color: AppColors.white)),
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

  Widget buildDetailField() {
    return TextFormField(
      controller: controller.detailController,
      decoration: InputDecoration(
        hintText: 'Add a note (optional)',
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.brand, width: 2),
        ),
      ),
      minLines: 3,
      maxLines: 5,
      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget buildSubmitButton() {
    return Obx(
      () => Button(
        onClick: controller.isSubmitting.value ? null : controller.submit,
        child: controller.isSubmitting.value
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(
                controller.submitLabel,
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
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
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
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
