import 'package:analyzer/dart/constant/value.dart';
import 'package:flutter_orm/enums/foreign_key_action.dart';
import 'package:flutter_orm/enums/index_order.dart';
import 'package:flutter_orm/utils/foreign_key.dart';
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

  ForeignKey convertToForeignKey() {
    Object entity = getField('entity') as Object;
    List<String> parentColumns = getField('parentColumns')!
        .toListValue()!
        .map((e) => e.toStringValue()!)
        .toList();
    List<String> childColumns = getField('childColumns')!
        .toListValue()!
        .map((e) => e.toStringValue()!)
        .toList();
    ForeignKeyAction onDelete = foreignKeyActionFromInt(
        getField('onDelete')?.getField('index')?.toIntValue());
    ForeignKeyAction onUpdate = foreignKeyActionFromInt(
        getField('onUpdate')?.getField('index')?.toIntValue());
    bool deferred = getField('deferred')?.toBoolValue() ?? false;
    return ForeignKey(
      entity: entity,
      parentColumns: parentColumns,
      childColumns: childColumns,
      onDelete: onDelete,
      onUpdate: onUpdate,
      deferred: deferred,
    );
  }
}
