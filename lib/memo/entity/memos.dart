import 'package:drift/drift.dart';
import 'package:my_drift_train/database/common_entity.dart';

class Memos extends Table with TableMixin {
  TextColumn get title => text().withLength(min: 6, max: 32)();

  TextColumn get content => text().named('body')();
}
