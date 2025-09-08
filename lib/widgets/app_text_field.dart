import 'package:app_structure/core/themes/app_style.dart';
import 'package:app_structure/core/themes/app_text.dart';
import 'package:app_structure/data/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'bottom_border_container.dart';

/// A customizable, performant text field with label, prefix/suffix icons, and error handling.
///
/// Usage:
/// ```dart
/// AppTextField(
///   controller: myController,
///   label: 'Email',
///   hintText: 'Enter your email',
///   prefixIcon: AppIcons.email,
///   onChanged: (val) {},
/// )
/// ```
class AppTextField extends StatefulWidget {
  /// Controls the text being edited.
  final TextEditingController? controller;

  /// Label displayed above the field.
  final String? label;

  /// Icon to display at the start. Asset path (SVG/PNG) or widget.
  final dynamic prefixIcon;

  /// Icon to display at the end. Asset path (SVG/PNG) or widget.
  final dynamic suffixIcon;

  /// Called when the suffix icon is tapped.
  final VoidCallback? onSuffixIconTap;

  /// Validator for the field value.
  final String? Function(String?)? validator;

  /// Placeholder text.
  final String? hintText;

  /// Error text to display (overrides validator).
  final String? errorText;

  /// Style for the input text.
  final TextStyle? textStyle;

  /// Style for the hint text.
  final TextStyle? hintStyle;

  /// Text alignment.
  final TextAlign textAlign;

  /// Keyboard action button.
  final TextInputAction textInputAction;

  /// Input formatters.
  final List<TextInputFormatter>? inputFormatters;

  /// Keyboard type.
  final TextInputType keyboardType;

  /// Max lines for the field.
  final int maxLines;

  /// Min lines for the field.
  final int minLines;

  /// Max length of input.
  final int? maxLength;

  /// Obscure text (for passwords).
  final bool obscureText;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the field is tapped.
  final VoidCallback? onTap;

  /// Called when the user submits the field.
  final ValueChanged<String>? onSubmitted;

  /// Whether the field is enabled.
  final bool enabled;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Whether to autofocus the field.
  final bool autofocus;

  /// Color for the suffix icon.
  final Color? suffixIconColor;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.validator,
    this.hintText,
    this.errorText,
    this.textStyle,
    this.hintStyle,
    this.textAlign = TextAlign.start,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.minLines = 1,
    this.maxLength,
    this.obscureText = false,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.suffixIconColor,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_hasFocus != _focusNode.hasFocus) {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hint Style
    final hintStyle =
        widget.hintStyle ??
        Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 12.sp,
          color: AppColors.lightGreyTextColor,
          fontWeight: FontWeight.w400, //
        );

    // Text Style
    final textStyle =
        widget.textStyle ??
        Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 12.sp,
          color: AppColors.primaryTextColor,
          fontWeight: FontWeight.w400, //
        );

    // Color
    final color = widget.errorText != null
        ? AppColors.red
        : _hasFocus
        ? AppColors.primaryColor
        : AppColors.dividerAndBorderColor;

    // Prefix Icon
    final prefixIcon = _buildIcon(widget.prefixIcon, color);

    // Suffix Icon
    final suffixIcon = _buildIcon(widget.suffixIcon, widget.suffixIconColor ?? color, onTap: widget.onSuffixIconTap);

    // Return Column
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (widget.label != null) ...[
          AppText(
            widget.label!,
            textColor: _hasFocus ? AppColors.primaryTextColor : AppColors.darkGreyTextColor, //
          ),
          4.verticalSpace,
        ],

        // Text Field
        BottomBorderContainer(
          color: color,
          isSelected: _hasFocus,
          child: TextField(
            focusNode: _focusNode,
            controller: widget.controller,
            onChanged: widget.onChanged,
            style: textStyle,
            onSubmitted: widget.onSubmitted,
            textAlign: widget.textAlign,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,
            cursorColor: AppColors.primaryColor,
            cursorRadius: const Radius.circular(6),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: hintStyle,
              fillColor: Colors.white,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14),
              isCollapsed: true,
              isDense: true,
              counter: const SizedBox.shrink(),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon, //
            ),
            textInputAction: widget.textInputAction,
            inputFormatters: widget.inputFormatters,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            onTap: widget.onTap,
            obscureText: widget.obscureText,
          ),
        ),

        // Error Text
        if (widget.errorText != null) ...[_buildError(widget.errorText!)],
      ],
    );
  }

  /// Build Icon
  Widget? _buildIcon(dynamic icon, Color color, {VoidCallback? onTap}) {
    if (icon == null) return null;
    Widget child;
    if (icon is String) {
      if (icon.endsWith('.svg')) {
        child = Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: SvgPicture.asset(icon, colorFilter: ColorFilter.mode(color, BlendMode.srcIn)),
        );
      } else {
        child = Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Image.asset(icon, color: color),
        );
      }
    } else if (icon is Widget) {
      child = icon;
    } else {
      return null;
    }
    return onTap != null ? InkWell(onTap: onTap, child: child) : child;
  }

  /// Build Error
  Widget _buildError(String error) {
    return Padding(
      padding: EdgeInsets.all(defaultPadding).copyWith(top: 4, bottom: 4),
      child: AppText.multiLine(error, textColor: AppColors.red),
    );
  }
}
