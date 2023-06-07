import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm/extensions/extensions.dart';

class DefaultOnConfigureCodeGeneratorAdapter extends CodeGeneratorAdapter {
  @override
  String generate(Element? element) {
    ClassElement dbClass = element as ClassElement;
    if (dbClass.hasOnConfigureInterface() && !dbClass.hasOnConfigureMethod()) {
      return """
@override
Future<void> onConfigure(Database? db) async {
}      
      """;
    }
    return '';
  }
}
