import 'package:flutter_orm/converter/base_converter.dart';

class BoolConverter implements BaseConverter<bool, int> {
  @override
  int from(bool value) {
    return value ? 1 : 0;
  }

  @override
  bool to(int value) {
    return value == 1;
  }
}
