import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shop_pos_system_app/database/database_helper.dart';

import 'package:shop_pos_system_app/pages/AddPosItemForm.dart';
import 'package:shop_pos_system_app/pages/Pos_Home_Page.dart';
import 'package:shop_pos_system_app/pages/ShopRegistrationPage%20.dart';
import 'package:shop_pos_system_app/pages/ShowAllPosItemsPage.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set up error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    logError('Flutter Error: ${details.exceptionAsString()}\n${details.stack}');
  };

  try {
    // Initialize the window manager and database
    await windowManager.ensureInitialized();

    // Full-screen mode for Windows only
    if (Platform.isWindows) {
      windowManager.waitUntilReadyToShow().then((_) async {
        // Start in full-screen mode
        await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
        await windowManager.setFullScreen(false);

        // Show the window after initialization
        await windowManager.show();
        await windowManager.focus();

        // After startup, allow resizing and minimizing
        Future.delayed(Duration(seconds: 1), () async {
          await windowManager.setResizable(true);
          await windowManager.setFullScreen(false); // Exit full-screen mode
        });
      });
    }

    // Initialize database for Windows, Linux, and macOS
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    await DatabaseHelper.getDatabase();
    await DatabaseHelper.showAllTables();

    // Run the app after initialization
    runApp(MyApp());
  } catch (error, stackTrace) {
    logError('Dart Error: $error\n$stackTrace');
  }
}

// Log error to the Downloads folder
void logError(String message) async {
  try {
    String? userProfile = Platform.environment['USERPROFILE'];
    if (userProfile != null) {
      String downloadsPath = '$userProfile\\Downloads';
      String logFilePath = '$downloadsPath\\app_error_log.txt';

      File logFile = File(logFilePath);
      await logFile.writeAsString(
        '[${DateTime.now()}] $message\n',
        mode: FileMode.append,
      );
      print('Error logged to $logFilePath');
    } else {
      print('Failed to locate the Downloads folder');
    }
  } catch (e) {
    print('Failed to log error: $e');
  }
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
      initialRoute: '/',
      routes: {
        '/': (context) => ShopRegisterPage(),
        '/posHomePage': (context) => PosHomePage(),
        '/AddPosItemForm': (context) => AddPosItemForm(),
        '/showAllPosItemsPage': (context) => ShowAllPosItemsPage(),
      },
    );
  }
}

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  CustomAppBar({required this.title});

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(30);
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _checkFullScreen();
  }

  Future<void> _checkFullScreen() async {
    bool fullScreen = await windowManager.isFullScreen();
    setState(() {
      isFullScreen = fullScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(widget.title),
      actions: [
        if (Platform.isWindows) ...[
          // Minimize Button
          IconButton(
            icon: Icon(Icons.minimize),
            onPressed: () async {
              await windowManager.minimize();
            },
          ),
          // Maximize/Restore Button
          IconButton(
            icon:
                isFullScreen ? Icon(Icons.crop_square) : Icon(Icons.fullscreen),
            onPressed: () async {
              if (isFullScreen) {
                await windowManager.setFullScreen(false);
                await windowManager.setResizable(true);
              } else {
                await windowManager.setFullScreen(true);
                await windowManager.setResizable(false);
              }
              _checkFullScreen();
            },
          ),
          // Close Button
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () async {
              await windowManager.close();
            },
          ),
        ],
      ],
    );
  }
}
