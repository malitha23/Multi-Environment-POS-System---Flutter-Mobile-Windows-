import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shop_pos_system_app/database/database_helper.dart';

import 'package:shop_pos_system_app/pages/AddPosItemForm.dart';
import 'package:shop_pos_system_app/pages/Pos_Home_Page.dart';
import 'package:shop_pos_system_app/pages/ShopRegistrationPage%20.dart';
import 'package:shop_pos_system_app/pages/ShowAllPosItemsPage.dart';
import 'package:shop_pos_system_app/pages/UpdateAllPosItemsPage.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set up error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    logError(
      'Flutter Error: ${details.exceptionAsString()}\n${details.stack}',
    );
  };

  try {
    // Initialize window manager for desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await windowManager.ensureInitialized();
      await setupWindowManager();
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    // Initialize the database
    await DatabaseHelper.getDatabase();
    await DatabaseHelper.showAllTables();

    // Run the app
    runApp(MyApp());
  } catch (error, stackTrace) {
    logError('Dart Error: $error\n$stackTrace');
  }
}

Future<void> setupWindowManager() async {
  await windowManager.waitUntilReadyToShow();
  await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  await windowManager.setFullScreen(false);
  await windowManager.show();
  await windowManager.focus();
  Future.delayed(const Duration(seconds: 1), () async {
    await windowManager.setResizable(true);
    await windowManager.setFullScreen(false);
  });
}

void logError(String message) async {
  try {
    String logFilePath;

    if (Platform.isAndroid) {
      // Get the app's documents directory for Android
      final directory = await getApplicationDocumentsDirectory();
      logFilePath = '${directory.path}/app_error_log.txt';
    } else if (Platform.isWindows) {
      // Use the Downloads folder for Windows
      final String? userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null) {
        final String downloadsPath = '$userProfile\\Downloads';
        logFilePath = '$downloadsPath\\app_error_log.txt';
      } else {
        print('Failed to locate the Downloads folder on Windows.');
        return;
      }
    } else {
      print('Logging is not supported on this platform.');
      return;
    }

    // Write the error log
    final File logFile = File(logFilePath);
    await logFile.writeAsString(
      '[${DateTime.now()}] $message\n',
      mode: FileMode.append,
    );

    print('Error logged to $logFilePath');
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
        '/updateAllPosItemsPage': (context) => ShowUpdatePosItemsPage(),
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
