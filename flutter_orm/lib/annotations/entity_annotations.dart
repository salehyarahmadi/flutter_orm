import 'package:flutter_orm/utils/foreign_key.dart';
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
/// Also you can set default value for columns using [defaultValue] property
/// of [Column] annotation.
/// You can define foreign keys using [foreignKeys] property of this annotation.
/// Each item of [foreignKeys] property is a [ForeignKey] instance.
/// ```dart
/// @Entity(
///   tableName: 'notes',
///   indices: [
///     Index(columns: ['text'], unique: true)
///   ],
///   foreignKeys: [
///     ForeignKey(
///       entity: User,
///       parentColumns: ['id'],
///       childColumns: ['userId'],
///       onDelete: ForeignKeyAction.CASCADE,
///       onUpdate: ForeignKeyAction.CASCADE,
///       deferred: false,
///     )
///   ],
/// )
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
///   @Column(name: 'defaultValueTest1', defaultValue: 'test')
///   final String? defaultValueTest1;
///
///   @Column(name: 'defaultValueTest2', defaultValue: '0')
///   final int? defaultValueTest2;
///
///   final int userId;
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
///     this.defaultValueTest1,
///     this.defaultValueTest2,
///     required this.userId,
///   });
/// }
/// ```
class Entity {
  static _EntityFields fields = const _EntityFields();
  final String? tableName;
  final List<Index>? indices;
  final List<ForeignKey>? foreignKeys;

  const Entity({this.tableName, this.indices, this.foreignKeys});
}

class _EntityFields {
  const _EntityFields();

  String get tableName => 'tableName';

  String get indices => 'indices';

  String get foreignKeys => 'foreignKeys';
}

/// Annotation for define primary key for your entity(table).
/// Defining a field with this annotation is necessary.
/// Also an entity must have exactly one primary key. In other words,
/// your entity must have exactly one field with this annotation.
/// If your primary key variable type be [int], you can set [autoGenerate]
/// property to true. If [autoGenerate] property is set to true, the field type
/// must be nullable and don't pass this field in object creation.
/// ```dart
/// @Entity()
/// class Note {
///   @PrimaryKey(autoGenerate: true)
///   final int? id;
///
///   final String text;
///   final bool isEdited;
///
///   Note({
///     this.id,
///     required this.text,
///     required this.isEdited,
///   });
/// }
/// ```
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

/// This annotation is used for when you want to change default name of
/// column name of a field in table or when you want to set default value
/// for column.
/// You have to know that the default column name is property name.
/// ```dart
/// @Entity()
/// class Note {
///   @PrimaryKey(autoGenerate: true)
///   final int? id;
///
///   final String text;
///
///   @Column(name: 'edited')
///   final bool isEdited;
///
///   @Column(name: 'test', defaultValue: '1')
///   final int? test;
///
///   Note({
///     this.id,
///     required this.text,
///     required this.isEdited,
///     this.test,
///   });
/// }
/// ```
class Column {
  static _ColumnFields fields = const _ColumnFields();
  final String name;
  final String? defaultValue;

  const Column({
    required this.name,
    this.defaultValue,
  });
}

class _ColumnFields {
  const _ColumnFields();

  String get name => 'name';

  String get defaultValue => 'defaultValue';
}

/// If you want a field doesn't map to a column in table, you can use
/// this annotation.
/// ```dart
/// @Entity()
/// class Note {
///   @PrimaryKey(autoGenerate: true)
///   final int? id;
///
///   final String text;
///
///   @Ignore()
///   final bool isEdited;
///
///   Note({
///     this.id,
///     required this.text,
///     required this.isEdited,
///   });
/// }
/// ```
class Ignore {
  const Ignore();
}

/// If you want to use an object that you have defined yourself, in your entity,
/// you can use this annotation. Suppose that the `Note` entity has an
/// `address` property that is an object itself. In this situation, you can
/// use this annotation on that field. Embedded objects also can have embedded
/// fields. Embedded object fields, can have [Column] and [Ignore] annotation,
/// but they can't have [PrimaryKey].
/// You should note that the fields of embedded object, merge with
/// entity fields in table. For example, for the below entity, created table
/// has these columns: `id`, `text`, `address_lat` and `address_lng`.
/// If you have noticed, embedded object fields has a prefix in its column
/// name that is field name by default.
/// You can change this prefix by change [prefix] property of [Embedded]
/// annotation.
///
/// ```dart
/// @Entity()
/// class Note {
///   @PrimaryKey(autoGenerate: true)
///   final int? id;
///
///   final String text;
///
///   @Embedded()
///   final Address? address;
///
///   Note({
///     this.id,
///     required this.text,
///     required this.isEdited,
///     this.address,
///   });
/// }
///
/// class Address {
///   @Column(name: 'lat')
///   final double latitude;
///
///   @Column(name: 'lng')
///   final double latitude;
///
///   Address({
///     required this.latitude,
///     required this.latitude,
///   });
/// }
/// ```
class Embedded {
  static _EmbeddedFields fields = const _EmbeddedFields();
  final String? prefix;

  const Embedded({this.prefix});
}

class _EmbeddedFields {
  const _EmbeddedFields();

  String get prefix => 'prefix';
}
