/// Actions to take when the parent Entity is deleted/updated
/// from/in the database.
enum ForeignKeyAction {
  /// When a parent key is modified or deleted from the database,
  /// no special action is taken. This means that SQLite will not make
  /// any effort to fix the constraint failure, instead, reject the change.
  NO_ACTION,

  /// The [RESTRICT] action means that the application is prohibited from
  /// deleting (for [onDelete]) or modifying (for [onUpdate]) a parent key when
  /// there exists one or more child keys mapped to it. The difference between
  /// the effect of a [RESTRICT] action and normal foreign key constraint
  /// enforcement is that the [RESTRICT] action processing happens as soon as
  /// the field is updated - not at the end of the current statement as it
  /// would with an immediate constraint, or at the end of the current
  /// transaction as it would with a deferred constraint.
  /// Even if the foreign key constraint it is attached to is deferred,
  /// configuring a [RESTRICT] action causes SQLite to return an error
  /// immediately if a parent key with dependent child keys is
  /// deleted or modified.
  RESTRICT,

  /// If the configured action is [SET_NULL], then when a parent key is
  /// deleted (for [onDelete]) or modified (for [onUpdate]),
  /// the child key columns of all rows in the child table that mapped to
  /// the parent key are set to contain [NULL] values.
  SET_NULL,

  /// The [SET_DEFAULT] actions are similar to [SET_NULL],
  /// except that each of the child key columns is set to contain the
  /// columns default value instead of NULL
  SET_DEFAULT,

  /// A [CASCADE] action propagates the delete or update operation on
  /// the parent key to each dependent child key. For [onDelete] action,
  /// this means that each row in the child entity that was associated
  /// with the deleted parent row is also deleted. For an onUpdate action,
  /// it means that the values stored in each dependent child key are
  /// modified to match the new parent key values.
  CASCADE,
}

extension ForeignKeyActionExtension on ForeignKeyAction {
  String query() {
    if (this == ForeignKeyAction.NO_ACTION) return 'NO ACTION';
    if (this == ForeignKeyAction.RESTRICT) return 'RESTRICT';
    if (this == ForeignKeyAction.SET_NULL) return 'SET NULL';
    if (this == ForeignKeyAction.SET_DEFAULT) return 'SET DEFAULT';
    if (this == ForeignKeyAction.CASCADE) return 'CASCADE';
    return 'NO ACTION';
  }
}

ForeignKeyAction foreignKeyActionFromInt(int? index) {
  if (index == 0) return ForeignKeyAction.NO_ACTION;
  if (index == 1) return ForeignKeyAction.RESTRICT;
  if (index == 2) return ForeignKeyAction.SET_NULL;
  if (index == 3) return ForeignKeyAction.SET_DEFAULT;
  if (index == 4) return ForeignKeyAction.CASCADE;

  return ForeignKeyAction.NO_ACTION;
}
