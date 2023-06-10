import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm_generator/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm_generator/extensions/extensions.dart';

class DefaultOnDowngradeCodeGeneratorAdapter extends CodeGeneratorAdapter {
  @override
  String generate(Element? element) {
    ClassElement dbClass = element as ClassElement;
    if (dbClass.hasOnDowngradeInterface() && !dbClass.hasOnDowngradeMethod()) {
      return """
@override
Future<void> onDowngrade(Database? db, int oldVersion, int newVersion) async {
}      
      """;
    }
    return '';
  }
}
