import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/values/app_colors.dart';

/// A row of individual digit boxes used for OTP (6 digits) and PIN (4 digits).
///
/// Auto-advances to the next box on input and moves back on delete. Reports the
/// concatenated value via [onChanged] and fires [onCompleted] when all boxes
/// are filled. Set [obscure] for PIN entry.
class BoxedCodeInput extends StatefulWidget {
  const BoxedCodeInput({
    super.key,
    this.length = 6,
    this.obscure = false,
    this.boxSize = 52,
    this.spacing = 10,
    this.onChanged,
    this.onCompleted,
    this.autoFocus = false,
    this.accentColor,
    this.clearToken = 0,
    this.prefillValue,
    this.prefillToken = 0,
  });

  final int length;
  final bool obscure;
  final double boxSize;
  final double spacing;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool autoFocus;
  final Color? accentColor;

  /// Bump this value (from the parent) to clear all boxes — e.g. after a wrong
  /// OTP. Any change vs the previous build resets the input.
  final int clearToken;

  /// A code to fill in programmatically, e.g. one read from an SMS via the
  /// SMS User Consent API. Bump [prefillToken] whenever [prefillValue] should
  /// be (re-)applied — a value alone isn't enough since the same code could
  /// legitimately arrive twice (resend).
  final String? prefillValue;
  final int prefillToken;

  @override
  State<BoxedCodeInput> createState() => _BoxedCodeInputState();
}

class _BoxedCodeInputState extends State<BoxedCodeInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void didUpdateWidget(BoxedCodeInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.clearToken != oldWidget.clearToken) {
      for (final c in _controllers) {
        c.clear();
      }
      if (mounted) {
        setState(() {});
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _focusNodes.first.requestFocus();
        });
      }
    }
    if (widget.prefillToken != oldWidget.prefillToken &&
        (widget.prefillValue ?? '').isNotEmpty) {
      _fill(widget.prefillValue!);
    }
  }

  /// Distributes [digits] across the boxes starting at [start] (used both for
  /// a paste and for an SMS-autofilled code), then reports the new value and
  /// moves focus to the first empty box (or drops focus once full).
  void _fill(String digits, {int start = 0}) {
    digits = digits.replaceAll(RegExp(r'\D'), '');
    var last = start - 1;
    for (var i = 0; i < digits.length && start + i < widget.length; i++) {
      _controllers[start + i].text = digits[i];
      last = start + i;
    }
    if (!mounted) return;
    setState(() {});
    if (last >= 0 && last < widget.length - 1) {
      _focusNodes[last + 1].requestFocus();
    } else if (last == widget.length - 1) {
      _focusNodes[last].unfocus();
    }
    widget.onChanged?.call(_value);
    if (_value.length == widget.length &&
        _controllers.every((c) => c.text.isNotEmpty)) {
      widget.onCompleted?.call(_value);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _value => _controllers.map((c) => c.text).join();

  void _onChanged(int index, String value) {
    // A paste (or SMS/keyboard autofill) delivers more than one digit into a
    // single box at once — spread it across the remaining boxes instead of
    // truncating it down to the first character.
    if (value.length > 1) {
      _fill(value, start: index);
      return;
    }
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    widget.onChanged?.call(_value);
    if (_value.length == widget.length &&
        !_value.contains(RegExp(r'\s')) &&
        _controllers.every((c) => c.text.isNotEmpty)) {
      // Keep focus on the field (don't unfocus) so that after a wrong OTP the
      // user can immediately type or backspace to edit without tapping a box.
      widget.onCompleted?.call(_value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(widget.length, (i) {
          final filled = _controllers[i].text.isNotEmpty;
          final accent = widget.accentColor ?? AppColors.brandOrange;
          return SizedBox(
            width: widget.boxSize,
            height: widget.boxSize + 4,
            child: KeyboardListener(
              focusNode: FocusNode(skipTraversal: true),
              onKeyEvent: (event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.backspace &&
                    _controllers[i].text.isEmpty &&
                    i > 0) {
                  _focusNodes[i - 1].requestFocus();
                  _controllers[i - 1].clear();
                  _onChanged(i - 1, '');
                }
              },
              child: TextField(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                autofocus: widget.autoFocus && i == 0,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                obscureText: widget.obscure,
                obscuringCharacter: '●',
                // Allow a full pasted/autofilled code to reach onChanged (it's
                // then spread across the boxes in _fill) instead of truncating
                // it down to a single character.
                maxLength: widget.length,
                autofillHints: (!widget.obscure && i == 0)
                    ? const [AutofillHints.oneTimeCode]
                    : null,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                  fillColor: AppColors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: filled ? accent : const Color(0xFFE2E8F0),
                      width: filled ? 1.6 : 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: accent, width: 1.6),
                  ),
                ),
                onChanged: (v) {
                  setState(() {});
                  _onChanged(i, v);
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}
