import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm/extensions/extensions.dart';

class DefaultOnUpgradeCodeGeneratorAdapter extends CodeGeneratorAdapter {
  @override
  String generate(Element? element) {
    ClassElement dbClass = element as ClassElement;
    if (dbClass.hasOnUpgradeInterface() && !dbClass.hasOnUpgradeMethod()) {
      return """
@override
Future<void> onUpgrade(Database? db, int oldVersion, int newVersion) async {
}      
      """;
    }
    return '';
  }
}
