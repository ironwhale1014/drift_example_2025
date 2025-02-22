import 'package:drift/drift.dart';
import 'package:my_drift_train/common/entity/cursor_pagination_entity.dart';
import 'package:my_drift_train/common/logger.dart';
import 'package:my_drift_train/memo/repository/memo_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../database/database_connector.dart';

part 'memo_service.g.dart';

@riverpod
class MemoService extends _$MemoService {
  late final MemoRepository _memoRepository;

  @override
  CursorPaginationBase build() {
    _memoRepository = ref.read(memoRepositoryProvider);
    return CursorPaginationLoading();
  }

  // Read
  Future<void> paginate({
    bool isNextPagination = false,
    bool isRefresh = false,
  }) async {
    // paginate 메소드가 실행 되야하는 상황
    // 처음 데이터를 받아올때 = 새로 고침 할때
    // 다음 데이터를 받아올때

    // 실행되면 안되는 상황
    // 데이터를 받아오는 중일때
    // 다음 데이터가 없을때

    bool isLoading = state is CursorPaginationLoading;
    bool isFetchMore = state is CursorFetchMore;

    // lastId가 null 처음 시작할때 또는 강제로 새로고침
    int? lastId;

    //&& !isRefresh 없으면 데이터가 있는 CursorPaginationModel 상태에서 강제 새로 고침이 작동 안함
    if (state is CursorPaginationModel && !isRefresh) {
      final pState = state as CursorPaginationModel;
      if (!pState.metaData.hasMore) {
        return;
      }
    }

    // (isNextPagination || isRefresh)은 없으면 데이터를 받아오는 로직으로 안넘어가고 로딩만 돌듯
    if ((isNextPagination || isRefresh) && (isLoading || isFetchMore)) {
      return;
    }

    if (isNextPagination) {
      final pState = state as CursorPaginationModel<Memo>;
      state = CursorFetchMore(metaData: pState.metaData, datas: pState.datas);
      lastId = pState.metaData.lastId;
    }

    if (isRefresh) {
      state = CursorPaginationLoading();
    }

    final CursorPaginationModel<Memo> resp = await _memoRepository.findAll(
      id: lastId,
      take: 10,
    );

    if (state is CursorFetchMore) {
      final pState = state as CursorFetchMore<Memo>;
      state = resp.copyWith(datas: [...pState.datas, ...resp.datas]);
    } else {
      state = resp;
    }
  }

  Future<void> update({required int id, String? title, String? content}) async {
    final Memo? findMemo = await _memoRepository.findById(id: id);
    if (findMemo == null) {
      throw Exception('not exist Memo');
    }

    await _memoRepository.update(
      id: id,
      memo: MemosCompanion(
        title: title != null ? Value(title) : const Value.absent(),
        content: content != null ? Value(content) : const Value.absent(),
      ),
    );

    final pState = state as CursorPaginationModel<Memo>;

    state = pState.copyWith(
      datas: List.from(
        pState.datas.map(
          (memo) =>
              memo.id == id
                  ? memo.copyWith(title: title, content: content)
                  : memo,
        ),
      ),
    );
  }

  // Create
  Future<void> create({required String title, required String content}) async {
    await _memoRepository.create(title: title, content: content);
  }

  //Delete
  Future<int> delete({required int id}) async {
    final Memo? findMemo = await _memoRepository.findById(id: id);
    if (findMemo == null) {
      throw Exception('not exist Memo');
    }
    final pState = state as CursorPaginationModel<Memo>;
    pState.datas.removeWhere((e) => e.id == id);
    state = pState.copyWith(datas: pState.datas);

    await _memoRepository.delete(id: id);

    return id;
  }
}
