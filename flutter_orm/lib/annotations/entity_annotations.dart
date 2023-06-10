import 'package:flutter_orm/utils/index.dart';

/// Annotation for create table in database.
/// You can set [tableName] and [indices] for this table, in this annotation.
/// If you don't set [tableName], the class name will be set as the default name.
/// You have to set primary key for table using [PrimaryKey] annotation.
/// The entity must have exactly one primary key and only integer primary key
/// can be auto increment.
/// All properties of the class that this annotation applied on, map to
/// a column in the table unless properties that [Ignore] annotation
/// are applied on. Default column name is property name. If you want to
/// change it use [Column] annotation and set [name] property.
/// ```dart
/// @Entity(tableName: 'notes', indices: [
///   Index(columns: ['text'], unique: true)
/// ])
/// class Note {
///   @PrimaryKey(autoGenerate: true)
///   final int? id;
///
///   final String text;
///   final bool isEdited;
///   final DateTime createDate;
///   final DateTime? updateDate;
///
///   @Column(name: 'lat')
///   final double? latitude;
///
///   @Column(name: 'lng')
///   final double? longitude;
///
///   @Ignore()
///   final String? ignoreTest;
///
///   Note({
///     this.id,
///     required this.text,
///     required this.isEdited,
///     required this.createDate,
///     this.updateDate,
///     this.latitude,
///     this.longitude,
///     this.ignoreTest,
///   });
/// }
/// ```
class Entity {
  static _EntityFields fields = const _EntityFields();
  final String? tableName;
  final List<Index>? indices;

  const Entity({this.tableName, this.indices});
}

class _EntityFields {
  const _EntityFields();

  String get tableName => 'tableName';

  String get indices => 'indices';
}

class PrimaryKey {
  static _PrimaryKeyFields fields = const _PrimaryKeyFields();
  final String? name;
  final bool autoGenerate;

  const PrimaryKey({
    this.name,
    this.autoGenerate = false,
  });
}

class _PrimaryKeyFields {
  const _PrimaryKeyFields();

  String get name => 'name';

  String get autoGenerate => 'autoGenerate';
}

class Column {
  static _ColumnFields fields = const _ColumnFields();
  final String name;

  const Column({required this.name});
}

class _ColumnFields {
  const _ColumnFields();

  String get name => 'name';
}

class Ignore {
  const Ignore();
}
