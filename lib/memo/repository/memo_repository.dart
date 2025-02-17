import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_drift_train/database/database_connector.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'memo_repository.g.dart';

@riverpod
MemoRepository memoRepository(Ref ref) {
  final dataBaseConnector = ref.read(databaseConnectorProvider);

  return MemoRepository(dataBaseConnector: dataBaseConnector);
}

class MemoRepository {
  MemoRepository({required this.dataBaseConnector});

  final DataBaseConnector dataBaseConnector;

  Future<Memo> create({required title, required content}) async {
    final id = await dataBaseConnector
        .into(dataBaseConnector.memos)
        .insert(MemosCompanion.insert(title: title, content: content));

    return (dataBaseConnector.select(dataBaseConnector.memos)
      ..where((tbl) => tbl.id.equals(id))).getSingle();
  }
}
