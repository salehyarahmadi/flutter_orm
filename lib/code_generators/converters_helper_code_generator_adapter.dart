import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm/extensions/extensions.dart';
import 'package:flutter_orm/utils/constants.dart';

class ConvertersHelperCodeGeneratorAdapter extends CodeGeneratorAdapter {
  @override
  String generate(Element? element) {
    ClassElement dbClass = element as ClassElement;
    List<String> convertersMethod =
        dbClass.getUserDefinedConvertersHelperMethods();
    String convertersMethodString = convertersMethod.join('\n');

    return """
class $convertersHelperClassName {
  
  $convertersMethodString
}
""";
  }
}
