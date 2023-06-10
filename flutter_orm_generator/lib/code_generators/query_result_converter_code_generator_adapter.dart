import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:flutter_orm/annotations/dao_annotations.dart';
import 'package:flutter_orm_generator/code_generators/base/code_generator_adapter.dart';
import 'package:flutter_orm_generator/code_generators/custom_object_from_json_code_generator_adapter.dart';
import 'package:flutter_orm_generator/extensions/extensions.dart';
import 'package:flutter_orm_generator/utils/constants.dart';

class QueryResultConverterCodeGeneratorAdapter extends CodeGeneratorAdapter {
  final ClassElement dbClass;

  QueryResultConverterCodeGeneratorAdapter(this.dbClass);

  @override
  String generate(Element? element) {
    MethodElement rawQueryMethod = element as MethodElement;

    String returnType = rawQueryMethod.getReturnTypeOfFutureMethod();

    if (_isRawDataReturnType(returnType)) {
      return 'return RawData(records);';
    }

    bool isList = rawQueryMethod.returnType.containList();
    String singularType = isList
        ? returnType.substring(5, returnType.lastIndexOf('>'))
        : returnType;

    if (singularType == 'void') {
      return '';
    }

    if (singularType.isBuiltIn() && isList) {
      return '''
            List<$singularType> list = [];
            for(var record in records ?? []) {
              list.add(record[record.keys.first] as $singularType);
            }
            return list;
            ''';
    }

    if (singularType.isBuiltIn() && !isList) {
      return '''
            return (records?[0][records[0].keys.first]) as $singularType;
            ''';
    }

    if (singularType.isBuiltInSupport() && isList) {
      return '''
            List<$singularType> list = [];
            for(var record in records ?? []) {
              list.add(BuiltInSupportConvertersHelper.to(
                "$singularType", 
                record[record.keys.first],
              ));
            }
            return list;
            ''';
    }

    if (singularType.isBuiltInSupport() && !isList) {
      return '''
        return BuiltInSupportConvertersHelper.to(
          "$singularType", 
          records?[0][records[0].keys.first],
        );
      ''';
    }

    bool isNullable = singularType.endsWith('?');
    String typeWithoutNullable = isNullable
        ? singularType.substring(0, singularType.length - 1)
        : singularType;

    if (typeWithoutNullable.isEntity(dbClass) && isList) {
      return '''
            List<$singularType> list = [];
            for (var record in records ?? []) {
              list.add(${typeWithoutNullable.helperClassName()}.fromJson(record));
            }
            return list;
            ''';
    }

    if (typeWithoutNullable.isEntity(dbClass) && !isList) {
      return '''
            if(records?.isNotEmpty ?? false) {
              return ${typeWithoutNullable.helperClassName()}.fromJson(records![0]);
            }
            ''';
    }

    DartType? singularReturnType =
        rawQueryMethod.getDartTypeFieldFromAnnotation(
            SingularReturnType, SingularReturnType.fields.type);
    if (singularReturnType != null) {
      String customObjectInstantiateGenerator;
      if (isList) {
        customObjectInstantiateGenerator = CodeGeneratorBuilder(
                CustomObjectFromJsonCodeGeneratorAdapter('record'))
            .element(singularReturnType.element)
            .generate();
        return '''
            List<$typeWithoutNullable> list = [];
            for (var record in records ?? []) {
              list.add($customObjectInstantiateGenerator);
            }
            return list;
            ''';
      }
      customObjectInstantiateGenerator = CodeGeneratorBuilder(
              CustomObjectFromJsonCodeGeneratorAdapter('records?[0]'))
          .element(singularReturnType.element)
          .generate();
      return '''
            if(records?.isNotEmpty ?? false) {
              return $customObjectInstantiateGenerator;
            }
            ''';
    }

    if (isList) {
      return '''
            List<$singularType> list = [];
            for (var record in records ?? []) {
              list.add($convertersHelperClassName.to${isNullable ? 'Nullable' : ''}$typeWithoutNullable(record[record.keys.first]));
            }
            return list;
            ''';
    }

    if (!isList) {
      return '''
            if(records?.isNotEmpty ?? false) {
              return $convertersHelperClassName.to${isNullable ? 'Nullable' : ''}$typeWithoutNullable(records?[0][records[0].keys.first]);
            }
            ''';
    }

    return '';
  }

  bool _isRawDataReturnType(String returnType) {
    return returnType == 'RawData' || returnType == 'RawData?';
  }
}
