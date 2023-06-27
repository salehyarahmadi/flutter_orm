extension ListExtension on List<String> {
  bool orderInsensitiveEqual(List<String> list) {
    List<int> foundedIndex = [];
    if (length != list.length) return false;
    for (var item in this) {
      for (int i = 0; i < list.length; i++) {
        if (item == list[i] && !foundedIndex.contains(i)) {
          foundedIndex.add(i);
          break;
        }
      }
    }
    if (foundedIndex.length != length) {
      return false;
    }
    return true;
  }
}
