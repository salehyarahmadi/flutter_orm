import 'package:flutter_orm/db_config/db_config.dart';


/// Annotation for initialize databases and generate methods for
/// access to databases.
/// It must be applied on an abstract class.
/// You don't need to do anything extra.
/// ```dart
/// @DBBuilder(databases: [NoteDB])
/// abstract class DatabaseBuilder {}
/// ```
/// After define this class, you can create and access to database like this:
/// ```dart
/// NoteDB db = await DBContext.getNoteDB();
/// ```
class DBBuilder {
  static _DBBuilderFields fields = const _DBBuilderFields();
  final List<Object> databases;

  const DBBuilder({this.databases = const []});
}

class _DBBuilderFields {
  const _DBBuilderFields();

  String get databases => 'databases';
}

/// Annotation for create database.
/// It must be applied on an abstract class.
/// Database entities(tables) must be defined in this annotation.
/// Configuration methods like [OnConfigure], [OnCreate], [OnOpen], [OnUpgrade]
/// and [OnDowngrade] for actions like Migration can implement in the class
/// that this annotation applied on.
/// Also, Dao classes must be defined in the class that this annotation
/// applied on as an abstract method.
/// [TypeConverters] annotation also apply on the class
/// that this annotation applied on.
/// ```dart
/// @DB(
///   name: 'note_db',
///   version: 1,
///   entities: [Note],
/// )
/// @TypeConverters(Converters)
/// abstract class NoteDB implements OnUpgrade {
///   NoteDao noteDao();
///
///   @override
///   Future<void> onUpgrade(Database? db, int oldVersion, int newVersion) async {
///     print('Migration');
///   }
/// }
/// ```
class DB {
  static _DBFields fields = const _DBFields();
  final String name;
  final List<Object> entities;
  final int version;
  final bool readOnly;
  final bool singleInstance;

  const DB({
    required this.name,
    required this.version,
    this.entities = const [],
    this.readOnly = false,
    this.singleInstance = true,
  });
}

class _DBFields {
  const _DBFields();

  String get name => 'name';

  String get entities => 'entities';

  String get version => 'version';

  String get readOnly => 'readOnly';

  String get singleInstance => 'singleInstance';
}

/// Annotation for define type converters for database.
/// You have to apply this annotation on class that [DB] annotation applied on.
/// You have to pass a class to this annotation that whose methods implement
/// conversion rules.
class TypeConverters {
  static _TypeConvertersFields fields = const _TypeConvertersFields();
  final Object converters;

  const TypeConverters(this.converters);
}

class _TypeConvertersFields {
  const _TypeConvertersFields();

  String get converters => 'converters';
}

/// Annotation for methods that implement conversion tools.
/// These methods must be defined in the class that passed to [TypeConverters]
/// annotation as an abstract method.
/// ```dart
/// class Converters {
///   @TypeConverter()
///   static DateTime to(String value) {
///     return DateTime.parse(value);
///   }
///
///   @TypeConverter()
///   static String from(DateTime dateTime) {
///     return dateTime.toIso8601String();
///   }
/// }
/// ```
class TypeConverter {
  const TypeConverter();
}
