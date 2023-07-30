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
