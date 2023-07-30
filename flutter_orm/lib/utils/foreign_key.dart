import 'package:flutter_orm/annotations/entity_annotations.dart';
import 'package:flutter_orm/enums/foreign_key_action.dart';

/// For define foreign key in entities, you have to use this class.
/// Foreign keys allows you to specify constraints across entities
/// such that SQLite will ensure that the relationship is valid
/// when you modify the database.
/// A foreign key constraint can be deferred until the transaction is complete.
/// This is useful if you are doing bulk inserts into the database
/// in a single transaction. By default, foreign key constraints
/// are immediate but you can change this value by setting [deferred] to true.
class ForeignKey {
  /// The parent Entity to reference. It must be a class
  /// annotated with [Entity] and referenced in the same database.
  final Object entity;

  /// The list of column names in the parent Entity.
  /// Number of columns must match the number of columns
  /// specified in [childColumns].
  final List<String> parentColumns;

  /// The list of column names in the current Entity.
  /// Number of columns must match the number of columns
  /// specified in [parentColumns].
  final List<String> childColumns;

  /// Action to take when the parent Entity is deleted from the database.
  /// Default value of [onDelete] is [ForeignKeyAction.NO_ACTION]
  final ForeignKeyAction onDelete;

  /// Action to take when the parent Entity is updated in the database.
  /// Default value of [onUpdate] is [ForeignKeyAction.NO_ACTION]
  final ForeignKeyAction onUpdate;

  /// A foreign key constraint can be deferred until the transaction is
  /// complete. This is useful if you are doing bulk inserts into the database
  /// in a single transaction. By default, foreign key constraints are
  /// immediate but you can change it by setting this field to true.
  final bool deferred;

  const ForeignKey({
    required this.entity,
    required this.parentColumns,
    required this.childColumns,
    this.onDelete = ForeignKeyAction.NO_ACTION,
    this.onUpdate = ForeignKeyAction.NO_ACTION,
    this.deferred = false,
  });
}
