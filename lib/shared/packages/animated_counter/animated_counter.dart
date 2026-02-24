// ignore_for_file: deprecated_member_use

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class AnimatedFlipCounter extends StatelessWidget {
  final num value;
  final Duration duration;
  final Curve curve;
  final TextStyle? textStyle;
  final String? prefix;
  final String? suffix;
  final int fractionDigits;
  final int wholeDigits;
  final String? thousandSeparator;
  final String decimalSeparator;
  final MainAxisAlignment mainAxisAlignment;
  final EdgeInsets padding;

  const AnimatedFlipCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.linear,
    this.textStyle,
    this.prefix,
    this.suffix,
    this.fractionDigits = 0,
    this.wholeDigits = 1,
    this.thousandSeparator,
    this.decimalSeparator = '.',
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.padding = EdgeInsets.zero, //
  }) : assert(fractionDigits >= 0, "fractionDigits must be non-negative"),
       assert(wholeDigits >= 0, "wholeDigits must be non-negative");

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style.merge(textStyle);
    // Layout number "8" (probably the widest digit) to see its size
    final prototypeDigit = TextPainter(
      text: TextSpan(text: "8", style: style),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.of(context).textScaler,
    )..layout();

    // Find the text color (or red as warning). This is so we can avoid using
    // `Opacity` and `AnimatedOpacity` widget, for better performance.
    final Color color = style.color ?? const Color(0xffff0000);

    // Convert the decimal value to int. For example, if we want 2 decimal
    // places, we will convert 5.21 into 521.
    final int value = (this.value * math.pow(10, fractionDigits)).round();

    // Split the integer value into separate digits.
    // For example, to draw 521, we split it into [5, 52, 521].
    List<int> digits = value == 0 ? [0] : [];
    int v = value.abs();
    while (v > 0) {
      digits.add(v);
      v = v ~/ 10;
    }
    while (digits.length < wholeDigits + fractionDigits) {
      digits.add(0); // padding leading zeroes
    }
    digits = digits.reversed.toList(growable: false);

    // Generate the widgets needed for digits before the decimal point.
    final integerWidgets = <Widget>[];
    for (int i = 0; i < digits.length - fractionDigits; i++) {
      final digit = _SingleDigitFlipCounter(
        key: ValueKey(digits.length - i),
        value: digits[i].toDouble(),
        duration: duration,
        curve: curve,
        size: prototypeDigit.size,
        color: color,
        padding: padding, //
      );
      integerWidgets.add(digit);
    }
    // Insert "thousand separator" widgets if needed.
    if (thousandSeparator != null) {
      int counter = 0;
      for (int i = integerWidgets.length; i > 0; i--) {
        if (counter > 0 && counter % 3 == 0) {
          integerWidgets.insert(i, Text(thousandSeparator!));
        }
        counter++;
      }
    }

    return DefaultTextStyle.merge(
      style: style,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: mainAxisAlignment,
        children: [
          if (prefix != null) Text(prefix!),
          ClipRect(
            child: TweenAnimationBuilder(
              // Animate the negative sign (-) appear and disappearing
              duration: duration,
              tween: Tween(end: value < 0 ? 1.0 : 0.0),
              builder: (_, double v, __) => Center(
                widthFactor: v,
                child: Opacity(opacity: v, child: const Text("-")),
              ),
            ),
          ),
          // Draw digits before the decimal point
          ...integerWidgets,
          // Draw the decimal point
          if (fractionDigits != 0) Text(decimalSeparator),
          // Draw digits after the decimal point
          for (int i = digits.length - fractionDigits; i < digits.length; i++)
            _SingleDigitFlipCounter(
              key: ValueKey("decimal$i"),
              value: digits[i].toDouble(),
              duration: duration,
              curve: curve,
              size: prototypeDigit.size,
              color: color,
              padding: padding, //
            ),
          if (suffix != null) Text(suffix!),
        ],
      ),
    );
  }
}

class _SingleDigitFlipCounter extends StatelessWidget {
  final double value;
  final Duration duration;
  final Curve curve;
  final Size size;
  final Color color;
  final EdgeInsets padding;

  const _SingleDigitFlipCounter({
    super.key,
    required this.value,
    required this.duration,
    required this.curve,
    required this.size,
    required this.color,
    required this.padding, //
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween(end: value),
      duration: duration,
      curve: curve,
      builder: (_, double value, __) {
        final whole = value ~/ 1;
        final decimal = value - whole;
        final w = size.width + padding.horizontal;
        final h = size.height + padding.vertical;

        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            children: <Widget>[
              _buildSingleDigit(digit: whole % 10, offset: h * decimal, opacity: 1 - decimal),
              _buildSingleDigit(digit: (whole + 1) % 10, offset: h * decimal - h, opacity: decimal),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSingleDigit({required int digit, required double offset, required double opacity}) {
    // Try to avoid using the `Opacity` widget when possible, for performance.
    final Widget child;
    if (color.opacity == 1) {
      // If the text style does not involve transparency, we can modify
      // the text color directly.
      child = Text(
        '$digit',
        textAlign: TextAlign.center,
        style: TextStyle(color: color.withOpacity(opacity.clamp(0, 1))),
      );
    } else {
      // Otherwise, we have to use the `Opacity` widget (less performant).
      child = Opacity(
        opacity: opacity.clamp(0, 1),
        child: Text('$digit', textAlign: TextAlign.center),
      );
    }
    return Positioned(left: 0, right: 0, bottom: offset + padding.bottom, child: child);
  }
}
