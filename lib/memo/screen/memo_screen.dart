import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_drift_train/common/entity/cursor_pagination_entity.dart';
import 'package:my_drift_train/common/layout/default_layout.dart';
import 'package:my_drift_train/common/logger.dart';
import 'package:my_drift_train/database/database_connector.dart';
import 'package:my_drift_train/memo/service/memo_service.dart';

class MemoScreen extends ConsumerStatefulWidget {
  const MemoScreen({super.key});

  @override
  ConsumerState createState() => _MemoScreenState();
}

class _MemoScreenState extends ConsumerState<MemoScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ref.read(memoServiceProvider.notifier).paginate();
    _scrollController.addListener(listener);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.removeListener(listener);
    _scrollController.dispose();
  }

  void listener() {
    logger.d(_scrollController.offset);
    if (_scrollController.offset >
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(memoServiceProvider.notifier).paginate(isNextPagination: true);
      logger.d('ddd');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memoServiceProvider);

    if (state is CursorPaginationLoading) {
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
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final pState = state as CursorPaginationModel<Memo>;

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
      child: ListView.builder(
        controller: _scrollController,
        itemCount: pState.datas.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (pState.datas.length == index) {
            return Center(
              child:
                  state is CursorFetchMore
                      ? CircularProgressIndicator()
                      : Text("마지막 입니다."),
            );
          }

          Memo memo = pState.datas[index];
          return InkWell(
            onTap: () {
              ref
                  .read(memoServiceProvider.notifier)
                  .update(id: memo.id, title: "update");
            },
            onDoubleTap: () {
              ref.read(memoServiceProvider.notifier).delete(id: memo.id);
            },
            child: ListTile(
              title: Text('${memo.id}: ${memo.title}'),
              subtitle: Text(memo.content),
              // leading: Text(memo.content),
            ),
          );
        },
      ),
    );
  }
}
