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
  Future<void> paginate({bool isNextPagination = false}) async {
    bool isLoading = state is CursorPaginationLoading;
    bool isFetchMore = state is CursorFetchMore;

    int? lastId;

    if (isNextPagination && (isLoading || isFetchMore)) {
      return;
    }

    if (state is CursorPaginationModel) {
      final pState = state as CursorPaginationModel;
      if (!pState.metaData.hasMore) {
        return;
      }
    }

    if (isNextPagination) {
      logger.d("isNextPagination");
      final pState = state as CursorPaginationModel<Memo>;
      state = CursorFetchMore(metaData: pState.metaData, datas: pState.datas);
      lastId = pState.metaData.lastId;
    }

    final resp = await _memoRepository.findAll(id: lastId, take: 10);

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

    // 기존 state가 CursorPaginationModel<Memo> 인지 체크 후 업데이트
    if (state is CursorPaginationModel<Memo>) {
      final pState = state as CursorPaginationModel<Memo>;

      state = pState.copyWith(
        datas: List.from(pState.datas.map(
              (memo) => memo.id == id
              ? memo.copyWith(title: title, content: content)
              : memo,
        )),
      );
    }
  }

  // Create
  Future<void> create({required String title, required String content}) async {
    final Memo memo = await _memoRepository.create(
      title: title,
      content: content,
    );

    final pState = state as CursorPaginationModel<Memo>;

    state = pState.copyWith(datas: [...pState.datas, memo]);
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
