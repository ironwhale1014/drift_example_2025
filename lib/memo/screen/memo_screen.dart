import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_drift_train/common/entity/cursor_pagination_entity.dart';
import 'package:my_drift_train/common/layout/default_layout.dart';
import 'package:my_drift_train/database/database_connector.dart';
import 'package:my_drift_train/excel/get_excel_provider.dart';
import 'package:my_drift_train/memo/screen/edit_memo_screen.dart';
import 'package:my_drift_train/memo/service/memo_service.dart';

class MemoScreen extends ConsumerStatefulWidget {
  const MemoScreen({super.key});

  static String get routeName => 'MemoScreen';

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
    if (_scrollController.offset >
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(memoServiceProvider.notifier).paginate(isNextPagination: true);
    }
  }

  Future<void> saveMemoFromExcel() async {
    await ref.read(getExcelProvider.notifier).saveMemoFromExcel();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memoServiceProvider);

    if (state is CursorPaginationLoading) {
      return DefaultLayout(
        title: "memo Screen",
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add),
        ),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final pState = state as CursorPaginationModel<Memo>;

    Size size = MediaQuery.of(context).size;
    return DefaultLayout(
      title: "memo Screen",
      actions: [
        MaterialButton(onPressed: saveMemoFromExcel, child: Icon(Icons.add)),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed(EditMemoScreen.routeName).then((value) {
            ref.read(memoServiceProvider.notifier).paginate(isRefresh: true);
          });
        },
        child: Icon(Icons.add),
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          ref.read(memoServiceProvider.notifier).paginate(isRefresh: true);
        },
        child: ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          itemCount: pState.datas.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (pState.datas.isEmpty) {
              return SizedBox(
                height: size.height-100,
                child: Center(child: Text('메모가 없습니다.\n메모를 입력 해주세요',style: TextStyle(fontSize: 24),)),
              );
            }

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
                context.goNamed(EditMemoScreen.routeName, extra: memo);
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
      ),
    );
  }
}
