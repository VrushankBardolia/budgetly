import 'package:budgetly/core/import_to_export.dart';
import 'package:intl/intl.dart';

class SheetRecordFormController extends GetxController {
  // ─── Arguments ────────────────────────────────────────────────────────────
  late final String sheetId;
  late final SheetRecord? editingRecord;

  // ─── Form ─────────────────────────────────────────────────────────────────
  final amountController = TextEditingController();
  final detailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // ─── Reactive State ───────────────────────────────────────────────────────
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<RecordType> selectedType = RecordType.expense.obs;
  final RxBool isSubmitting = false.obs;

  bool get isEditing => editingRecord != null;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map? ?? {};
    sheetId = args['sheetId'] ?? '';
    editingRecord = args['record'];

    if (isEditing) {
      amountController.text = editingRecord!.amount.toInt().toString();
      detailController.text = editingRecord!.detail;
      selectedDate.value = editingRecord!.date;
      selectedType.value = editingRecord!.type;
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    detailController.dispose();
    super.onClose();
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDate.value,
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime.now(),
    );
    if (picked != null) selectedDate.value = picked;
  }

  void setType(RecordType type) => selectedType.value = type;

  // ─── Validation ───────────────────────────────────────────────────────────

  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) return 'Please enter amount';
    final parsed = double.tryParse(value);
    if (parsed == null) return 'Please enter a valid number';
    if (parsed <= 0) return 'Amount must be greater than 0';
    return null;
  }

  // ─── Submit ───────────────────────────────────────────────────────────────

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    isSubmitting.value = true;
    try {
      final data = {
        'date': Timestamp.fromDate(selectedDate.value),
        'amount': double.parse(amountController.text),
        'type': selectedType.value.name,
        'detail': detailController.text.trim(),
        'createdAt': Timestamp.fromDate(editingRecord?.createdAt ?? DateTime.now()),
      };

      if (isEditing) {
        await FirebaseHelper.updateRecord(sheetId, editingRecord!.id, data);
      } else {
        await FirebaseHelper.addRecord(sheetId, data);
      }

      Get.back(result: true);
    } finally {
      isSubmitting.value = false;
    }
  }

  // ─── Derived Getters ──────────────────────────────────────────────────────

  String get formattedDate => DateFormat('MMM dd, yyyy').format(selectedDate.value);
  String get title => isEditing ? 'Edit Record' : 'Add Record';
  String get submitLabel => isEditing ? 'Update' : 'Add';
}
