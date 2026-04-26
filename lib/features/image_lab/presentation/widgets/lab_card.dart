import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';

class LabCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<BoxShadow>? shadow;
  final Color? color;
  final double? radius;
  final Border? border;

  const LabCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.shadow,
    this.color,
    this.radius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.card,
        borderRadius: BorderRadius.circular(radius ?? AppRadii.card),
        border: border ?? Border.all(color: AppColors.border),
        boxShadow: shadow ?? AppShadows.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius ?? AppRadii.card),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(0),
          child: child,
        ),
      ),
    );
  }
}
