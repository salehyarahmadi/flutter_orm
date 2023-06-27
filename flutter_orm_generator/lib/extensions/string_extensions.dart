import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/annotations/db_annotations.dart';
import 'package:flutter_orm/converter/built_in_support_converters_helper.dart';
import 'package:flutter_orm_generator/extensions/element_extensions.dart';
import 'package:flutter_orm_generator/utils/constants.dart';

extension StringExtension on String {
  bool isBuiltInType() {
    return builtInTypes.keys.contains(this);
  }

  bool isNotBuiltInType() {
    return !builtInTypes.keys.contains(this);
  }

  bool isPredefinedConverterType() {
    return PredefinedConvertersHelper.isPredefinedConverterType(this);
  }

  bool isNullable() {
    return contains('?');
  }

  bool isNotNullable() {
    return !contains('?');
  }

  Iterable<RegExpMatch> getAllVariablesTemplate() {
    final variablePattern = RegExp(r':[a-zA-Z][a-zA-Z0-9_]+');
    return variablePattern.allMatches(this);
  }

  String helperClassName() => '${this}Helper';

  String implClassName() => '${this}Impl';

  bool isEntity(ClassElement dbClass) {
    return dbClass
            .getListFieldFromAnnotation(DB, DB.fields.entities)
            ?.map((e) => e.toTypeValue()?.element?.name)
            .toList()
            .contains(this) ??
        false;
  }

  bool isListOfEntity(ClassElement dbClass) {
    if (!contains('List<')) return false;
    int index = indexOf('List<');
    if (contains('List<', index + 5)) return false;
    String entityName = substring(index + 5, indexOf('>'));
    return entityName.isEntity(dbClass);
  }

  String appendIfNotEmpty(String str) => this + (this.isNotEmpty ? str : '');

  String appendUnderscoreIfNotEmpty() => this.appendIfNotEmpty('_');
}
