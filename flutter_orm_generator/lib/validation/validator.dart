import 'package:analyzer/dart/element/element.dart';

/// Base class for define a validation.
/// If you want to validate an [Element] or its child types like:
/// [MethodElement] and [ClassElement], you have to create
/// a class that extends this abstract class.
/// Example:
/// ```dart
/// class IsFutureMethodValidator extends ElementValidator<MethodElement> {
///   String? message;
///
///   IsFutureMethodValidator({this.message});
///
///   @override
///   check(MethodElement element) {
///     if (!element.returnType.isDartAsyncFuture) {
///       throw Exception(message ?? '${element.name} return type must be future');
///     }
///     checkNext(element);
///   }
/// }
/// ```
///
/// If you want to chain some validator, you can do like this:
/// ```dart
///       NullCheckValidator()
///         .then(IsClassValidator())
///         .then(IsAbstractClassValidator())
///         .then(IsDaoValidator())
///         .check(element);
/// ```
abstract class ElementValidator<T extends Element?> {
  ElementValidator? _next;

  ElementValidator then(ElementValidator next) {
    if (_next == null) {
      _next = next;
    } else {
      _next!.then(next);
    }
    return this;
  }

  void check(T element);

  checkNext(T element) {
    return _next?.check(element);
  }
}
