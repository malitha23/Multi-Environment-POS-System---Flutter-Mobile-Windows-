import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shop_pos_system_app/database/database_helper.dart';
import 'package:shop_pos_system_app/pages/AddPosItemForm.dart';
import 'package:shop_pos_system_app/pages/Pos_Home_Page.dart';
import 'package:shop_pos_system_app/pages/ShopRegistrationPage%20.dart';
import 'package:shop_pos_system_app/pages/ShowAllPosItemsPage.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  // Ensure that all database initialization is done before the app starts.
  WidgetsFlutterBinding.ensureInitialized();
// Initialize FFI if running on desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

//   await DatabaseHelper.deleteDatabase();
//   final db = await DatabaseHelper.getDatabase();
//   print("Database initialized: ${db.isOpen}");

  // Initialize the database
  await DatabaseHelper.getDatabase();
  // await DatabaseHelper.truncateAllTables();

  // Show tables
  await DatabaseHelper.showAllTables();

  // // Insert test data
  // await DatabaseHelper.insertPosItems([
  //   {
  //     'name': 'Apple',
  //     'category': 'Fruit',
  //     'subCategory': 'Fresh',
  //     'price': {'default': 1.5, 'discounted': 1.2},
  //     'quantity': 50,
  //     'unit': 'kg',
  //     'image': 'apple.png',
  //     'barcode': '123456',
  //     'itemCode': 'ITEM001',
  //     'discount': 10,
  //     'priceFormat': 'regular',
  //   },
  // ]);

  // // Fetch and print data

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop Registration',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/posHomePage',
      routes: {
        '/': (context) => ShopRegisterPage(), // Default screen (Registration)
        '/posHomePage': (context) => PosHomePage(), // Route to POS Items page
        '/AddPosItemForm': (context) =>
            AddPosItemForm(), // Route to POS Items page
        '/showAllPosItemsPage': (context) =>
            ShowAllPosItemsPage(), // Route to POS Items page
      },
    );
  }
}
