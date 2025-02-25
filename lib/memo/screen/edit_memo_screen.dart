import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_drift_train/common/components/custom_text_field.dart';
import 'package:my_drift_train/common/layout/default_layout.dart';
import 'package:my_drift_train/memo/service/memo_service.dart';

import '../../database/database_connector.dart';

class EditMemoScreen extends ConsumerWidget {
  EditMemoScreen({super.key, this.memo});

  final Memo? memo;

  static String get routeName => 'EditMemoScreen';

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _titleController.text = memo?.title ?? '';
    _contentController.text = memo?.content ?? '';
    return DefaultLayout(
      title: memo == null ? 'Write Memo' : 'Edit Memo',
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              SizedBox(height: 16),
              CustomTextField(
                controller: _titleController,
                hintText: "input title",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'write title';
                  }

                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _contentController,
                hintText: "input content",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'write content';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (memo == null) {
                      await ref
                          .read(memoServiceProvider.notifier)
                          .create(
                            title: _titleController.text,
                            content: _contentController.text,
                          );
                    } else {
                      await ref
                          .read(memoServiceProvider.notifier)
                          .update(
                            id: memo!.id,
                            title: _titleController.text,
                            content: _contentController.text,
                          );
                    }
                    context.pop();
                  }
                },
                child: Text(memo == null ? "Save" : "Update"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
