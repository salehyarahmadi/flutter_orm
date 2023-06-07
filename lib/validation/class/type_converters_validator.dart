import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/annotations/db_annotations.dart';
import 'package:flutter_orm/extensions/extensions.dart';
import 'package:flutter_orm/validation/element/is_class_validator.dart';
import 'package:flutter_orm/validation/element/null_check_validator.dart';
import 'package:flutter_orm/validation/method/is_not_future_method_validator.dart';
import 'package:flutter_orm/validation/method/is_static_method_validator.dart';
import 'package:flutter_orm/validation/method/method_parameters_count_validator.dart';
import 'package:flutter_orm/validation/validator.dart';
import 'package:source_gen/source_gen.dart';

const _typeConverterChecker = TypeChecker.fromRuntime(TypeConverter);

class TypeConvertersValidator extends ElementValidator<ClassElement> {
  String? message;

  TypeConvertersValidator({this.message});

  @override
  check(ClassElement element) {
    Element? typeConvertersClass = element
        .getDartTypeFieldFromAnnotation(
            TypeConverters, TypeConverters.fields.converters)
        ?.element;
    if (typeConvertersClass != null) {
      NullCheckValidator().then(IsClassValidator()).check(typeConvertersClass);
      Map<String, String> methodsInfo = {};
      for (var method in (typeConvertersClass as ClassElement).methods) {
        if (_typeConverterChecker.hasAnnotationOfExact(method)) {
          IsNotFutureMethodValidator()
              .then(MethodParametersCountValidator(1))
              .then(IsStaticMethodValidator())
              .check(method);
          String returnType = method.returnType.toString();
          String parameterType = method.parameters.first.type.toString();
          if ((returnType.isBuiltIn() || returnType.isBuiltInSupport()) &&
              (parameterType.isBuiltIn() || parameterType.isBuiltInSupport())) {
            throw Exception('built-in types cannot convert to each other: '
                'from $parameterType to $returnType');
          }
          if ((returnType.isNullable() && parameterType.isNotNullable()) ||
              (returnType.isNotNullable() && parameterType.isNullable())) {
            throw Exception('return type and parameter type of type '
                'converter method must be both nullable or both not nullable');
          }
          if (methodsInfo.containsKey(parameterType)) {
            throw Exception('you have already defined a type converter method '
                'with parameter type: $parameterType');
          }
          methodsInfo.putIfAbsent(parameterType, () => returnType);
        }
      }

      methodsInfo.forEach((key, value) {
        bool found = false;
        methodsInfo.forEach((innerKey, innerValue) {
          if (innerKey == value && innerValue == key) {
            found = true;
          }
        });
        if (!found) {
          throw Exception('method with return type $key and '
              'parameter type $value must be declare');
        }
      });
    }
    checkNext(element);
  }
}
