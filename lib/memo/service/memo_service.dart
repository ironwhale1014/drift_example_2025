import 'dart:math';

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
    logger.d("hey");
    logger.d(isNextPagination);

    if (isNextPagination) {
      logger.d("isNextPagination");
      final pState = state as CursorPaginationModel<Memo>;
      state = CursorFetchMore(metaData: pState.metaData, datas: pState.datas);
      lastId = pState.metaData.lastId;
    }

    final resp = await _memoRepository.findAll(id: lastId, take: 10);

    if (state is CursorFetchMore) {
      final pState = state as CursorPaginationModel<Memo>;
      state = CursorFetchMore(
        metaData: pState.metaData.copyWith(lastId: resp.datas.last.id),
        datas: [...pState.datas, ...resp.datas],
      );
    } else {
      state = resp;
    }
  }

  //Update
  Future<void> update({required int id, String? title, String? content}) async {
    final Memo? findMemo = await _memoRepository.findById(id: id);
    if (findMemo == null) {
      throw Exception('not exist Memo');
    }

    final updatedMemo = findMemo.copyWith(title: title, content: content);
    final pState = state as CursorPaginationModel<Memo>;
    state = pState.copyWith(
      datas:
          pState.datas
              .map((memo) => memo.id == id ? updatedMemo : memo)
              .toList(),
    );

    await _memoRepository.update(id: id, memo: updatedMemo);
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
