import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm/extensions/extensions.dart';

class DefaultOnCreateCodeGeneratorAdapter extends CodeGeneratorAdapter {
  @override
  String generate(Element? element) {
    ClassElement dbClass = element as ClassElement;
    if (dbClass.hasOnCreateInterface() && !dbClass.hasOnCreateMethod()) {
      return """
@override
Future<void> onCreate(Database? db, int version) async {
}      
      """;
    }
    return '';
  }
}
