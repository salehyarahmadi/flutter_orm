import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:flutter_orm/annotations/dao_annotations.dart';
import 'package:flutter_orm/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm/code_generators/query_result_converter_code_generator_adapter.dart';
import 'package:flutter_orm/extensions/extensions.dart';
import 'package:flutter_orm/utils/constants.dart';
import 'package:flutter_orm/validation/method/is_all_parameters_positional_validator.dart';
import 'package:flutter_orm/validation/method/is_future_method_validator.dart';
import 'package:flutter_orm/validation/method/method_return_type_validator.dart';
import 'package:flutter_orm/validation/method/raw_query_format_validator.dart';
import 'package:flutter_orm/validation/method/raw_query_method_parameters_validator.dart';

class RawQueryCodeGeneratorAdapter extends CodeGeneratorAdapter {
  final ClassElement dbClass;

  RawQueryCodeGeneratorAdapter(this.dbClass);

  @override
  String generate(Element? element) {
    ClassElement daoClass = element as ClassElement;
    return _generateRawQueryMethodsImplementation(daoClass);
  }

  String _generateRawQueryMethodsImplementation(ClassElement daoClass) {
    List<MethodElement> rawQueryMethods =
        daoClass.getMethodsWithQueryAnnotation();
    _validateRawQueryMethods(rawQueryMethods);
    String result = '';
    for (var method in rawQueryMethods) {
      String query =
          method.getStringFieldFromAnnotation(Query, Query.fields.query) ?? '';
      String formattedQuery = _convertQueryVariablesFormat(query, method);

      String queryResultConverter = CodeGeneratorBuilder(
              QueryResultConverterCodeGeneratorAdapter(dbClass))
          .element(method)
          .generate();

      String methodImpl = """              
@override
${method.declarationWithTransactionParameter()} async {
  var executor = txn ?? db;
  List<Map<String, Object?>>? records = await executor?.rawQuery('''
$formattedQuery
''');
  
  $queryResultConverter
}
""";
      result += methodImpl + '\n';
    }

    return result;
  }

  _validateRawQueryMethods(List<MethodElement> methods) {
    for (var method in methods) {
      IsFutureMethodValidator()
          .then(IsAllParametersPositionalValidator())
          .then(RawQueryMethodParametersValidator(dbClass))
          .then(MethodReturnTypeValidator(
              (type) => // Todo: check this conditions
                  (!type.containMap()) &&
                  (type.isFutureVoid() ||
                      type.isFutureRawData() ||
                      (!type.containList() && type.isNullable()) ||
                      // (type.containList() && type.isNotNullable()) ||
                      (type.containList() && !type.containVoid())),
              'return type of method ${method.name} is wrong'))
          .then(RawQueryFormatValidator())
          .check(method);
    }
  }

  String _convertQueryVariablesFormat(String query, MethodElement method) {
    String _e = 'e';
    for (var match in query.getAllVariablesTemplate()) {
      String variableTemplate = query.substring(match.start, match.end);
      String variableName = query.substring(match.start + 1, match.end);

      bool isInsideQuotation = _isInsideQuotation(variableTemplate, query);

      DartType parameterType =
          method.parameters.firstWhere((e) => e.name == variableName).type;
      bool isParameterTypeList = parameterType.isDartCoreList;
      String parameterTypeName = isParameterTypeList
          ? parameterType
              .toString()
              .substring(5, parameterType.toString().lastIndexOf('>'))
          : parameterType.toString();

      String singleVarName = isParameterTypeList ? _e : variableName;
      String replacement = parameterTypeName.isBuiltIn()
          ? '\$$singleVarName'
          : (parameterTypeName.isBuiltInSupport()
              ? '\${BuiltInSupportConvertersHelper.from("$parameterTypeName", $singleVarName)}'
              : '\${$convertersHelperClassName.from$parameterTypeName($singleVarName)}');

      if (!isInsideQuotation) {
        replacement = '"$replacement"';
      }

      if (isParameterTypeList) {
        replacement =
            '\${$variableName.map(($_e) => $replacement).toList().join(",")}';
      }

      query = query.replaceFirst(variableTemplate, replacement);
    }
    return query;
  }

  bool _isInsideQuotation(String variableTemplate, String query) {
    var variablePattern = RegExp(r"'.*'");
    for (var match in variablePattern.allMatches(query)) {
      String temp = query.substring(match.start, match.end);
      if (temp.contains(variableTemplate)) return true;
    }
    variablePattern = RegExp(r'".*"');
    for (var match in variablePattern.allMatches(query)) {
      String temp = query.substring(match.start, match.end);
      if (temp.contains(variableTemplate)) return true;
    }
    return false;
  }
}
