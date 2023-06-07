import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm/extensions/extensions.dart';
import 'package:flutter_orm/validation/method/is_all_parameters_positional_validator.dart';
import 'package:flutter_orm/validation/method/is_future_method_validator.dart';
import 'package:flutter_orm/validation/method/method_parameter_validator.dart';
import 'package:flutter_orm/validation/method/method_parameters_count_validator.dart';
import 'package:flutter_orm/validation/method/method_return_type_validator.dart';

class BulkInsertCodeGeneratorAdapter extends CodeGeneratorAdapter {
  final ClassElement dbClass;

  BulkInsertCodeGeneratorAdapter(this.dbClass);

  @override
  String generate(Element? element) {
    MethodElement bulkInsertMethod = element as MethodElement;
    _validation(bulkInsertMethod);
    String parameterName = bulkInsertMethod.parameters.first.name;
    String parameterTypeName =
        bulkInsertMethod.parameters.first.type.toString();
    String entityName = parameterTypeName.substring(
      parameterTypeName.indexOf('List<') + 5,
      parameterTypeName.indexOf('>'),
    );
    return """
@override
${bulkInsertMethod.declarationWithTransactionParameter()} async {
  var executor = txn ?? db;
  if(executor != null) {
    var batch = executor.batch();
    for(var e in $parameterName) {
      batch.insert(
        ${entityName.helperClassName()}.tableName, 
        ${entityName.helperClassName()}.toJson(e),
        ${bulkInsertMethod.getConflictAlgorithm()}
      );
    }
    await batch.commit();
  }
}
""";
  }

  _validation(MethodElement bulkInsertMethod) {
    IsFutureMethodValidator()
        .then(MethodParametersCountValidator(1))
        .then(IsAllParametersPositionalValidator())
        .then(MethodReturnTypeValidator(
          (type) => type.isFutureVoid(),
          '${bulkInsertMethod.name}: '
          'bulk insert method\'s return type must be void',
        ))
        .then(MethodParameterValidator(
            0,
            (type) => type.isNotNullable(),
            '${bulkInsertMethod.name}: '
            'bulk insert method\'s parameter cannot be nullable'))
        .then(MethodParameterValidator(
            0,
            (type) => type.isListOfEntity(dbClass),
            '${bulkInsertMethod.name}: '
            'bulk insert method\'s parameter must be List of Entity'))
        .check(bulkInsertMethod);
  }
}
