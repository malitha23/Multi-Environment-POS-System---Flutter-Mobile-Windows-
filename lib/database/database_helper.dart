import 'dart:convert';
import 'dart:io'; // For platform detection
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // For desktop
import 'package:sqflite/sqflite.dart'; // For Android/iOS
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  // Initialize FFI for desktop platforms
  static void _initializeFFI() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  // Get or initialize the database
  static Future<Database> getDatabase() async {
    if (_database != null) {
      return _database!;
    }

    _initializeFFI();

    _database = await openDatabase(
      join(await getDatabasesPath(), 'shop_database.db'),
      version: 3, // Increment version if the schema changes
      onCreate: (db, version) async {
        // Create tables here
        await db.execute(
          '''CREATE TABLE shop(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          shopname TEXT,
          shopcategory TEXT,
          email TEXT UNIQUE,
          password TEXT)''',
        );

        await db.execute(
          '''CREATE TABLE posItems(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          category TEXT,
          subCategory TEXT,
          price TEXT,
          quantity INTEGER,
          unit TEXT,
          image TEXT,
          barcode TEXT,
          itemCode TEXT,
          discount INTEGER,
          priceFormat TEXT)''',
        );

        await db.execute(
          '''CREATE TABLE subcategory(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          shop_id INTEGER,
          subcategory_name TEXT,
          FOREIGN KEY (shop_id) REFERENCES shop(id))''',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Handle schema upgrades when the database version is changed
        if (oldVersion < 2) {
          // Add the 'createdate' column if it doesn't exist
        }
      },
    );

    return _database!;
  }

  static Future<bool> insertPosItems(
      List<Map<String, dynamic>> posItems) async {
    final db = await getDatabase();
    try {
      for (var item in posItems) {
        String priceJson = jsonEncode(item['price']);
        int id = await db.insert(
          'posItems',
          {
            'name': item['name'],
            'category': item['category'],
            'subCategory': item['subCategory'],
            'price': priceJson,
            'quantity': item['quantity'],
            'unit': item['unit'],
            'image': item['image'],
            'barcode': item['barcode'],
            'itemCode': item['itemCode'],
            'discount': item['discount'],
            'priceFormat': item['priceFormat'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        if (id < 0) {
          // Return false if any insertion fails
          print("Failed to insert posItem: $item");
          return false;
        }
        print("Inserted posItem with ID: $id");
      }
      return true; // All insertions succeeded
    } catch (e) {
      print("Error inserting posItems: $e");
      return false; // Indicate failure on error
    }
  }

  static Future<List<Map<String, dynamic>>> getPosItems({
    required String searchtext, // Search text filter
    required int page, // Page number
    required int pageSize, // Number of items per page
  }) async {
    final db = await getDatabase();
    // await _addCreatedateColumnIfNeeded(db);

    try {
      String whereClause = '';
      final List<String> whereArgs = [];
      // await db.rawDelete('DELETE FROM posItems');
      // Check if searchtext is not empty, otherwise fetch all items without filter
      if (searchtext.isNotEmpty) {
        print(searchtext);
        whereClause =
            'WHERE name LIKE ? OR category LIKE ? OR subCategory LIKE ? OR barcode LIKE ? OR itemCode LIKE ?';
        whereArgs.addAll([
          '%$searchtext%',
          '%$searchtext%',
          '%$searchtext%',
          '%$searchtext%',
          '%$searchtext%',
        ]);
      }

      // Query the database with the constructed WHERE clause and parameters, along with LIMIT and OFFSET for pagination
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT * FROM posItems $whereClause LIMIT ? OFFSET ?',
        [...whereArgs, pageSize, (page - 1) * pageSize],
      );

      // Decode the price field and return the modified maps
      return maps.map((item) {
        final newItem = Map<String, dynamic>.from(item);
        if (newItem['price'] != null) {
          newItem['price'] = jsonDecode(newItem['price']); // Decode price JSON
        }
        return newItem;
      }).toList();
    } catch (e) {
      print("Error fetching posItems: $e");
      return [];
    }
  }

  // Insert a new shop into the 'shop' table
  static Future<void> insertShop(Map<String, dynamic> shop) async {
    final db = await getDatabase();
    try {
      await db.insert(
        'shop',
        shop,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("Error inserting shop: $e");
    }
  }

  // Insert subcategories into the 'subcategory' table
  static Future<void> insertSubcategories(
      int shopId, List<String> subcategories) async {
    final db = await getDatabase();
    try {
      for (var subcategory in subcategories) {
        await db.insert(
          'subcategory',
          {'shop_id': shopId, 'subcategory_name': subcategory},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      print("Error inserting subcategories: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> getShopsWithSubcategories() async {
    final db = await getDatabase();
    try {
      final shops = await db.query('shop');
      List<Map<String, dynamic>> shopsWithSubcategories = [];

      for (var shop in shops) {
        // Create a mutable copy of the shop map
        final mutableShop = Map<String, dynamic>.from(shop);

        // Fetch subcategories for the current shop
        final subcategories = await db.query(
          'subcategory',
          where: 'shop_id = ?',
          whereArgs: [mutableShop['id']],
        );

        // Add subcategories to the mutable shop map
        mutableShop['subcategories'] = subcategories
            .map((subcategory) => subcategory['subcategory_name'])
            .toList();

        // Add the modified shop map to the result list
        shopsWithSubcategories.add(mutableShop);
      }

      return shopsWithSubcategories;
    } catch (e) {
      print("Error fetching shops with subcategories: $e");
      return [];
    }
  }

  // Show all tables in the database
  static Future<void> showAllTables() async {
    final db = await DatabaseHelper.getDatabase();
    try {
      // Fetch all table names
      final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name");

      // Loop through each table and print its columns
      for (var table in tables) {
        final tableName = table['name'];
        print("Table: $tableName");

        // Fetch column details for each table
        final columns = await db.rawQuery("PRAGMA table_info($tableName)");
        for (var column in columns) {
          print("  Column: ${column['name']}, Type: ${column['type']}");
        }
        print(""); // Add a line break between tables
      }
    } catch (e) {
      print("Error fetching tables: $e");
    }
  }

  // Delete the database
  static Future<void> deleteDatabase() async {
    final dbPath = join(await getDatabasesPath(), 'shop_database.db');
    await databaseFactory.deleteDatabase(dbPath);
    print("Database deleted.");
  }

// Truncate all tables in the database
  static Future<void> truncateAllTables() async {
    final db = await getDatabase();
    try {
      // Fetch all table names except SQLite's internal tables
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      );

      for (var table in tables) {
        final tableName = table['name'];
        print("Truncating table: $tableName");

        // Use DELETE to clear table contents
        await db.delete(tableName.toString());
      }

      print("All tables truncated successfully.");
    } catch (e) {
      print("Error truncating tables: $e");
    }
  }

  // Close the database connection
  static Future<void> close() async {
    final db = await getDatabase();
    await db.close();
  }
}
