import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_drift_train/common/entity/cursor_pagination_entity.dart';
import 'package:my_drift_train/database/database_connector.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'memo_repository.g.dart';

@Riverpod(keepAlive: true)
MemoRepository memoRepository(Ref ref) {
  final dataBaseConnector = ref.read(databaseConnectorProvider);

  return MemoRepository(dataBaseConnector: dataBaseConnector);
}

class MemoRepository {
  MemoRepository({required this.dataBaseConnector});

  final DataBaseConnector dataBaseConnector;

  Future<Memo> create({required String title, required String content}) async {
    final id = await dataBaseConnector
        .into(dataBaseConnector.memos)
        .insert(MemosCompanion.insert(title: title, content: content));

    return (dataBaseConnector.select(dataBaseConnector.memos)
      ..where((tbl) => tbl.id.equals(id))).getSingle();
  }

  Future<CursorPaginationModel<Memo>> findAll({int? id, int take = 10}) async {
    bool hasMore = true;
    int? lastId;
    final query = dataBaseConnector.select(dataBaseConnector.memos);
    if (id != null) {
      query.where((memo) => memo.id.isBiggerThanValue(id));
    }

    query.limit(take);
    final List<Memo> datas = await query.get();

    if (datas.length < take) {
      hasMore = false;
    }

    if (hasMore) {
      lastId = datas.last.id;
    }

    return CursorPaginationModel(
      metaData: MetaData(lastId: lastId, hasMore: hasMore),
      datas: datas,
    );
  }

  Future<int> delete({required int id}) async {
    return (dataBaseConnector.delete(dataBaseConnector.memos)
      ..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<Memo> update({required int id, required Memo memo}) {
    (dataBaseConnector.update(dataBaseConnector.memos)
      ..where((tbl) => tbl.id.equals(id))).write(memo);

    return (dataBaseConnector.select(dataBaseConnector.memos)
      ..where((tbl) => tbl.id.equals(id))).getSingle();
  }

  Future<Memo?> findById({required int id}) async {
    return (dataBaseConnector.select(dataBaseConnector.memos)
      ..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }
}
