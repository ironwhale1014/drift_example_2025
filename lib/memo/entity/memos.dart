import 'package:drift/drift.dart';
import 'package:my_drift_train/database/table_mixin.dart';

class Memos extends Table with TableMixin {
  TextColumn get title => text()();

  TextColumn get content => text()();
}
