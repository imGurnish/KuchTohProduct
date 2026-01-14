import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Mindspace Text Field Widget
///
/// A styled text field with floating label, icons, and validation support.
/// Matches the premium design aesthetic.
class MindspaceTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final IconData? prefixIcon;
  final Widget? suffixWidget;
  final int maxLines;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? errorText;

  const MindspaceTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixWidget,
    this.maxLines = 1,
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.errorText,
  });

  /// Email input field
  factory MindspaceTextField.email({
    Key? key,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool enabled = true,
    TextInputAction? textInputAction,
    void Function(String)? onSubmitted,
    FocusNode? focusNode,
    String? errorText,
  }) {
    return MindspaceTextField(
      key: key,
      label: 'Email',
      hint: 'Enter your email',
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      keyboardType: TextInputType.emailAddress,
      enabled: enabled,
      prefixIcon: Icons.email_outlined,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      focusNode: focusNode,
      errorText: errorText,
    );
  }

  /// Password input field with visibility toggle
  factory MindspaceTextField.password({
    Key? key,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool enabled = true,
    String label = 'Password',
    String hint = 'Enter your password',
    TextInputAction? textInputAction,
    void Function(String)? onSubmitted,
    FocusNode? focusNode,
    String? errorText,
  }) {
    return _PasswordTextField(
      key: key,
      label: label,
      hint: hint,
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      focusNode: focusNode,
      errorText: errorText,
    );
  }

  @override
  State<MindspaceTextField> createState() => _MindspaceTextFieldState();
}

class _MindspaceTextFieldState extends State<MindspaceTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isFocused && !hasError
                ? [
                    BoxShadow(
                      color:
                          (isDark
                                  ? AppColors.darkAccent
                                  : AppColors.lightPrimary)
                              .withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            validator: widget.validator,
            onChanged: widget.onChanged,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onSubmitted,
            autofocus: widget.autofocus,
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? (isDark
                                ? AppColors.darkAccent
                                : AppColors.lightPrimary)
                          : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary),
                      size: 20,
                    )
                  : null,
              suffixIcon: widget.suffixWidget,
              errorText: widget.errorText,
              errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
              labelStyle: TextStyle(
                color: hasError
                    ? AppColors.error
                    : _isFocused
                    ? (isDark ? AppColors.darkAccent : AppColors.lightPrimary)
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Password text field with visibility toggle
class _PasswordTextField extends MindspaceTextField {
  const _PasswordTextField({
    super.key,
    required super.label,
    super.hint,
    super.controller,
    super.validator,
    super.onChanged,
    super.enabled,
    super.textInputAction,
    super.onSubmitted,
    super.focusNode,
    super.errorText,
  }) : super(
         prefixIcon: Icons.lock_outline,
         keyboardType: TextInputType.visiblePassword,
       );

  @override
  State<MindspaceTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends _MindspaceTextFieldState {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isFocused && !hasError
                ? [
                    BoxShadow(
                      color:
                          (isDark
                                  ? AppColors.darkAccent
                                  : AppColors.lightPrimary)
                              .withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            validator: widget.validator,
            onChanged: widget.onChanged,
            keyboardType: widget.keyboardType,
            obscureText: _obscureText,
            enabled: widget.enabled,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onSubmitted,
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              prefixIcon: Icon(
                Icons.lock_outline,
                color: _isFocused
                    ? (isDark ? AppColors.darkAccent : AppColors.lightPrimary)
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
              errorText: widget.errorText,
              errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
              labelStyle: TextStyle(
                color: hasError
                    ? AppColors.error
                    : _isFocused
                    ? (isDark ? AppColors.darkAccent : AppColors.lightPrimary)
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
