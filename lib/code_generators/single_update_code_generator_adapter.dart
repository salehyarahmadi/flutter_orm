import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm/extensions/extensions.dart';
import 'package:flutter_orm/validation/method/is_all_parameters_positional_validator.dart';
import 'package:flutter_orm/validation/method/is_future_method_validator.dart';
import 'package:flutter_orm/validation/method/method_parameter_validator.dart';
import 'package:flutter_orm/validation/method/method_parameters_count_validator.dart';
import 'package:flutter_orm/validation/method/method_return_type_validator.dart';

class SingleUpdateCodeGeneratorAdapter extends CodeGeneratorAdapter {
  final ClassElement dbClass;

  SingleUpdateCodeGeneratorAdapter(this.dbClass);

  @override
  String generate(Element? element) {
    MethodElement singleUpdateMethod = element as MethodElement;
    _validation(singleUpdateMethod);

    Element? entity = singleUpdateMethod.parameters.first.type.element;
    String parameterName = singleUpdateMethod.parameters.first.name;
    ClassElement parameterEntityClass = entity as ClassElement;
    String parameterEntityName = parameterEntityClass.name;

    FieldElement pkField =
        dbClass.getPrimaryKeyWithEntityName(parameterEntityName);

    return """
@override
${singleUpdateMethod.declarationWithTransactionParameter()} async {
  if($parameterName.${pkField.name} != null) {
    var executor = txn ?? db;
    ${singleUpdateMethod.hasReturnType() ? 'return ' : ''}await executor?.update(
      ${parameterEntityClass.name.helperClassName()}.tableName, 
      ${parameterEntityClass.name.helperClassName()}.toJson($parameterName),
      where: '${pkField.getColumnName()} = ?',
      whereArgs: [$parameterName.${pkField.name}],
      ${singleUpdateMethod.getConflictAlgorithm()}
    );
  }
}
""";
  }

  _validation(MethodElement singleUpdateMethod) {
    IsFutureMethodValidator()
        .then(MethodParametersCountValidator(1))
        .then(IsAllParametersPositionalValidator())
        .then(MethodReturnTypeValidator(
          (type) => type.isFutureNullableInt() || type.isFutureVoid(),
          '${singleUpdateMethod.name}: '
          'single update method\'s return type is either int? or void',
        ))
        .then(MethodParameterValidator(
            0,
            (type) => type.isNotNullable(),
            '${singleUpdateMethod.name}: '
            'single update method\'s parameter cannot be nullable'))
        .then(MethodParameterValidator(
            0,
            (type) => type.isEntity(dbClass),
            '${singleUpdateMethod.name}: '
            'single update method\'s parameter must be Entity'))
        .check(singleUpdateMethod);
  }
}
