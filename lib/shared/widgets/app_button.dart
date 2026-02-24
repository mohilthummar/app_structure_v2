import 'package:app_structure/core/theme/app_style.dart';
import 'package:app_structure/core/utils/app_loader.dart';
import 'package:app_structure/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:app_structure/core/theme/app_text.dart';

/// Button type for AppButton
enum ButtonType { elevated, outline, gradient }

/// Image alignment for AppButton
enum ImageAlign { start, end, startTitle, endTitle }

class AppButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final String? label;
  final Widget? child;
  final Size? minimumSize;
  final bool isLoading;
  final bool disable;
  final bool safeArea;
  final bool outlined;
  final bool gradient;
  final ButtonType buttonType;
  final IconData? icon;
  final String? image;
  final Color? imageColor;
  final double? imageSize;
  final double? imageSpacing;
  final double? fontSize;
  final TextStyle? titleStyle;
  final Color? loaderColor;
  final Color? color;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? highlightColor;
  final Gradient? customGradient;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final ImageAlign? imageAlign;
  final bool enableFeedback;
  final bool useMarqueeTitle;
  final Widget? topLayerWidget;
  final Function(bool)? onHighlightChanged;

  const AppButton({
    super.key,
    required this.onPressed,
    this.label,
    this.child,
    this.minimumSize,
    this.isLoading = false,
    this.disable = false,
    this.safeArea = false,
    this.outlined = false,
    this.gradient = false,
    this.buttonType = ButtonType.elevated,
    this.icon,
    this.image,
    this.imageColor,
    this.imageSize,
    this.imageSpacing,
    this.fontSize,
    this.titleStyle,
    this.loaderColor,
    this.color,
    this.backgroundColor,
    this.borderColor,
    this.highlightColor,
    this.customGradient,
    this.borderRadius,
    this.padding,
    this.margin,
    this.imageAlign,
    this.enableFeedback = true,
    this.useMarqueeTitle = false,
    this.topLayerWidget,
    this.onHighlightChanged,
    this.onLongPress,
  });

  /// Outlined button constructor
  const AppButton.outlined({
    super.key,
    required this.onPressed,
    required this.label,
    this.minimumSize,
    this.isLoading = false,
    this.safeArea = false,
    this.disable = false,
    this.child,
    this.icon,
    this.image,
    this.imageColor,
    this.imageSize,
    this.imageSpacing,
    this.fontSize,
    this.titleStyle,
    this.loaderColor,
    this.color,
    this.backgroundColor,
    this.borderColor,
    this.highlightColor,
    this.customGradient,
    this.borderRadius,
    this.padding,
    this.margin,
    this.imageAlign,
    this.enableFeedback = true,
    this.useMarqueeTitle = false,
    this.topLayerWidget,
    this.onHighlightChanged,
    this.onLongPress,
  }) : outlined = true,
       gradient = false,
       buttonType = ButtonType.outline;

  /// Gradient button constructor
  const AppButton.gradient({
    super.key,
    required this.onPressed,
    required this.label,
    this.minimumSize,
    this.isLoading = false,
    this.safeArea = false,
    this.disable = false,
    this.child,
    this.icon,
    this.image,
    this.imageColor,
    this.imageSize,
    this.imageSpacing,
    this.fontSize,
    this.titleStyle,
    this.loaderColor,
    this.color,
    this.backgroundColor,
    this.borderColor,
    this.highlightColor,
    this.customGradient,
    this.borderRadius,
    this.padding,
    this.margin,
    this.imageAlign,
    this.enableFeedback = true,
    this.useMarqueeTitle = false,
    this.topLayerWidget,
    this.onHighlightChanged,
    this.onLongPress,
  }) : outlined = false,
       gradient = true,
       buttonType = ButtonType.gradient;

  /// Custom child button constructor
  const AppButton.custom({
    super.key,
    required this.onPressed,
    required this.child,
    this.minimumSize,
    this.isLoading = false,
    this.safeArea = false,
    this.disable = false,
    this.label,
    this.icon,
    this.image,
    this.imageColor,
    this.imageSize,
    this.imageSpacing,
    this.fontSize,
    this.titleStyle,
    this.loaderColor,
    this.color,
    this.backgroundColor,
    this.borderColor,
    this.highlightColor,
    this.customGradient,
    this.borderRadius,
    this.padding,
    this.margin,
    this.imageAlign,
    this.enableFeedback = true,
    this.useMarqueeTitle = false,
    this.topLayerWidget,
    this.onHighlightChanged,
    this.onLongPress,
  }) : outlined = false,
       gradient = false,
       buttonType = ButtonType.elevated;

  /// SafeArea button constructor
  const AppButton.safeArea({
    super.key,
    required this.onPressed,
    required this.label,
    this.minimumSize,
    this.isLoading = false,
    this.disable = false,
    this.child,
    this.icon,
    this.image,
    this.imageColor,
    this.imageSize,
    this.imageSpacing,
    this.fontSize,
    this.titleStyle,
    this.loaderColor,
    this.color,
    this.backgroundColor,
    this.borderColor,
    this.highlightColor,
    this.customGradient,
    this.borderRadius,
    this.padding,
    this.margin,
    this.imageAlign,
    this.enableFeedback = true,
    this.useMarqueeTitle = false,
    this.topLayerWidget,
    this.onHighlightChanged,
    this.onLongPress,
  }) : outlined = false,
       gradient = false,
       safeArea = true,
       buttonType = ButtonType.elevated;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  void _handleHighlightChanged(bool pressed) {
    setState(() {
      _pressed = pressed;
    });
    if (widget.onHighlightChanged != null) {
      widget.onHighlightChanged!(pressed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.disable || widget.isLoading;
    final Color effectiveBackgroundColor = widget.outlined ? Colors.transparent : (widget.backgroundColor ?? AppColors.primaryColor);
    final Color effectiveForegroundColor = widget.outlined ? (widget.color ?? AppColors.primaryTextColor) : (widget.color ?? AppColors.whiteTextColor);
    final OutlinedBorder shape = RoundedRectangleBorder(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(defaultRadius),
      side: widget.outlined ? BorderSide(color: widget.borderColor ?? AppColors.primaryColor, width: 1.2) : BorderSide.none,
    );
    final double elevation = widget.outlined ? 0 : 2;
    final Color shadowColor = widget.outlined ? Colors.transparent : (AppColors.primaryColor.withAlpha((255.0 * .2).round()));

    final Widget buttonContent = widget.isLoading ? CircularLoader(color: widget.loaderColor ?? effectiveForegroundColor) : _buildDefaultChild(context);

    Widget button = ElevatedButton(
      onPressed: isDisabled ? null : widget.onPressed,
      onLongPress: isDisabled ? null : widget.onLongPress,
      style: ElevatedButton.styleFrom(
        minimumSize: widget.minimumSize ?? Size(double.maxFinite, Get.width < 380 ? 52.h : 42.h),
        padding: widget.padding ?? REdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
        surfaceTintColor: Colors.transparent,
        shape: shape,
        backgroundColor: widget.gradient ? null : effectiveBackgroundColor,
        foregroundColor: effectiveForegroundColor,
        shadowColor: shadowColor,
        elevation: elevation,
        disabledBackgroundColor: AppColors.disableColor,
        disabledForegroundColor: AppColors.lightGreyTextColor,
      ),
      child: buttonContent,
    );

    if (widget.gradient) {
      button = Ink(
        decoration: BoxDecoration(
          gradient:
              widget.customGradient ??
              LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  AppColors.primaryColor.withAlpha(20),
                  AppColors.primaryColor,
                  AppColors.primaryColor,
                  AppColors.primaryColor.withAlpha(20),
                ],
              ),
          borderRadius: widget.borderRadius ?? BorderRadius.circular(defaultRadius),
        ),
        child: button,
      );
    }

    if (widget.safeArea) {
      button = SafeArea(
        minimum: EdgeInsets.symmetric(horizontal: defaultPadding).copyWith(bottom: defaultBottomPadding),
        child: button,
      );
    }

    // Margin
    if (widget.margin != null) {
      button = Padding(padding: widget.margin!, child: button);
    }

    // Top Layer Widget
    if (widget.topLayerWidget != null) {
      button = Stack(alignment: Alignment.center, children: [button, widget.topLayerWidget!]);
    }

    // Add Transform.scale animation
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      tween: Tween<double>(begin: 1.0, end: _pressed ? 0.96 : 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTapDown: isDisabled ? null : (_) => _handleHighlightChanged(true),
            onTapUp: isDisabled ? null : (_) => _handleHighlightChanged(false),
            onTapCancel: isDisabled ? null : () => _handleHighlightChanged(false),
            child: child,
          ),
        );
      },
      child: button,
    );
  }

  /// Build Default Child
  Widget _buildDefaultChild(BuildContext context) {
    final List<Widget> rowChildren = [];

    // Icon
    if (widget.icon != null && (widget.image == null || widget.image!.isEmpty)) {
      rowChildren.add(
        Icon(
          widget.icon,
          color: widget.color ?? AppColors.whiteTextColor,
          size: 24,
        ),
      );

      // Image Spacing
      if (widget.imageSpacing != null) {
        rowChildren.add(SizedBox(width: widget.imageSpacing));
      }
    }

    // Image Align
    if (widget.imageAlign == ImageAlign.start || widget.imageAlign == ImageAlign.startTitle) {
      rowChildren.add(_buildImageWidget());
      if (widget.imageSpacing != null) {
        rowChildren.add(SizedBox(width: widget.imageSpacing));
      }
    }

    // Label
    if (widget.label != null && widget.label!.isNotEmpty) {
      rowChildren.add(
        Flexible(
          child: AppText(
            widget.label!,
            textSize: TextSize.large_16,
            textWeight: TextWeight.w500,
            textColor: widget.color ?? AppColors.whiteTextColor,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    // Image Align
    if (widget.imageAlign == ImageAlign.end || widget.imageAlign == ImageAlign.endTitle) {
      if (widget.imageSpacing != null) rowChildren.add(SizedBox(width: widget.imageSpacing));
      rowChildren.add(_buildImageWidget());
    }

    // Return Row
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: rowChildren,
    );
  }

  /// Build Image Widget
  Widget _buildImageWidget() {
    if (widget.image == null || widget.image!.isEmpty) return const SizedBox();
    if (widget.image!.endsWith('.svg')) {
      return SvgPicture.asset(
        widget.image!,
        height: widget.imageSize ?? 22,
        colorFilter: widget.imageColor != null ? ColorFilter.mode(widget.imageColor!, BlendMode.srcIn) : null,
        alignment: Alignment.bottomLeft,
      );
    } else {
      return Image.asset(
        widget.image!,
        height: widget.imageSize ?? 22,
        color: widget.imageColor,
        alignment: Alignment.bottomLeft,
      );
    }
  }
}
