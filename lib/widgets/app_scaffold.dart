import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final bool withScroll;

  static const double maxContentWidth = 430;

  const AppScaffold({
    super.key,
    required this.child,
    this.withScroll = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            child: withScroll
                ? SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    child: child,
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    child: child,
                  ),
          ),
        ),
      ),
    );
  }
}