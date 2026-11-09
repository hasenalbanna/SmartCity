import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final double maxWidth;
  final bool safeArea;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.drawer,
    this.maxWidth = 1100,
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: body,
      ),
    );

    if (safeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      backgroundColor: AppColors.background(context),
      drawerScrimColor: Colors.black.withValues(alpha: 0.20),
      appBar: appBar,
      drawer: drawer,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient(context),
        ),
        child: SizedBox.expand(child: content),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
