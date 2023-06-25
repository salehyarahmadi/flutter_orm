import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/annotations/entity_annotations.dart';
import 'package:flutter_orm_generator/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm_generator/code_generators/column_code_generator_adapter.dart';
import 'package:flutter_orm_generator/extensions/extensions.dart';
import 'package:flutter_orm_generator/validation/field/is_eligible_for_embedded_validator.dart';

class EmbeddedColumnCodeGeneratorAdapter extends CodeGeneratorAdapter {
  final ClassElement dbClass;
  final String prevPrefix;
  final bool hasAnyNullablePrefix;

  EmbeddedColumnCodeGeneratorAdapter(
    this.dbClass, {
    this.prevPrefix = '',
    this.hasAnyNullablePrefix = false,
  });

  @override
  String generate(Element? element) {
    FieldElement embeddedField = element as FieldElement;
    _validation(embeddedField);
    String prefix = embeddedField.getStringFieldFromAnnotation(
            Embedded, Embedded.fields.prefix) ??
        embeddedField.name;
    ClassElement embeddedClass = embeddedField.type.element as ClassElement;
    String embeddedFieldsQuery = CodeGeneratorBuilder(
      ColumnCodeGeneratorAdapter(
        dbClass,
        entityCheck: false,
        prefix: '${prevPrefix}${prevPrefix.isNotEmpty ? '_' : ''}$prefix',
        hasAnyNullablePrefix: hasAnyNullablePrefix,
      ),
    ).element(embeddedClass).generate();

    return embeddedFieldsQuery;
  }

  _validation(FieldElement embeddedField) {
    IsEligibleForEmbeddedValidator(dbClass).check(embeddedField);
  }
}
