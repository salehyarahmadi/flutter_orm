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

enum IndexOrder { asc, desc }

extension IndexOrderExtension on IndexOrder {
  String get name {
    switch (this) {
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
