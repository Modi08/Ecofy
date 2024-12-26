import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class User {
  final String id;
  final String email;
  final String pwd;
  final String username;
  final String connectionId;
  final String bio;
  final int followers;
  final int following;
  final List<String> uploadedPhotos;
  final String profilePic;

  User({
    required this.id,
    required this.email,
    required this.pwd,
    required this.username,
    required this.connectionId,
    required this.bio,
    required this.followers,
    required this.following,
    required this.uploadedPhotos,
    required this.profilePic
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      "pwd": pwd,
      'username': username,
      "connectionId": connectionId,
      "bio": bio,
      "followers": followers,
      "following": following,
      "uploadedPhotos": uploadedPhotos,
      "profilePic": profilePic
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map["id"],
      email: map["email"],
      pwd: map["pwd"],
      username: map["username"],
      connectionId: map["connectionId"],
      bio: map["bio"],
      followers: map["followers"],
      following: map["following"],
      uploadedPhotos: map["uploadedPhotos"],
      profilePic: map["profilePic"]
    );
  }
}

class DatabaseService {
  static const databaseName = "users.db";
  static const databaseVersion = 1;
  static const tableName = "users";

  static const columnUserId = "userId";
  static const columnEmail = "email";
  static const columnPwd = "pwd";
  static const columnUsername = "username";
  static const columnBio = "bio";
  static const columnConnectionId = "connectionId";
  static const columnFollowers = "followers";
  static const columnFollowing = "following";
  static const columnUploadedPhotos = "uploadedPhotos";
  static const columnProfilePic = "profilePic";

  // Singleton pattern to ensure only one instance of the database
  static final DatabaseService instance = DatabaseService._constructor();

  DatabaseService._constructor();
  static late Database databaseInstance;

  Future<Database> get database async {
    databaseInstance = await initDatabase();
    return databaseInstance;
  }

  Future<Database> initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, databaseName);
    databaseFactory.deleteDatabase(path);  //Need to be uncommented if scheme is changes

    return await openDatabase(path,
        version: databaseVersion, onCreate: (db, version) async {
          await db.execute('''
          CREATE TABLE $tableName (
            $columnUserId TEXT PRIMARY KEY,
            $columnEmail TEXT,
            $columnPwd TEXT,
            $columnUsername TEXT,
            $columnBio TEXT,
            $columnFollowing INTEGER,
            $columnFollowers INTEGER,
            $columnUploadedPhotos TEXT,
            $columnConnectionId TEXT,
            $columnProfilePic TEXT
          )
          ''');
        });
  }

  // Insert a row in the database
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(tableName, row);
  }

  // Get a single row by ID
  Future<Map<String, dynamic>?> queryById(String id) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(tableName,
        where: '$columnUserId = ?', whereArgs: [id]);
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  // Get all rows from the database
  Future<List<Map<String, dynamic>>> queryAll() async {
    Database db = await database;
    return await db.query(tableName);
  }

  // Update a row in the database
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await database;
    String id = row[columnUserId];
    return await db.update(tableName, row,
        where: '$columnUserId = ?', whereArgs: [id]);
  }

  // Delete a row from the database
  Future<int> delete(int id) async {
    Database db = await database;
    return await db.delete(tableName,
        where: '$columnUserId = ?', whereArgs: [id]);
  }

  Future<int> replace(Map<String, dynamic> row) async {
    return await queryById(row[columnUserId]).then((itemFound) async {
      if (itemFound == null) {
        return await insert(row);
      } else {
        return await update(row);
      }
    });
  }
}