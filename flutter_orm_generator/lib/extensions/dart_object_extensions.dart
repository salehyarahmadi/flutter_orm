import 'package:analyzer/dart/constant/value.dart';
import 'package:flutter_orm/utils/index.dart';

extension DartObjectExtension on DartObject {
  Index convertToTableIndex() {
    List<String> columns = getField('columns')
            ?.toListValue()
            ?.map((e) => e.toStringValue())
            .whereType<String>()
            .toList() ??
        [];
    String? name = getField('name')?.toStringValue();
    bool? unique = getField('unique')?.toBoolValue();
    List<IndexOrder> orders = getField('orders')
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
