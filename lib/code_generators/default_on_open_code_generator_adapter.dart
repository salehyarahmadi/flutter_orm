import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm/extensions/extensions.dart';

class DefaultOnOpenCodeGeneratorAdapter extends CodeGeneratorAdapter {
  @override
  String generate(Element? element) {
    ClassElement dbClass = element as ClassElement;

    if (dbClass.hasOnOpenInterface() && !dbClass.hasOnOpenMethod()) {
      return """
@override
Future<void> onOpen(Database? db) async {
}      
      """;
    }
    return '';
  }
}
