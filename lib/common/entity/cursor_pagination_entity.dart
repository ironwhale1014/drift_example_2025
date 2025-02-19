abstract class CursorPaginationBase {}

class CursorPaginationLoading extends CursorPaginationBase {}

class CursorPaginationError extends CursorPaginationBase {
  final String message;

  CursorPaginationError({required this.message});
}

class CursorPaginationModel<T> extends CursorPaginationBase {
  final MetaData metaData;
  final List<T> datas;

  CursorPaginationModel({required this.metaData, required this.datas});

  CursorPaginationModel<T> copyWith({MetaData? metaData, List<T>? datas}) {
    return CursorPaginationModel<T>(
      metaData: metaData ?? this.metaData,
      datas: datas ?? this.datas,
    );
  }
}

class CursorFetchMore<T> extends CursorPaginationModel<T> {
  CursorFetchMore({required super.metaData, required super.datas});
}

class MetaData {
  final int? lastId;

  MetaData({required this.lastId});

  MetaData copyWith({int? lastId}) {
    return MetaData(lastId: lastId ?? this.lastId);
  }
}
