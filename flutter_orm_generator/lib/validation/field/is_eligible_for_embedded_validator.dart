import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm_generator/extensions/extensions.dart';
import 'package:flutter_orm_generator/validation/validator.dart';

class IsEligibleForEmbeddedValidator extends ElementValidator<FieldElement> {
  final ClassElement dbClass;
  String? message;

  IsEligibleForEmbeddedValidator(this.dbClass, {this.message});

  @override
  check(FieldElement element) {
    if (element.type.isBuiltInType()) {
      throw Exception('${element.type.nameWithNullable()} ${element.name}: '
          'this field cannot be embedded, because '
          'this type supported internally by SQLite');
    }
    if (element.type.isPredefinedConverterType()) {
      throw Exception('${element.type.nameWithNullable()} ${element.name}: '
          'this field cannot be embedded, because '
          'this type supported internally');
    }
    if (dbClass
        .getUserDefinedConvertibleTypes()
        .keys
        .contains(element.type.nameWithNullable())) {
      throw Exception('${element.type.nameWithNullable()} ${element.name}: '
          'this field cannot be embedded, because '
          'this type converted before using @TypeConverter');
    }

    String? currentPackageName = dbClass.getPackageName();
    String? embeddedFieldPackageName = element.type.element?.getPackageName();
    if (currentPackageName != embeddedFieldPackageName) {
      throw Exception('${element.type.nameWithNullable()} ${element.name}: '
          'this field cannot be embedded, because '
          'this type is not in your own package: ${currentPackageName}');
    }

    checkNext(element);
  }
}
