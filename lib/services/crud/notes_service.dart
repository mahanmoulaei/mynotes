import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart' show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;

const createUserTable = '''
CREATE TABLE IF NOT EXISTS $userTable (
    `id` INTEGER NOT NULL,
    `email` TEXT NOT NULL UNIQUE,
    PRIMARY KEY(`id` AUTOINCREMENT)
);''';
const createNoteTable = '''
CREATE TABLE IF NOT EXISTS $noteTable (
    `id` INTEGER NOT NULL,
    `user_id` INTEGER NOT NULL,
    `text` TEXT,
    `is_synced_with_cloud` INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY(`user_id`) REFERENCES `user`(`id`),
    PRIMARY KEY(`id` AUTOINCREMENT)
);''';

const dbName = "notes.db";
const noteTable = "note";
const userTable = "user";
const idColumn = "id";
const emailColumn = "email";
const userIdColumn = "user_id";
const textColumn = "text";
const isSyncedWithCloudColumn = "is_synced_with_cloud";

class DatabaseAlreadyOpenException implements Exception {}

class UnableToGetDocumentsDirectory implements Exception {}

class DatabaseIsNotOpen implements Exception {}

class CouldNotDeleteUser implements Exception {}

class UserAlreadyExists implements Exception {}

class CouldNotFindUser implements Exception {}

class CouldNotDeleteNote implements Exception {}

class CouldNotFindNote implements Exception {}

class CouldNotUpdateNote implements Exception {}

class NotesService {
  Database? _db;

  Database _getDatabaseOrThrow() {
    final db = _db;

    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUserTable);
      await db.execute(createNoteTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }

  Future<void> close() async {
    final db = _db;

    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();

      _db = null;
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    email = email.toLowerCase();

    final results = await db.query(userTable, where: "email = ?", whereArgs: [email]);

    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final userId = await db.insert(userTable, {emailColumn: email.toLowerCase()});

    return DatabaseUser(id: userId, email: email);
  }

  Future<bool> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();

    final deletedCount = await db.delete(userTable, where: "email = ?", whereArgs: [email]);

    if (deletedCount < 1) {
      throw CouldNotDeleteUser();
    }

    return true;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    email = email.toLowerCase();

    final results = await db.query(userTable, limit: 1, where: "email = ?", whereArgs: [email]);

    if (results.isEmpty) {
      throw CouldNotFindUser();
    }

    return DatabaseUser.fromRow(results.first);
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);

    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    const text = "";

    final noteId = await db.insert(noteTable, {userIdColumn: owner.id, textColumn: text, isSyncedWithCloudColumn: 1});

    return DatabaseNote(id: noteId, userId: owner.id, text: text, isSyncedWithCloud: true);
  }

  Future<bool> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(noteTable, where: "id = ?", whereArgs: [id]);

    if (deletedCount < 1) {
      throw CouldNotDeleteNote();
    }

    return true;
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    return await db.delete(noteTable);
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();

    final results = await db.query(noteTable, limit: 1, where: "id = ?", whereArgs: [id]);

    if (results.isEmpty) {
      throw CouldNotFindNote();
    }

    return DatabaseNote.fromRow(results.first);
  }

  Future<Iterable<DatabaseNote>> getAllNotes({required int id}) async {
    final db = _getDatabaseOrThrow();

    final results = await db.query(noteTable);

    return results.map((noteRow) {
      return DatabaseNote.fromRow(noteRow);
    });
  }

  Future<DatabaseNote> updateNote({required int id, required String text}) async {
    final db = _getDatabaseOrThrow();

    await getNote(id: id);

    final updatesCount = await db.update(noteTable, {textColumn: text, isSyncedWithCloudColumn: 0});

    if (updatesCount < 1) {
      throw CouldNotUpdateNote();
    }

    return await getNote(id: id);
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() {
    return "Person, ID = $id, Email = $email";
  }

  @override
  bool operator ==(covariant DatabaseUser other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  const DatabaseNote({required this.id, required this.userId, required this.text, required this.isSyncedWithCloud});

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud = (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() {
    return "Note, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud";
  }

  @override
  bool operator ==(covariant DatabaseNote other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
