import 'dart:io'; // For platform detection
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // For desktop
import 'package:sqflite/sqflite.dart'; // For Android/iOS
import 'package:path/path.dart';
import 'package:path/path.dart' as p;

class DatabaseHelper {
  static Database? _database;

  // Get or initialize the database
  static Future<Database> getDatabase() async {
    if (_database != null) {
      return _database!;
    }

    _initializeFFI();

    String dbPath;
    final projectName = 'shop_pos_system_app';

    if (Platform.isWindows) {
      // Path to AppData\Local
      final appDataPath = p.join(
        Platform.environment['LOCALAPPDATA']!,
        projectName,
      );

      // Ensure the directory exists
      Directory(appDataPath).createSync(recursive: true);

      // Database file path
      dbPath = p.join(appDataPath, 'shop_database.db');
    } else {
      // For other platforms, use the default database path
      dbPath = p.join(await getDatabasesPath(), 'shop_database.db');
    }

    _database = await openDatabase(
      dbPath,
      version: 10,
      onCreate: (db, version) async {
        // Create tables
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
          image TEXT)''',
        );

        await db.execute(
          '''CREATE TABLE stock(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          stockId TEXT,
          item_id INTEGER,
          unit TEXT,
          priceFormat TEXT,
          price TEXT,
          size TEXT,
          quantity INTEGER,
          additional TEXT,
          barcode TEXT,
          itemCode TEXT,
          discountPercentage REAL,
          FOREIGN KEY (item_id) REFERENCES posItems(id))''',
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
        if (oldVersion < newVersion) {
          // Handle schema upgrades here
        }
      },
    );

    return _database!;
  }

  static void _initializeFFI() {
    // Initialize the SQLite FFI for Windows, Linux, and macOS
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

// Function to drop all tables
  static Future<void> _dropTables(Database db) async {
    try {
      // Fetch all table names
      final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'");

      for (var table in tables) {
        final tableName = table['name'];
        print("Dropping table: $tableName");

        // Drop the table
        await db.execute('DROP TABLE IF EXISTS $tableName');
      }
      print("All tables dropped successfully.");
    } catch (e) {
      print("Error dropping tables: $e");
    }
  }

// Function to recreate the tables
  static Future<void> _createTables(Database db) async {
    try {
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
        image TEXT)''',
      );

      await db.execute(
        '''CREATE TABLE stock(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stockId TEXT,
        item_id INTEGER,
        unit TEXT,
        priceFormat TEXT,
        price TEXT,
        size TEXT,
        quantity INTEGER,
        additional TEXT,
        barcode TEXT,
        itemCode TEXT,
        discountPercentage REAL,
        FOREIGN KEY (item_id) REFERENCES posItems(id))''',
      );

      await db.execute(
        '''CREATE TABLE subcategory(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shop_id INTEGER,
        subcategory_name TEXT,
        FOREIGN KEY (shop_id) REFERENCES shop(id))''',
      );

      print("All tables recreated successfully.");
    } catch (e) {
      print("Error creating tables: $e");
    }
  }

  static Future<bool> insertPosItems(
      List<Map<String, dynamic>> posItems) async {
    final db = await getDatabase();
    try {
      String stockId = DateFormat('yyyy-MMMM-dd').format(DateTime.now());

      for (var item in posItems) {
        // Insert into the posItems table
        int posItemId = await db.insert(
          'posItems',
          {
            'name': item['name'],
            'category': item['category'],
            'subCategory': item['subCategory'],
            'image': item['image'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Now insert into the stock table for each size in the 'price' field
        var prices = item['price']; // This contains sizes like 'XL' and 'M'

        prices.forEach((size, priceDetails) async {
          // Generate a unique itemCode for each stock entry
          String itemCode = await generateItemCode(item['name']);

          await db.insert(
            'stock',
            {
              'item_id': posItemId, // Reference the posItems id
              'unit': item['unit'],
              'priceFormat': item['priceFormat'],
              'price': priceDetails['price'].toString(), // Store price as text
              'size': size.toUpperCase() ?? '',
              'quantity': priceDetails['quantity'],
              'additional': priceDetails['additional'],
              'barcode': priceDetails['barcode'],
              'itemCode': itemCode, // Unique itemCode
              'discountPercentage': priceDetails['discountPercentage'],
              'stockId': stockId, // Set stockId to the unique timestamp
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        });

        print("Inserted posItem with ID: $posItemId");
      }

      return true; // All insertions succeeded
    } catch (e) {
      print("Error inserting posItems: $e");
      return false; // Indicate failure on error
    }
  }

// Helper function to generate unique itemCode
  static Future<String> generateItemCode(String name) async {
    String baseCode = name[0].toUpperCase(); // First letter of the name
    Random random = Random();
    String randomDigits = List.generate(4, (index) => random.nextInt(10))
        .join(); // Generate 4 random digits

    String itemCode =
        baseCode + randomDigits; // Combine the base code and random digits

    // Check if the itemCode already exists in the database
    final db = await getDatabase();
    var result = await db.query(
      'stock',
      where: 'itemCode = ?',
      whereArgs: [itemCode],
    );

    if (result.isNotEmpty) {
      // If itemCode exists, regenerate it
      return await generateItemCode(
          name); // Recursively call until a unique itemCode is generated
    }

    return itemCode; // Return the unique itemCode
  }

  static Future<List<Map<String, dynamic>>> getPosItems({
    required String searchtext, // Search text filter
    required int page, // Page number
    required int pageSize, // Number of items per page
  }) async {
    final db = await getDatabase();

    try {
      // Prepare the SQL query with conditionals based on the searchtext
      String query;
      List<dynamic> queryParams;

      if (searchtext.isNotEmpty) {
        query = '''
        SELECT posItems.*, stock.stockId, stock.unit, stock.priceFormat, stock.price, stock.size,
               stock.quantity, stock.additional, stock.barcode, stock.itemCode, stock.discountPercentage
        FROM posItems
        LEFT JOIN stock ON posItems.id = stock.item_id
        WHERE stock.itemCode = ? COLLATE NOCASE
        LIMIT ? OFFSET ?
      ''';
        queryParams = [searchtext, pageSize, (page - 1) * pageSize];
      } else {
        query = '''
        SELECT posItems.*, stock.stockId, stock.unit, stock.priceFormat, stock.price, stock.size,
               stock.quantity, stock.additional, stock.barcode, stock.itemCode, stock.discountPercentage
        FROM posItems
        LEFT JOIN stock ON posItems.id = stock.item_id
        LIMIT ? OFFSET ?
      ''';
        queryParams = [pageSize, (page - 1) * pageSize];
      }

      // Execute the primary query
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(query, queryParams);

      // If no results, attempt to match `posItems.name` with `searchtext`
      if (maps.isEmpty && searchtext.isNotEmpty) {
        query = '''
        SELECT posItems.*, stock.stockId, stock.unit, stock.priceFormat, stock.price, stock.size,
               stock.quantity, stock.additional, stock.barcode, stock.itemCode, stock.discountPercentage
        FROM posItems
        LEFT JOIN stock ON posItems.id = stock.item_id
        WHERE REPLACE(posItems.name, ' ', '') LIKE REPLACE(?, ' ', '')
        LIMIT ? OFFSET ?
      ''';
        queryParams = ['%$searchtext%', pageSize, (page - 1) * pageSize];

        // Execute the fallback query
        final fallbackMaps = await db.rawQuery(query, queryParams);

        if (fallbackMaps.isNotEmpty) {
          return _processPosItemsResult(fallbackMaps);
        }
      }

      // Process and return the result
      return _processPosItemsResult(maps);
    } catch (e) {
      print("Error fetching posItems with stock: $e");
      return [];
    }
  }

  Map<String, dynamic> itemMap = {
    '1': {
      'id': 1,
      'name': 'king shirt',
      'category': 'Clothing',
      'subCategory': 'Shirts',
      'stock': [
        {
          'stockId': '1737063795113',
          'details': [
            {
              'unit': 'shirt',
              'priceFormat': 'Rs',
              'price': 1450.0,
              'quantity': 50,
              'additional': 'black',
              'barcode': '',
              'itemCode': '1737063795113_M',
              'discountPercentage': 10.0
            },
            {
              'unit': 'shirt',
              'priceFormat': 'Rs',
              'price': 1550.0,
              'quantity': 10,
              'additional': 'red',
              'barcode': '',
              'itemCode': '1737063795113_S',
              'discountPercentage': 0.0
            }
          ]
        },
        // New stock items added
        {
          'stockId': '1737063795114',
          'details': [
            {
              'unit': 'shirt',
              'priceFormat': 'Rs',
              'price': 1600.0,
              'quantity': 30,
              'additional': 'blue',
              'barcode': '',
              'itemCode': '1737063795114_M',
              'discountPercentage': 5.0
            },
            {
              'unit': 'shirt',
              'priceFormat': 'Rs',
              'price': 1700.0,
              'quantity': 20,
              'additional': 'green',
              'barcode': '',
              'itemCode': '1737063795114_L',
              'discountPercentage': 15.0
            }
          ]
        }
      ]
    },
    '2': {
      'id': 2,
      'name': 'queen shirt',
      'category': 'Clothing',
      'subCategory': 'Shirts',
      'stock': [
        {
          'stockId': '1846079235874',
          'details': [
            {
              'unit': 'shirt',
              'priceFormat': 'Rs',
              'price': 1600.0,
              'quantity': 20,
              'additional': 'blue',
              'barcode': '',
              'itemCode': '1846079235874_L',
              'discountPercentage': 5.0
            },
            {
              'unit': 'shirt',
              'priceFormat': 'Rs',
              'price': 1700.0,
              'quantity': 15,
              'additional': 'green',
              'barcode': '',
              'itemCode': '1846079235874_XL',
              'discountPercentage': 15.0
            }
          ]
        },
        // New stock items added
        {
          'stockId': '1846079235875',
          'details': [
            {
              'unit': 'shirt',
              'priceFormat': 'Rs',
              'price': 1800.0,
              'quantity': 40,
              'additional': 'yellow',
              'barcode': '',
              'itemCode': '1846079235875_M',
              'discountPercentage': 8.0
            },
            {
              'unit': 'shirt',
              'priceFormat': 'Rs',
              'price': 1900.0,
              'quantity': 25,
              'additional': 'purple',
              'barcode': '',
              'itemCode': '1846079235875_L',
              'discountPercentage': 12.0
            }
          ]
        }
      ]
    }
  };
// Helper method to process query results into the required structure
  static List<Map<String, dynamic>> _processPosItemsResult(
      List<Map<String, dynamic>> maps) {
    Map<int, Map<String, dynamic>> itemMap = {};

    for (var row in maps) {
      int posItemId = row['id'];

      // If posItem is not already added to the result, add it
      if (!itemMap.containsKey(posItemId)) {
        itemMap[posItemId] = {
          'id': row['id'],
          'name': row['name'],
          'category': row['category'],
          'subCategory': row['subCategory'],
          'image': row['image'],
          'stock': [], // Initialize stock as a list
        };
      }

      // Add stock data if it exists
      if (row['stockId'] != null) {
        String stockId = row['stockId'];

        // Check if this stockId is already in the stock list
        var existingStock = (itemMap[posItemId]!['stock'] as List).firstWhere(
          (stock) => stock['stockId'] == stockId,
          orElse: () => null,
        );

        if (existingStock == null) {
          // Add a new stock entry if it doesn't exist
          (itemMap[posItemId]!['stock'] as List).add({
            'stockId': stockId,
            'details': [], // Initialize details as a list
          });
          existingStock = (itemMap[posItemId]!['stock'] as List).last;
        }

        // Add stock details to the existing stock entry
        (existingStock['details'] as List).add({
          'unit': row['unit'],
          'priceFormat': row['priceFormat'],
          'price': double.tryParse(row['price']) ?? 0.0,
          'size': row['size'],
          'quantity': row['quantity'],
          'additional': row['additional'],
          'barcode': row['barcode'],
          'itemCode': row['itemCode'],
          'discountPercentage': row['discountPercentage'] ?? 0.0,
        });
      }
    }

    // Transform the map into the requested structure
    return itemMap.values.toList();
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
