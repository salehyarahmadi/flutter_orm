import 'package:flutter_orm/converter/base_converter.dart';

/// This class is a converter for [bool] type.
/// [bool] converts to [int] that is a sqlite supported type.
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
