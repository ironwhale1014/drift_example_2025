import 'package:flutter/material.dart';

class DefaultLayout extends StatelessWidget {
  const DefaultLayout({
    super.key,
    required this.child,
    this.title,
    this.floatingActionButton,
    this.actions,
  });

  final String? title;
  final Widget child;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: renderAppbar(title),
      body: child,
      floatingActionButton: floatingActionButton,
    );
  }

  renderAppbar(String? title) {
    if (title == null) {
      return null;
    }

    return AppBar(
      title: Text(title),
      actions: actions,
      centerTitle: true,
      backgroundColor: Colors.amber,
    );
  }
}
