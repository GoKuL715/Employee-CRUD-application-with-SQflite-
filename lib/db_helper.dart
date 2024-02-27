import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""
    CREATE TABLE employee (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      employeeId INTEGER,
      employeeName TEXT,
      gender TEXT,
      dateOfJoining TEXT,
      createAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    """);
  }
static Future<sql.Database> db() async {
  return sql.openDatabase(
    "database_name.db",
    version: 1,
    onCreate: (sql.Database database, int version) async {
      await createTables(database);
    },
    onOpen: (db) async {
      // Ensure the table is created when the database is opened
      if (await db.rawQuery("SELECT * FROM sqlite_master WHERE type='table' AND name='employee'").then((value) => value.isEmpty)) {
        await createTables(db);
      }
    },
  );
}


  // Create a new employee
  static Future<int> createEmployee(int employeeId, String employeeName, String gender, String dateOfJoining) async {
    final db = await SQLHelper.db();

    final employee = {
      'employeeId': employeeId,
      'employeeName': employeeName,
      'gender': gender,
      'dateOfJoining': dateOfJoining,
    };
    final id = await db.insert('employee', employee,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  // Read all employees
  static Future<List<Map<String, dynamic>>> getAllEmployees() async {
    final db = await SQLHelper.db();
    return db.query('employee', orderBy: 'id');
  }

  // Read a single employee by id
  static Future<List<Map<String, dynamic>>> getSingleEmployee(int id) async {
    final db = await SQLHelper.db();
    return db.query('employee', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Update an employee by id
  static Future<int> updateEmployee(int id, int employeeId, String employeeName, String gender, String dateOfJoining) async {
    final db = await SQLHelper.db();
    final employee = {
      'employeeId': employeeId,
      'employeeName': employeeName,
      'gender': gender,
      'dateOfJoining': dateOfJoining,
      'createAt': DateTime.now().toString()
    };
    final result = await db.update('employee', employee, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete an employee by id
  static Future<bool> deleteEmployee(int id) async {
  try {
    final db = await SQLHelper.db();
    int rowsAffected = await db.delete('employee', where: "id = ?", whereArgs: [id]);
    return rowsAffected > 0; // Returns true if any rows were deleted
  } catch (e) {
    print("Error deleting employee: $e");
    return false; // Returns false if an error occurred
  }
}

}
