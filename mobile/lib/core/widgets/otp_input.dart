import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInput extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool hasError;

  const OtpInput({
    super.key,
    this.length = 6,
    this.onCompleted = null,
    this.onChanged = null,
    this.hasError = false,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<String> _pinValues;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (index) => TextEditingController());
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
    _pinValues = List.filled(widget.length, '');
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _nextFocus(int index) {
    if (index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
    }
  }

  void _previousFocus(int index) {
    if (index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _updateValue(int index, String value) {
    if (value.length > 1) {
      // Handle paste
      final cleanVal = value.replaceAll(RegExp(r'[^0-9]'), '');
      for (int i = 0; i < widget.length && i < cleanVal.length; i++) {
        _controllers[i].text = cleanVal[i];
        _pinValues[i] = cleanVal[i];
      }
      final completeVal = _pinValues.join('');
      if (widget.onChanged != null) widget.onChanged!(completeVal);
      if (completeVal.length == widget.length) {
        if (widget.onCompleted != null) widget.onCompleted!(completeVal);
      }
      _focusNodes[widget.length - 1].requestFocus();
      return;
    }

    _pinValues[index] = value;
    final completeVal = _pinValues.join('');
    
    if (widget.onChanged != null) widget.onChanged!(completeVal);

    if (value.isNotEmpty) {
      _nextFocus(index);
    }

    if (completeVal.length == widget.length) {
      if (widget.onCompleted != null) widget.onCompleted!(completeVal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.width > 600;

    // Responsive dimensions
    final boxWidth = isTablet ? 60.0 : 46.0;
    final boxHeight = isTablet ? 70.0 : 56.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: boxWidth,
          height: boxHeight,
          child: CallbackShortcuts(
            bindings: <ShortcutActivator, VoidCallback>{
              const SingleActivator(LogicalKeyboardKey.backspace): () {
                if (_controllers[index].text.isEmpty && index > 0) {
                  _controllers[index - 1].clear();
                  _pinValues[index - 1] = '';
                  _previousFocus(index);
                }
              },
            },
            child: Semantics(
              label: "Digit ${index + 1} of ${widget.length}",
              child: TextFormField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: TextStyle(
                  fontSize: isTablet ? 24 : 18,
                  fontWeight: FontWeight.bold,
                  color: widget.hasError
                      ? theme.colorScheme.error
                      : (theme.brightness == Brightness.dark ? Colors.white : Colors.black),
                ),
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                  fillColor: theme.brightness == Brightness.dark
                      ? const Color(0xFF111317)
                      : Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: widget.hasError
                          ? theme.colorScheme.error
                          : (theme.brightness == Brightness.dark
                              ? const Color(0xFF1F2937)
                              : const Color(0xFFE5E7EB)),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: widget.hasError ? theme.colorScheme.error : theme.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) => _updateValue(index, value),
              ),
            ),
          ),
        );
      }),
    );
  }
}
