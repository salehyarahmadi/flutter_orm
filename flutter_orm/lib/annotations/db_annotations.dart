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
/// abstract class NoteDB {
///   NoteDao noteDao();
///
///   @OnUpgrade()
///   Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
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
  final List<Object> migrations;

  const DB({
    required this.name,
    required this.version,
    this.entities = const [],
    this.readOnly = false,
    this.singleInstance = true,
    this.migrations = const [],
  });
}

class _DBFields {
  const _DBFields();

  String get name => 'name';

  String get entities => 'entities';

  String get version => 'version';

  String get readOnly => 'readOnly';

  String get singleInstance => 'singleInstance';

  String get migrations => 'migrations';
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

/// Annotation for define OnConfigure method for database.
/// Prototype of the function called before calling [onCreate]/[onUpdate]/[onOpen]
/// when the database is open.
/// Post initialization should happen here.
/// This annotation must be applied on a method in the database class.
/// Method syntax is also important.
/// Example:
/// ```dart
/// @DB(
///   name: 'note_db',
///   version: 1,
///   entities: [Note],
/// )
/// abstract class NoteDB {
///   @OnConfigure()
///   Future<void> onConfigure(Database db) async {
///     print('onConfigure');
///   }
/// }
/// ```
class OnConfigure {
  const OnConfigure();
}

/// Annotation for define OnOpen method for database.
/// Prototype of the function called when the database is open.
/// Post initialization should happen here.
/// This annotation must be applied on a method in the database class.
/// Method syntax is also important.
/// Example:
/// ```dart
/// @DB(
///   name: 'note_db',
///   version: 1,
///   entities: [Note],
/// )
/// abstract class NoteDB {
///   @OnOpen()
///   Future<void> onOpen(Database db) async {
///     print('onOpen');
///   }
/// }
/// ```
class OnOpen {
  const OnOpen();
}

/// Annotation for define Migration(OnUpgrade) method for database.
/// Prototype of the function called when the version has increased.
/// Schema migration (adding column, adding table, adding trigger...)
/// should happen here.
/// This annotation must be applied on a method in the database class.
/// Method syntax is also important.
/// Example:
/// ```dart
/// @DB(
///   name: 'note_db',
///   version: 1,
///   entities: [Note],
/// )
/// abstract class NoteDB {
///   @OnUpgrade()
///   Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
///     print('onUpgrade');
///   }
/// }
/// ```
class OnUpgrade {
  const OnUpgrade();
}

/// Annotation for define Migration(OnDowngrade) method for database.
/// Prototype of the function called when the version has decreased.
/// Schema migration (adding column, adding table, adding trigger...)
/// should happen here.
/// This annotation must be applied on a method in the database class.
/// Method syntax is also important.
/// Example:
/// ```dart
/// @DB(
///   name: 'note_db',
///   version: 1,
///   entities: [Note],
/// )
/// abstract class NoteDB {
///   @OnDowngrade()
///   Future<void> onDowngrade(Database db, int oldVersion, int newVersion) async {
///     print('onDowngrade');
///   }
/// }
/// ```
class OnDowngrade {
  const OnDowngrade();
}
