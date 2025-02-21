import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomTextField extends ConsumerWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.validator,
    this.hintText,
  });

  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final String? hintText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(borderSide: BorderSide(width: 1)),
      ),
    );
  }
}
