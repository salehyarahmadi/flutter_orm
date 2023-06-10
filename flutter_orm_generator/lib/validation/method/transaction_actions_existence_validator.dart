import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_orm/annotations/dao_annotations.dart';
import 'package:flutter_orm_generator/extensions/extensions.dart';
import 'package:flutter_orm_generator/validation/validator.dart';

class TransactionActionsExistenceValidator
    extends ElementValidator<MethodElement> {
  final ClassElement daoClass;
  String? message;

  TransactionActionsExistenceValidator(this.daoClass, {this.message});

  @override
  check(MethodElement element) {
    List<String> sequentialActions = element
            .getListFieldFromAnnotation(
                Transactional, Transactional.fields.sequentialActions)
            ?.map((e) => e.toStringValue() ?? '')
            .toList() ??
        [];
    for (var action in sequentialActions) {
      if (!daoClass.methods.map((e) => e.name).toList().contains(action)) {
        throw Exception('${element.name}: method with name $action must be '
            'declared in ${daoClass.name}');
      }
    }
    checkNext(element);
  }
}
