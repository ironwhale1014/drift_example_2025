import 'package:flutter/material.dart';

class DefaultLayout extends StatelessWidget {
  const DefaultLayout({
    super.key,
    required this.child,
    this.title,
    this.floatingActionButton,
  });

  final String? title;
  final Widget child;
  final Widget? floatingActionButton;

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
      centerTitle: true,
      backgroundColor: Colors.amber,
    );
  }
}
