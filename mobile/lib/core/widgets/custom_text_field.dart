import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final String? errorText;
  final bool isPassword;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final String? semanticLabel;

  const CustomTextField({
    super.key,
    required this.controller,
    String? label,
    String? labelText,
    this.hintText = null,
    this.errorText = null,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator = null,
    this.prefixIcon = null,
    this.suffixIcon = null,
    this.textInputAction = TextInputAction.next,
    this.onChanged = null,
    this.onFieldSubmitted = null,
    this.enabled = true,
    this.autofillHints = null,
    this.focusNode = null,
    this.semanticLabel = null,
  }) : labelText = label ?? labelText ?? '';

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget? finalSuffix;
    if (widget.isPassword) {
      finalSuffix = Semantics(
        label: _obscureText ? "Show password" : "Hide password",
        button: true,
        child: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      );
    } else {
      finalSuffix = widget.suffixIcon;
    }

    return Semantics(
      label: widget.semanticLabel ?? widget.labelText,
      textField: true,
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscureText,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        textInputAction: widget.textInputAction,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onFieldSubmitted,
        enabled: widget.enabled,
        autofillHints: widget.autofillHints,
        focusNode: widget.focusNode,
        style: TextStyle(
          fontSize: 15,
          color: isDark ? Colors.white : Colors.black,
        ),
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          errorText: widget.errorText,
          prefixIcon: widget.prefixIcon,
          suffixIcon: finalSuffix,
          alignLabelWithHint: true,
        ),
      ),
    );
  }
}
