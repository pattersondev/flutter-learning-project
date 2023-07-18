import "package:sqflite/sqflite.dart";
import "package:path_provider/path_provider.dart";
import "package:path/path.dart" show join;

class DatabaseAlreadyOpenException implements Exception {}

class UnableToGetDocumentsDirectory implements Exception {}

class DatabaseIsNotOpen implements Exception {}

class CouldNotDeleteUser implements Exception {}

class UserAlreadyExists implements Exception {}

class UserNotFound implements Exception {}

class NoteNotFound implements Exception {}

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
    if (_db != null) throw DatabaseAlreadyOpenException();
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      // create user table
      await db.execute(createUserTable);

      // create note table
      db.execute(createNoteTable);
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

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(userTable,
        where: '$emailColumn = ?', whereArgs: [email.toLowerCase()]);
    if (deletedCount < 1) {
      throw CouldNotDeleteUser();
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable,
        where: '$emailColumn = ?', whereArgs: [email.toLowerCase()]);
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }
    final id = await db.insert(userTable, {emailColumn: email.toLowerCase()});
    return DatabaseUser(id: id, email: email);
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable,
        where: '$emailColumn = ?', whereArgs: [email.toLowerCase()]);

    if (results.isEmpty) {
      throw UserNotFound();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();

    final user = getUser(email: owner.email);
    if (user != owner) {
      throw UserNotFound();
    }

    const text = '';
    final noteId = await db.insert(noteTable,
        {text: text, userIdColumn: owner.id, isSyncedWithCloudColumn: 1});

    final note = DatabaseNote(
        id: noteId, userId: owner.id, isSyncedWithCloud: true, body: text);
    return note;
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();

    final deletedCount =
        await db.delete(userTable, where: '$id = ?', whereArgs: [id]);
    if (deletedCount < 1) {
      throw CouldNotDeleteUser();
    }
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    return await db.delete(noteTable);
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();

    final notes =
        await db.query(noteTable, limit: 1, where: 'id = ?', whereArgs: [id]);

    if (notes.isEmpty) {
      throw NoteNotFound();
    } else {
      return DatabaseNote.fromRow(notes.first);
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);

    return notes.map((n) => DatabaseNote.fromRow(n));
  }

  Future<DatabaseNote> updateNote(
      {required DatabaseNote note, required String text}) async {
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);
    final updateCount = await db
        .update(noteTable, {bodyColumn: text, isSyncedWithCloudColumn: 0});
    if (updateCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      return await getNote(id: note.id);
    }
  }
}

class DatabaseUser {
  final int id;
  final String email;

  DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() {
    return 'Person, ID = $id, email = $email';
  }

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final bool isSyncedWithCloud;
  final String body;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.isSyncedWithCloud,
    required this.body,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        body = map[bodyColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() {
    return 'Note, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud, body = $body';
  }

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const bodyColumn = 'body';
const createUserTable = ''' 
  CREATE TABLE IF NOT EXISTS $userTable (
  $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
  $emailColumn TEXT NOT NULL UNIQUE
  )
''';
const createNoteTable = '''
  CREATE TABLE IF NOT EXISTS $noteTable (
  $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
  $userIdColumn INTEGER NOT NULL,
  $isSyncedWithCloudColumn INTEGER NOT NULL,
  $bodyColumn TEXT NOT NULL,
  FOREIGN KEY ($userIdColumn) REFERENCES $userTable ($idColumn)
  )
''';
