import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

enum ButtonType { primary, outlined, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonType type;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final String? semanticLabel;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.icon = null,
    this.backgroundColor = null,
    this.textColor = null,
    this.width = null,
    this.semanticLabel = null,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Determine colors
    Color btnBg = backgroundColor ?? theme.primaryColor;
    Color btnTxt = textColor ?? (isDark ? Colors.black : Colors.white);
    
    if (type == ButtonType.outlined) {
      btnBg = Colors.transparent;
      btnTxt = textColor ?? theme.textTheme.bodyLarge?.color ?? Colors.white;
    } else if (type == ButtonType.text) {
      btnBg = Colors.transparent;
      btnTxt = textColor ?? theme.primaryColor;
    }

    final childContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) ...[
          SpinKitThreeBounce(
            color: type == ButtonType.outlined ? theme.primaryColor : btnTxt,
            size: 18,
          ),
        ] else ...[
          if (icon != null) ...[
            Icon(icon, size: 20, color: type == ButtonType.outlined ? theme.primaryColor : btnTxt),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: type == ButtonType.outlined ? theme.primaryColor : btnTxt,
            ),
          ),
        ],
      ],
    );

    Widget buttonWidget;

    if (type == ButtonType.outlined) {
      buttonWidget = OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: theme.primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: childContent,
      );
    } else if (type == ButtonType.text) {
      buttonWidget = TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: childContent,
      );
    } else {
      buttonWidget = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: btnBg,
          foregroundColor: btnTxt,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: childContent,
      );
    }

    return Semantics(
      label: semanticLabel ?? text,
      button: true,
      enabled: onPressed != null && !isLoading,
      child: width != null
          ? SizedBox(width: width, child: buttonWidget)
          : SizedBox(width: double.infinity, child: buttonWidget),
    );
  }
}
