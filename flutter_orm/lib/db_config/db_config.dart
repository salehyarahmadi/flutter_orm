import 'package:sqflite/sqflite.dart';

/// This is a configuration method for database.
/// Your DB class can implement this abstract class and override [onConfigure].
/// Prototype of the function called before calling [onCreate]/[onUpdate]/[onOpen]
/// when the database is open.
/// Post initialization should happen here.
abstract class OnConfigure {
  Future<void> onConfigure(Database? db);
}

/// This is a configuration method for database.
/// Your DB class can implement this abstract class and override [onOpen].
/// Prototype of the function called when the database is open.
/// Post initialization should happen here.
abstract class OnOpen {
  Future<void> onOpen(Database? db);
}

/// This is a configuration method for database.
/// Your DB class can implement this abstract class and override [onUpgrade].
/// Prototype of the function called when the version has increased.
/// Schema migration (adding column, adding table, adding trigger...)
/// should happen here.
abstract class OnUpgrade {
  Future<void> onUpgrade(Database? db, int oldVersion, int newVersion);
}

/// This is a configuration method for database.
/// Your DB class can implement this abstract class and override [onDowngrade].
/// Prototype of the function called when the version has decreased.
/// Schema migration (adding column, adding table, adding trigger...)
/// should happen here.
abstract class OnDowngrade {
  Future<void> onDowngrade(Database? db, int oldVersion, int newVersion);
}

/// This is a configuration method for database.
/// Your DB class can implement this abstract class and override [onCreate].
/// Prototype of the function called when the database is created.
/// Database initialization (creating tables, views, triggers...)
/// should happen here.
abstract class OnCreate {
  Future<void> onCreate(Database? db, int version);
}
