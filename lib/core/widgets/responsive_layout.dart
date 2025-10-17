import 'package:flutter/material.dart';
import '../utils/breakpoints.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (Breakpoints.isDesktop(context)) {
          return desktop ?? tablet ?? mobile;
        }
        if (Breakpoints.isTablet(context)) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints)
  builder;
  final double? maxWidth;

  const ResponsiveBuilder({super.key, required this.builder, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? Breakpoints.contentMaxWidth(context),
        ),
        child: Padding(
          padding: Breakpoints.screenPadding(context),
          child: LayoutBuilder(builder: builder),
        ),
      ),
    );
  }
}
