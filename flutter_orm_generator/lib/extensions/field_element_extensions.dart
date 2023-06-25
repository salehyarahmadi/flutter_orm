import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/annotations/entity_annotations.dart';
import 'package:source_gen/source_gen.dart';

import 'extensions.dart';

const _primaryKeyChecker = TypeChecker.fromRuntime(PrimaryKey);
const _columnChecker = TypeChecker.fromRuntime(Column);
const _embeddedChecker = TypeChecker.fromRuntime(Embedded);

extension FieldElementExtension on FieldElement {
  String getColumnName() {
    if (_primaryKeyChecker.hasAnnotationOfExact(this)) {
      return getStringFieldFromAnnotation(PrimaryKey, PrimaryKey.fields.name) ??
          name;
    }
    if (_columnChecker.hasAnnotationOfExact(this)) {
      return getStringFieldFromAnnotation(Column, Column.fields.name) ?? name;
    }
    return name;
  }

  bool isEmbeddedField() {
    return _embeddedChecker.hasAnnotationOfExact(this);
  }
}
