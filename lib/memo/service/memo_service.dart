import 'package:my_drift_train/common/logger.dart';
import 'package:my_drift_train/memo/repository/memo_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../database/database_connector.dart';

part 'memo_service.g.dart';

@riverpod
class MemoService extends _$MemoService {
  late final MemoRepository _memoRepository;

  @override
  List<Memo> build() {
    _memoRepository = ref.read(memoRepositoryProvider);
    return [];
  }

  // Read
  Future<List<Memo>> paginate() async {
    state = await _memoRepository.findAll();
    return _memoRepository.findAll();
  }

  //Update
  Future<Memo> update({required int id, String? title, String? content}) async {
    final Memo? findMemo = await _memoRepository.findById(id: id);
    if (findMemo == null) {
      throw Exception('not exist Memo');
    }

    final updatedMemo = findMemo.copyWith(title: title, content: content);
    final pState = state;
    state = pState.map((memo) => memo.id == id ? updatedMemo : memo).toList();

    await _memoRepository.update(id: id, memo: updatedMemo);

    return updatedMemo;
  }

  // Create
  Future<Memo> create({required String title, required String content}) async {
    final Memo memo = await _memoRepository.create(
      title: title,
      content: content,
    );

    final pState = state;

    state = [...pState, memo];

    logger.d(state);
    return memo;
  }

  //Delete
  Future<int> delete({required int id}) async {
    final Memo? findMemo = await _memoRepository.findById(id: id);
    if (findMemo == null) {
      throw Exception('not exist Memo');
    }
    final pState = state;
    pState.removeWhere((e) => e.id == id);
    state = [...pState];

    await _memoRepository.delete(id: id);

    return id;
  }
}
