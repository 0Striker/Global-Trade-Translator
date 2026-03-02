import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ai_translate.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Safely add new columns by checking their existence mapping instead of relying purely on version limits.
    // This prevents migration crashes if the database was recreated during development with a mismatched version.
    var tableInfo = await db.rawQuery('PRAGMA table_info(messages)');
    var columns = tableInfo.map((info) => info['name'] as String).toList();
    
    if (!columns.contains('tip')) {
      await db.execute('ALTER TABLE messages ADD COLUMN tip TEXT;');
    }
    if (!columns.contains('direction')) {
      await db.execute('ALTER TABLE messages ADD COLUMN direction TEXT;');
    }

    // Version 4 table migrations for conversations
    var convTableInfo = await db.rawQuery('PRAGMA table_info(conversations)');
    var convColumns = convTableInfo.map((info) => info['name'] as String).toList();
    
    if (!convColumns.contains('sourceLanguage')) {
      await db.execute('ALTER TABLE conversations ADD COLUMN sourceLanguage TEXT;');
    }
    if (!convColumns.contains('targetLanguage')) {
      await db.execute('ALTER TABLE conversations ADD COLUMN targetLanguage TEXT;');
    }
    if (!convColumns.contains('sector')) {
      await db.execute('ALTER TABLE conversations ADD COLUMN sector TEXT;');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const integerType = 'INTEGER NOT NULL';
    const textType = 'TEXT NOT NULL';
    const intPrimaryKey = 'INTEGER PRIMARY KEY AUTOINCREMENT';

    await db.execute('''
CREATE TABLE conversations (
  id $idType,
  createdAt $integerType,
  sourceLanguage TEXT,
  targetLanguage TEXT,
  sector TEXT
)
''');

    await db.execute('''
CREATE TABLE messages (
  id $intPrimaryKey,
  conversation_id $textType,
  role $textType,
  content $textType,
  tip TEXT,
  direction TEXT,
  created_at $integerType
)
''');
  }

  Future<void> insertConversation(Conversation conversation) async {
    final db = await instance.database;
    await db.insert(
      'conversations',
      conversation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Conversation>> getConversations() async {
    final db = await instance.database;
    final result = await db.query(
      'conversations',
      orderBy: 'createdAt DESC',
    );
    return result.map((json) => Conversation.fromMap(json)).toList();
  }
  
  Future<void> deleteConversation(String id) async {
      final db = await instance.database;
      await db.delete('conversations', where: 'id = ?', whereArgs: [id]);
      await db.delete('messages', where: 'conversation_id = ?', whereArgs: [id]);
  }

  Future<void> insertMessage(Message message) async {
    final db = await instance.database;
    await db.insert('messages', message.toMap());
  }

  Future<List<Message>> getMessages(String conversationId) async {
    final db = await instance.database;
    final result = await db.query(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'created_at ASC',
    );
    return result.map((json) => Message.fromMap(json)).toList();
  }
}
