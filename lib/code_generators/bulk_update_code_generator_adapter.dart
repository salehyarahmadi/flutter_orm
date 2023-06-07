import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm/extensions/extensions.dart';
import 'package:flutter_orm/validation/method/is_all_parameters_positional_validator.dart';
import 'package:flutter_orm/validation/method/is_future_method_validator.dart';
import 'package:flutter_orm/validation/method/method_parameter_validator.dart';
import 'package:flutter_orm/validation/method/method_parameters_count_validator.dart';
import 'package:flutter_orm/validation/method/method_return_type_validator.dart';

class BulkUpdateCodeGeneratorAdapter extends CodeGeneratorAdapter {
  final ClassElement dbClass;

  BulkUpdateCodeGeneratorAdapter(this.dbClass);

  @override
  String generate(Element? element) {
    MethodElement bulkUpdateMethod = element as MethodElement;
    _validation(bulkUpdateMethod);

    String parameterName = bulkUpdateMethod.parameters.first.name;
    String parameterTypeName =
        bulkUpdateMethod.parameters.first.type.toString();
    String entityName = parameterTypeName.substring(
      parameterTypeName.indexOf('List<') + 5,
      parameterTypeName.indexOf('>'),
    );

    FieldElement pkField = dbClass.getPrimaryKeyWithEntityName(entityName);

    return """
@override
${bulkUpdateMethod.declarationWithTransactionParameter()} async {
  var executor = txn ?? db;
  if(executor != null) {
    var batch = executor.batch();
    for(var e in $parameterName) {
      executor.update(
        ${entityName.helperClassName()}.tableName, 
        ${entityName.helperClassName()}.toJson(e),
        where: '${pkField.getColumnName()} = ?',
        whereArgs: [e.${pkField.name}],
        ${bulkUpdateMethod.getConflictAlgorithm()}
      );
    }
    await batch.commit();
  }
}
""";
  }

  _validation(MethodElement bulkUpdateMethod) {
    IsFutureMethodValidator()
        .then(MethodParametersCountValidator(1))
        .then(IsAllParametersPositionalValidator())
        .then(MethodReturnTypeValidator(
          (type) => type.isFutureVoid(),
          '${bulkUpdateMethod.name}: '
          'bulk update method\'s return type must be void',
        ))
        .then(MethodParameterValidator(
            0,
            (type) => type.isNotNullable(),
            '${bulkUpdateMethod.name}: '
            'bulk update method\'s parameter cannot be nullable'))
        .then(MethodParameterValidator(
            0,
            (type) => type.isListOfEntity(dbClass),
            '${bulkUpdateMethod.name}: '
            'bulk update method\'s parameter must be List of Entity'))
        .check(bulkUpdateMethod);
  }
}
