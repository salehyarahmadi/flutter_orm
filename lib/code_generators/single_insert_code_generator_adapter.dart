import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm/extensions/extensions.dart';
import 'package:flutter_orm/validation/method/is_all_parameters_positional_validator.dart';
import 'package:flutter_orm/validation/method/is_future_method_validator.dart';
import 'package:flutter_orm/validation/method/method_parameter_validator.dart';
import 'package:flutter_orm/validation/method/method_parameters_count_validator.dart';
import 'package:flutter_orm/validation/method/method_return_type_validator.dart';


class SingleInsertCodeGeneratorAdapter extends CodeGeneratorAdapter {
  final ClassElement dbClass;

  SingleInsertCodeGeneratorAdapter(this.dbClass);

  @override
  String generate(Element? element) {
    MethodElement singleInsertMethod = element as MethodElement;
    _validation(singleInsertMethod);

    Element? entity = singleInsertMethod.parameters.first.type.element;
    String parameterName = singleInsertMethod.parameters.first.name;
    ClassElement parameterEntityClass = entity as ClassElement;

    return """
@override
${singleInsertMethod.declarationWithTransactionParameter()} async {
  var executor = txn ?? db;
  ${singleInsertMethod.hasReturnType() ? 'return ' : ''}await executor?.insert(
  ${parameterEntityClass.name.helperClassName()}.tableName, 
  ${parameterEntityClass.name.helperClassName()}.toJson($parameterName),
  ${singleInsertMethod.getConflictAlgorithm()}
  );
}
""";
  }

  _validation(MethodElement singleInsertMethod) {
    IsFutureMethodValidator()
        .then(MethodParametersCountValidator(1))
        .then(IsAllParametersPositionalValidator())
        .then(MethodReturnTypeValidator(
          (type) => type.isFutureNullableInt() || type.isFutureVoid(),
          '${singleInsertMethod.name}: '
          'single insert method\'s return type is either int? or void',
        ))
        .then(MethodParameterValidator(
            0,
            (type) => type.isNotNullable(),
            '${singleInsertMethod.name}: '
            'single insert method\'s parameter cannot be nullable'))
        .then(MethodParameterValidator(
            0,
            (type) => type.isEntity(dbClass),
            '${singleInsertMethod.name}: '
            'single insert method\'s parameter must be Entity'))
        .check(singleInsertMethod);
  }
}
