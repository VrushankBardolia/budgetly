import 'package:budgetly/core/import_to_export.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

BuildContext? get appContext => navigatorKey.currentContext;

bool _isDialogOpen = false;
bool get isDialogOpen => _isDialogOpen;

Future<void> singleActionDialog(BuildContext context, Widget widget) async {
  return showDialog(context: context, builder: (context) => widget);
}

Future<T?> dialog<T>(Widget widget, {bool barrierDismissible = true}) async {
  if (appContext == null) return null;
  _isDialogOpen = true;
  try {
    return await showDialog<T>(
      context: appContext!,
      barrierDismissible: barrierDismissible,
      builder: (context) => widget,
    );
  } finally {
    _isDialogOpen = false;
  }
}

Future<T?> defaultDialog<T>({Widget? title, required Widget content}) async {
  if (appContext == null) return null;
  _isDialogOpen = true;
  try {
    return await showDialog<T>(
      context: appContext!,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: title,
        content: content,
      ),
    );
  } finally {
    _isDialogOpen = false;
  }
}

Future<bool> confirmationDialog({
  BuildContext? context,
  String title = 'Confirmation',
  String? message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  bool isDestructive = false,
  Color? iconColor,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
}) async {
  final targetContext = context ?? appContext;
  if (targetContext == null) return false;

  _isDialogOpen = true;
  try {
    final result = await showDialog<bool>(
      context: targetContext,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(16),
        insetPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: boldText(18, color: Colors.white),
            ),
            message != null && message.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: regularText(14, color: AppColors.grey),
                    ),
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      if (onCancel != null) onCancel();
                      Navigator.of(context).pop(false);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: AppColors.surfaceLight),
                      ),
                    ),
                    child: Text(cancelText, style: semiBoldText(14, color: AppColors.grey)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (onConfirm != null) onConfirm();
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDestructive ? AppColors.error : AppColors.brand,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(confirmText, style: semiBoldText(14, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return result ?? false;
  } finally {
    _isDialogOpen = false;
  }
}

Future<T?> bottomSheet<T>(
  Widget widget, {
  bool isScrollControlled = false,
  Color? backgroundColor,
  ShapeBorder? shape,
}) {
  return showModalBottomSheet<T>(
    context: appContext!,
    isScrollControlled: isScrollControlled,
    backgroundColor: backgroundColor ?? AppColors.surfaceLight,
    shape: shape,
    builder: (context) => widget,
  );
}

void successSnackbar(String title) {
  _showSnackbar(title, ToastificationType.success, AppColors.success);
}

void errorSnackbar(String title) {
  _showSnackbar(title, ToastificationType.error, AppColors.error);
}

void infoSnackbar(String title) {
  _showSnackbar(title, ToastificationType.info, AppColors.brand);
}

void warningSnackbar(String title) {
  _showSnackbar(title, ToastificationType.warning, AppColors.warning);
}

void _showSnackbar(String title, ToastificationType type, Color color) {
  toastification.show(
    title: Text(title, style: mediumText(14, color: color)),
    autoCloseDuration: const Duration(seconds: 5),
    showIcon: false,
    alignment: Alignment.topCenter,
    type: type,
    style: ToastificationStyle.minimal,
    primaryColor: color,
    showProgressBar: false,
  );
}
