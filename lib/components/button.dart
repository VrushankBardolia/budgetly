import 'package:budgetly/core/import_to_export.dart';

class Button extends StatelessWidget {
  final Widget child;
  final VoidCallback? onClick;

  const Button({super.key, required this.child, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        padding: EdgeInsetsGeometry.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.brandDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.brand.withValues(alpha: 0.2)),
        ),
        child: Center(child: child),
      ),
    );
  }
}
