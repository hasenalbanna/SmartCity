import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? accentBorderColor;
  final Color? backgroundColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSpace.cardPadding,
    this.onTap,
    this.accentBorderColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final surface = backgroundColor ?? AppColors.surface(context);
    final outline = AppColors.outline(context);

    Widget content = Padding(padding: padding, child: child);
    if (accentBorderColor != null) {
      content = IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accentBorderColor,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(AppRadius.md),
                ),
              ),
            ),
            Expanded(child: content),
          ],
        ),
      );
    }

    return Material(
      color: surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdBorder,
        side: BorderSide(color: outline, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: AppRadius.mdBorder,
              child: content,
            )
          : content,
    );
  }
}
