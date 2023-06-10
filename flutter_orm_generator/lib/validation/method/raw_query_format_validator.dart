import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/annotations/dao_annotations.dart';
import 'package:flutter_orm_generator/extensions/extensions.dart';
import 'package:flutter_orm_generator/validation/validator.dart';

class RawQueryFormatValidator extends ElementValidator<MethodElement> {
  String? message;

  RawQueryFormatValidator({this.message});

  @override
  check(MethodElement element) {
    String query =
        element.getStringFieldFromAnnotation(Query, Query.fields.query) ?? '';
    if (query.isEmpty) {
      throw Exception('${element.name} method: query cannot be empty');
    }

    for (var match in query.getAllVariablesTemplate()) {
      String variableName = query.substring(match.start + 1, match.end);
      if (!element.parameters
          .map((e) => e.name)
          .toList()
          .contains(variableName)) {
        throw Exception('${element.name} method must has a parameter '
            'with name: $variableName');
      }
    }
    checkNext(element);
  }
}
