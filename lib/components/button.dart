import 'package:flutter/material.dart';

enum ButtonVariant { darkBlue, white }

class Button extends StatelessWidget {
  final Widget child;
  final VoidCallback? onClick;
  final ButtonVariant variant;
  const Button({
    super.key,
    required this.child,
    required this.onClick,
    this.variant = ButtonVariant.darkBlue,
  });

  @override
  Widget build(BuildContext context) {
    final white = variant == ButtonVariant.white;

    return GestureDetector(
      onTap: onClick,
      child: Container(
        padding: EdgeInsetsGeometry.all(16),
        width: double.infinity,
        decoration: white
            ? BoxDecoration(
                // WHITE COLOR THEME
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                // border: Border.all(
                //   color: Theme.of(context).colorScheme.onPrimary,
                // ),
              )
            : BoxDecoration(
                // DARK BLUE COLOR THEME
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withAlpha(100),
                ),
              ),
        child: Center(child: child),
      ),
    );
  }
}
