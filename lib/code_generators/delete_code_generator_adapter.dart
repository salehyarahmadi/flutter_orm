import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm/extensions/extensions.dart';
import 'package:flutter_orm/validation/class/is_entity_validator.dart';
import 'package:flutter_orm/validation/element/is_class_validator.dart';
import 'package:flutter_orm/validation/element/null_check_validator.dart';
import 'package:flutter_orm/validation/method/is_all_parameters_positional_validator.dart';
import 'package:flutter_orm/validation/method/is_future_method_validator.dart';
import 'package:flutter_orm/validation/method/method_parameter_validator.dart';
import 'package:flutter_orm/validation/method/method_parameters_count_validator.dart';
import 'package:flutter_orm/validation/method/method_return_type_validator.dart';
import 'package:flutter_orm/validation/validator.dart';


class DeleteCodeGeneratorAdapter extends CodeGeneratorAdapter {
  final ClassElement dbClass;

  DeleteCodeGeneratorAdapter(this.dbClass);

  @override
  String generate(Element? element) {
    ClassElement daoClass = element as ClassElement;

    List<MethodElement> deleteMethods =
        daoClass.getMethodsWithDeleteAnnotation();
    _validation(dbClass, deleteMethods);

    String result = '';
    for (var method in deleteMethods) {
      String methodImpl = _generateMethodImpl(method);
      result += methodImpl + '\n';
    }

    return result;
  }

  _validation(
    ClassElement dbClass,
    List<MethodElement> deleteMethods,
  ) {
    ElementValidator methodValidator = IsFutureMethodValidator()
        .then(IsAllParametersPositionalValidator())
        .then(MethodReturnTypeValidator(
          (type) => type.isFutureNullableInt() || type.isFutureVoid(),
          'delete method\'s return type is either int? or void',
        ))
        .then(MethodParametersCountValidator(1))
        .then(MethodParameterValidator(0, (type) => type.isNotNullable(),
            'delete method\'s parameter cannot be nullable'));

    ElementValidator parameterValidator = NullCheckValidator()
        .then(IsClassValidator())
        .then(IsEntityValidator(dbClass));

    for (var method in deleteMethods) {
      methodValidator.check(method);
      parameterValidator.check(method.parameters.first.type.element);
    }
  }

  String _generateMethodImpl(MethodElement method) {
    Element? entity = method.parameters.first.type.element;
    String parameterName = method.parameters.first.name;
    ClassElement parameterEntityClass = entity as ClassElement;
    String parameterEntityName = parameterEntityClass.name;

    FieldElement pkField =
        dbClass.getPrimaryKeyWithEntityName(parameterEntityName);
    String tableName = entity.getEntityTableName();

    return """
@override
${method.declarationWithTransactionParameter()} async {
  if($parameterName.${pkField.name} != null) {
    var executor = txn ?? db;
    ${method.hasReturnType() ? 'return ' : ''}await executor?.delete(
      '$tableName',
      where: '${pkField.getColumnName()} = ?',
      whereArgs: [$parameterName.${pkField.name}],
    );
  }
}
""";
  }
}
