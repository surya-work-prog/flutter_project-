import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? Responsive.maxContentWidth(context),
        ),
        child: Padding(
          padding: padding ??
              EdgeInsets.symmetric(
                horizontal: Responsive.horizontalPadding(context),
                vertical: 20,
              ),
          child: child,
        ),
      ),
    );
  }
}