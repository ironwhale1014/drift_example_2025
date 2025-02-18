import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_drift_train/common/layout/default_layout.dart';
import 'package:my_drift_train/database/database_connector.dart';
import 'package:my_drift_train/memo/service/memo_service.dart';

class MemoScreen extends ConsumerStatefulWidget {
  const MemoScreen({super.key});

  @override
  ConsumerState createState() => _MemoScreenState();
}

class _MemoScreenState extends ConsumerState<MemoScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ref.read(memoServiceProvider.notifier).paginate();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memoServiceProvider);

    return DefaultLayout(
      title: "memo Screen",
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref
              .read(memoServiceProvider.notifier)
              .create(title: 'test!!!!!!!!', content: 'test');
        },
        child: Icon(Icons.add),
      ),
      child:
          (state.isEmpty)
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: state.length,
                itemBuilder: (BuildContext context, int index) {
                  Memo memo = state[index];
                  return InkWell(
                    onTap: () {
                      ref
                          .read(memoServiceProvider.notifier)
                          .update(id: memo.id, title: "update");
                    },
                    onDoubleTap: () {
                      ref
                          .read(memoServiceProvider.notifier)
                          .delete(id: memo.id);
                    },
                    child: ListTile(
                      title: Text(memo.title),
                      // leading: Text(memo.content),
                    ),
                  );
                },
              ),
    );
  }
}
