import 'package:flutter_orm/annotations/db_annotations.dart';
import 'package:flutter_orm/converter/built_in_support_converters_helper.dart';
import 'package:flutter_orm/extensions/element_extensions.dart';
import 'package:flutter_orm/utils/constants.dart';
import 'package:analyzer/dart/element/element.dart';

extension StringExtension on String {
  bool isBuiltIn() {
    return builtInTypes.keys.contains(this);
  }

  bool isNotBuiltIn() {
    return !builtInTypes.keys.contains(this);
  }

  bool isBuiltInSupport() {
    return BuiltInSupportConvertersHelper.isBuiltInSupport(this);
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
}

extension ListExtension on List<String> {
  bool orderInsensitiveEqual(List<String> list) {
    List<int> foundedIndex = [];
    if (length != list.length) return false;
    for (var item in this) {
      for (int i = 0; i < list.length; i++) {
        if (item == list[i] && !foundedIndex.contains(i)) {
          foundedIndex.add(i);
          break;
        }
      }
    }
    if (foundedIndex.length != length) {
      return false;
    }
    return true;
  }
}