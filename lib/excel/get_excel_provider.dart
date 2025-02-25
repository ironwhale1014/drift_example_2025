import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_drift_train/memo/service/memo_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../common/logger.dart';
import 'excel_memo.dart';

part 'get_excel_provider.g.dart';


@riverpod
class GetExcel extends _$GetExcel {
  @override
  List build() {
    return [];
  }

  Future<void> saveMemoFromExcel() async {
    final List<ExcelMemo>? memos = await _getExcelFile();
    if (memos != null) {
      for (final ExcelMemo memo in memos) {
        await ref
            .read(memoServiceProvider.notifier)
            .create(title: memo.title, content: memo.content);
      }
      ref.read(memoServiceProvider.notifier).paginate(isRefresh: true);
    }
  }

  Future<List<ExcelMemo>?> _getExcelFile() async {
    final pickFiles = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (pickFiles == null) {
      logger.e("no file");
      return null;
    }

    final File file = File(pickFiles.files.single.path!);
    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    final sheet = excel.tables.keys.first;
    final table = excel.tables[sheet];

    if (table == null) {
      logger.e("no data");
      return null;
    }
    List<ExcelMemo> memos = [];
    for (final row in table.rows) {
      memos.add(
        ExcelMemo(
          title: row[0]?.value.toString() ?? "",
          content: row[1]?.value.toString() ?? '',
        ),
      );
    }

    return memos;
  }
}


