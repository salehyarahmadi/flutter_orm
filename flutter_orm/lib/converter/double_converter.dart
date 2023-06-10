import 'package:flutter_orm/converter/base_converter.dart';

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
