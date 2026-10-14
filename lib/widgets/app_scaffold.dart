import 'package:flutter/material.dart';
import '../themes/Light.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final bool withScroll;

  /// Максимальная ширина контента на широких экранах.
  static const double maxContentWidth = 480;

  const AppScaffold({
    super.key,
    required this.child,
    this.withScroll = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Light.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: maxContentWidth,
            ),
            child: withScroll
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(Light.space6),
                    child: child,
                  )
                : Padding(
                    padding: const EdgeInsets.all(Light.space6),
                    child: child,
                  ),
          ),
        ),
      ),
    );
  }
}