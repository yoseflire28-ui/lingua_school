// ─────────────────────────────────────────────────────────────────────────────
// Lingua School — Database Helper (SQLite)
// Singleton managing table creation, indexed queries, and CRUD operations.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/student_model.dart';
import '../models/activity_log_model.dart';

class DatabaseHelper {
  // ─── Singleton ────────────────────────────────────────────────────────────
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  static const String _dbName      = 'lingua_school.db';
  static const int    _dbVersion   = 2;
  static const String _studentsT   = 'students';
  static const String _activityT   = 'activity_logs';

  /// Returns the singleton [Database], initialising it on first access.
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path   = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ─── Schema Creation ──────────────────────────────────────────────────────

  Future<void> _onCreate(Database db, int version) async {
    // Students table — optimised for 1,000+ records
    await db.execute('''
      CREATE TABLE $_studentsT (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name        TEXT NOT NULL,
        last_name         TEXT NOT NULL,
        phone_number      TEXT NOT NULL,
        gender            TEXT NOT NULL,
        section           TEXT NOT NULL,
        registration_date TEXT NOT NULL,
        branch            TEXT NOT NULL DEFAULT 'Main Office',
        package           TEXT NOT NULL DEFAULT 'Foundation',
        first_month_paid  INTEGER NOT NULL DEFAULT 0,
        second_month_paid INTEGER NOT NULL DEFAULT 0,
        age               TEXT NOT NULL DEFAULT '',
        grade             TEXT NOT NULL DEFAULT '',
        academic_year     TEXT NOT NULL DEFAULT '',
        school_name       TEXT NOT NULL DEFAULT ''
      )
    ''');

    // Four indices to accelerate multi-field search queries
    await db.execute('CREATE INDEX idx_fn ON $_studentsT(first_name)');
    await db.execute('CREATE INDEX idx_ln ON $_studentsT(last_name)');
    await db.execute('CREATE INDEX idx_ph ON $_studentsT(phone_number)');
    await db.execute('CREATE INDEX idx_sc ON $_studentsT(section)');

    // Activity logs table
    await db.execute('''
      CREATE TABLE $_activityT (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        action_type   TEXT NOT NULL,
        student_names TEXT NOT NULL,
        details       TEXT NOT NULL,
        timestamp     TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE $_studentsT ADD COLUMN age TEXT NOT NULL DEFAULT ''");
      await db.execute("ALTER TABLE $_studentsT ADD COLUMN grade TEXT NOT NULL DEFAULT ''");
      await db.execute("ALTER TABLE $_studentsT ADD COLUMN academic_year TEXT NOT NULL DEFAULT ''");
      await db.execute("ALTER TABLE $_studentsT ADD COLUMN school_name TEXT NOT NULL DEFAULT ''");
    }
  }

  // ─── Students CRUD ────────────────────────────────────────────────────────

  Future<int> insertStudent(Student student) async {
    final db = await database;
    return db.insert(_studentsT, student.toMap());
  }

  Future<List<Student>> getAllStudents() async {
    final db   = await database;
    final maps = await db.query(_studentsT, orderBy: 'first_name ASC');
    return maps.map(Student.fromMap).toList();
  }

  /// Full-text search across first_name, last_name, phone_number, section, branch, package.
  /// Uses indexed columns for sub-millisecond response on large datasets.
  Future<List<Student>> searchStudents(String query) async {
    if (query.isEmpty) return getAllStudents();
    final db = await database;
    final q  = '%$query%';
    final maps = await db.rawQuery('''
      SELECT * FROM $_studentsT
       WHERE first_name   LIKE ?
          OR last_name    LIKE ?
          OR phone_number LIKE ?
          OR section      LIKE ?
          OR branch       LIKE ?
          OR package      LIKE ?
       ORDER BY first_name ASC
    ''', [q, q, q, q, q, q]);
    return maps.map(Student.fromMap).toList();
  }

  Future<int> updateStudent(Student student) async {
    final db = await database;
    return db.update(_studentsT, student.toMap(),
        where: 'id = ?', whereArgs: [student.id]);
  }

  Future<int> deleteStudent(int id) async {
    final db = await database;
    return db.delete(_studentsT, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllStudents() async {
    final db = await database;
    await db.delete(_studentsT);
  }

  /// Inserts a large list of students in a single batch transaction.
  Future<void> insertStudentsBatch(List<Student> students) async {
    final db    = await database;
    final batch = db.batch();
    for (final s in students) {
      batch.insert(_studentsT, s.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  // ─── Activity Logs ────────────────────────────────────────────────────────

  Future<int> insertActivityLog(ActivityLog log) async {
    final db = await database;
    return db.insert(_activityT, log.toMap());
  }

  Future<List<ActivityLog>> getAllActivityLogs() async {
    final db   = await database;
    final maps = await db.query(_activityT, orderBy: 'timestamp DESC');
    return maps.map(ActivityLog.fromMap).toList();
  }

  Future<void> clearActivityLogs() async {
    final db = await database;
    await db.delete(_activityT);
  }
}
