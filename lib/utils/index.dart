import 'package:analyzer/dart/constant/value.dart';

class Index {
  final List<String> columns;
  final String? name;
  final bool unique;
  final List<IndexOrder> orders;

  const Index({
    this.columns = const [],
    this.name,
    this.unique = false,
    this.orders = const [],
  });

  static Index fromDartObject(DartObject dartObject) {
    List<String> columns = dartObject
            .getField('columns')
            ?.toListValue()
            ?.map((e) => e.toStringValue())
            .whereType<String>()
            .toList() ??
        [];
    String? name = dartObject.getField('name')?.toStringValue();
    bool? unique = dartObject.getField('unique')?.toBoolValue();
    List<IndexOrder> orders = dartObject
            .getField('orders')
            ?.toListValue()
            ?.map((e) => indexOrderFromInt(e.getField('index')?.toIntValue()))
            .toList() ??
        [];

    return Index(
      columns: columns,
      name: name,
      unique: unique ?? false,
      orders: orders,
    );
  }
}

enum IndexOrder { asc, desc }

extension IndexOrderExtension on IndexOrder {
  String get name {
    switch(this) {
      case IndexOrder.asc:
        return 'asc';
      case IndexOrder.desc:
        return 'desc';
    }
  }
}

IndexOrder indexOrderFromInt(int? index) {
  if (index == 0) return IndexOrder.asc;
  if (index == 1) return IndexOrder.desc;
  return IndexOrder.asc;
}
