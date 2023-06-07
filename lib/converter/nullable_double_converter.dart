import 'package:flutter_orm/converter/base_converter.dart';

class NullableDoubleConverter implements BaseConverter<double?, num?> {
  @override
  num? from(double? value) {
    if (value == null) return null;
    num n = value;
    return n;
  }

  @override
  double? to(num? value) {
    if (value == null) return null;
    return value.toDouble();
  }
}
