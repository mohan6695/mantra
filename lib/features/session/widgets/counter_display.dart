import 'package:flutter/material.dart';

/// Animated counter display that smoothly transitions between numbers.
class CounterDisplay extends StatelessWidget {
  final int count;
  final Color? color;
  final TextStyle? style;

  const CounterDisplay({
    super.key,
    required this.count,
    this.color,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = color ?? theme.colorScheme.primary;
    final textStyle = style ??
        theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: textColor,
        );

    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: count),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Text(
          '$value',
          style: textStyle,
        );
      },
    );
  }
}
