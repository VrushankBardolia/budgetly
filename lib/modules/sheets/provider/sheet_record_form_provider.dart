import 'package:budgetly/core/import_to_export.dart';
import 'package:intl/intl.dart';

class SheetRecordFormProvider extends ChangeNotifier {
  final Ref ref;

  // ─── Arguments ────────────────────────────────────────────────────────────
  final String sheetId;
  final SheetRecord? editingRecord;

  // ─── Form ─────────────────────────────────────────────────────────────────
  final amountController = TextEditingController();
  final detailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // ─── State ───────────────────────────────────────────────────────
  DateTime selectedDate = DateTime.now();
  RecordType selectedType = RecordType.expense;
  bool isSubmitting = false;

  bool get isEditing => editingRecord != null;

  SheetRecordFormProvider(this.ref, Map args)
    : sheetId = args['sheetId'] ?? '',
      editingRecord = args['record'] {
    if (isEditing) {
      amountController.text = editingRecord!.amount.toInt().toString();
      detailController.text = editingRecord!.detail;
      selectedDate = editingRecord!.date;
      selectedType = editingRecord!.type;
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    detailController.dispose();
    super.dispose();
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: appContext!,
      initialDate: selectedDate,
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      selectedDate = picked;
      notifyListeners();
    }
  }

  void setType(RecordType type) {
    selectedType = type;
    notifyListeners();
  }

  // ─── Validation ───────────────────────────────────────────────────────────

  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) return 'Please enter amount';
    final parsed = double.tryParse(value);
    if (parsed == null) return 'Please enter a valid number';
    if (parsed <= 0) return 'Amount must be greater than 0';
    return null;
  }

  String? validateDetail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter detail';
    return null;
  }

  // ─── Submit ───────────────────────────────────────────────────────────────

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    isSubmitting = true;
    notifyListeners();
    try {
      final data = {
        'date': Timestamp.fromDate(selectedDate),
        'amount': double.parse(amountController.text),
        'type': selectedType.name,
        'detail': detailController.text.trim(),
        'createdAt': Timestamp.fromDate(editingRecord?.createdAt ?? DateTime.now()),
      };

      if (isEditing) {
        await FirebaseHelper.updateRecord(sheetId, editingRecord!.id, data);
      } else {
        await FirebaseHelper.addRecord(sheetId, data);
      }
      ref.read(sheetsProvider).loadSheets();

      appRouter.pop(true);
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  // ─── Derived Getters ──────────────────────────────────────────────────────

  String get formattedDate => DateFormat('MMM dd, yyyy').format(selectedDate);
  String get title => isEditing ? 'Edit Record' : 'Add Record';
  String get submitLabel => isEditing ? 'Update' : 'Add';
}
