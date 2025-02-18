import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_drift_train/memo/repository/memo_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../database/database_connector.dart';

part 'memo_service.g.dart';

@Riverpod(keepAlive: true)
MemoService memoService(Ref ref) {
  final MemoRepository memoRepository = ref.read(memoRepositoryProvider);
  return MemoService(memoRepository: memoRepository);
}

class MemoService {
  final MemoRepository memoRepository;

  MemoService({required this.memoRepository});

  //Update
  Future<Memo> update({required int id, String? title, String? content}) async {
    final Memo? findMemo = await memoRepository.findById(id: id);
    if (findMemo == null) {
      throw Exception('not exist Memo');
    }
    return findMemo.copyWith(title: title, content: content);
  }

  // Read
  Future<List<Memo>> findAll() {
    return memoRepository.findAll();
  }

  // Create
  Future<Memo> create({required String title, required String content}) async {
    return memoRepository.create(title: title, content: content);
  }

  //Delete
  Future<int> delete({required int id}) async {
    final Memo? findMemo = await memoRepository.findById(id: id);
    if (findMemo == null) {
      throw Exception('not exist Memo');
    }
    return memoRepository.delete(id: id);
  }
}
