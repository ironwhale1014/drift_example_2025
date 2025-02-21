import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_drift_train/memo/entity/memos.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_connector.g.dart';

@Riverpod(keepAlive: true)
DataBaseConnector databaseConnector(Ref ref) {
  return DataBaseConnector();
}

@DriftDatabase(tables: [Memos])
class DataBaseConnector extends _$DataBaseConnector {
  DataBaseConnector() : super(_openConnection());

  @override
  // TODO: implement schemaVersion
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final folder = await getApplicationDocumentsDirectory();
      final file = File(p.join(folder.path, 'sqlite/my_db.db'));

      return NativeDatabase.createInBackground(file);
    });
  }
}
