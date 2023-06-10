import 'package:flutter_orm/converter/base_converter.dart';

class NullableBoolConverter implements BaseConverter<bool?, int?> {
  @override
  int? from(bool? value) {
    if (value == null) return null;
    return value ? 1 : 0;
  }

  @override
  bool? to(int? value) {
    if (value == null) return null;
    return value == 1;
  }
}
