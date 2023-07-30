import 'package:flutter_orm/enums/index_order.dart';

/// By using this class you can define index for your [Entity] or table.
/// For more information about index, you can refer to https://sqlite.org/
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
}
