import 'package:flutter_orm/converter/base_converter.dart';

/// This class is a converter for [double] type.
/// [double] converts to [num] that is a sqlite supported type.
class DoubleConverter implements BaseConverter<double, num> {
  @override
  num from(double value) {
    num n = value;
    return n;
  }

  @override
  double to(num value) {
    return value.toDouble();
  }
}
