import 'package:flutter_orm/utils/constants.dart';

extension StringExtension on String {
  bool isBuiltIn() {
    return builtInTypes.keys.contains(this);
  }

  bool isNotBuiltIn() {
    return !builtInTypes.keys.contains(this);
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
}
