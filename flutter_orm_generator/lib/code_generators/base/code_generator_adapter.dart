import 'package:analyzer/dart/element/element.dart';

/// Base class for classes that want to generating code or query.
/// [Element] itself is base class for
/// [ClassElement], [MethodElement], [ParameterElement] and etc.
/// Usually, in these classes, the first thing is casting the [element] to
/// the proper element like [ClassElement] to fetch required properties
/// from the [element] and then do some validation to make sure that everything
/// is Ok and finally generate codes or queries based on fetched properties.
abstract class CodeGeneratorAdapter {
  String generate(Element? element);
}

class CodeGeneratorBuilder {
  final CodeGeneratorAdapter adapter;

  Element? _element;

  CodeGeneratorBuilder(this.adapter);

  CodeGeneratorBuilder element(Element? element) {
    _element = element;
    return this;
  }

  String generate() => adapter.generate(_element);
}
