import 'dart:async';
import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shop_pos_system_app/constants/app_colors.dart';
import 'package:shop_pos_system_app/database/database_helper.dart';
import 'package:shop_pos_system_app/main.dart';
import 'package:shop_pos_system_app/pages/widgets/FullScreenLoader.dart';
import 'package:shop_pos_system_app/pages/widgets/Pos_ItemPanel.dart';
import 'package:shop_pos_system_app/pages/widgets/billPDFGenerator.dart';
import 'package:shop_pos_system_app/pages/widgets/post__ItemDetailDialog%20.dart';
import 'package:shop_pos_system_app/pages/widgets/user_menu_widget.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PosHomePage extends StatefulWidget {
  @override
  State<PosHomePage> createState() => _PosHomePageState();
}

class _PosHomePageState extends State<PosHomePage> {
  List<Map<String, dynamic>> posItems = [];

  double minPanelHeight = 0; // Set the minimum height for the sliding panel
  List<Map<String, dynamic>> checkoutItems = [];
  String subtotal = '0.0';
  double selectedQuantity = 1.0; // Default value
  double totalPrice = 0.0; // Default total price

  Map<String, bool?> selectedPrices = {}; // Track selected price options

  final PanelController _panelController = PanelController();
  bool isOpened = false;

  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();
  final GlobalKey<SideMenuState> _endSideMenuKey = GlobalKey<SideMenuState>();
  final TextEditingController _searchController = TextEditingController();
  late ScrollController _scrollController;
  int _page = 1; // Initial page for pagination
  bool _hasMoreData = true; // Flag to check if there is more data
  bool _isLoading = false; // Track loading state
  final int pageSize = 20;
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    // Fetch posItems when the widget is first created
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _fetchPosItems();
    _searchController.addListener(_onSearchChanged);
  }

// When the search text changes
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _page = 1;
        posItems = [];
      });
      _fetchPosItems(); // Fetch posItems after the delay
    });
  }

// Scroll listener to detect when the user has reached the bottom
  void _scrollListener() {
    // Check if we are at the bottom of the list with a small buffer
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasMoreData) {
        // Fetch more data when scrolled to the bottom
        _fetchPosItems();
      }
    }
  }

  // Fetch posItems with pagination and search text filter
  Future<void> _fetchPosItems() async {
    if (_isLoading) return; // Prevent multiple fetches at the same time

    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      // Fetch items based on current page and search text
      final items = await DatabaseHelper.getPosItems(
        searchtext: _searchController.text, // Pass the search text
        page: _page, // Current page
        pageSize: pageSize, // Page size
      );

      setState(() {
        // var items2 = [
        //   {
        //     "id": 1,
        //     "name": "kings shirt",
        //     "category": "Clothing",
        //     "subCategory": "Shirts",
        //     "image":
        //         "C:\\Users\\Malith\\Documents/{3EE7CDAF-D1A3-4745-B883-FAB5697542C6}.png",
        //     "stock": [
        //       {
        //         "stockId": 1737063795113,
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 50,
        //             "color": "black",
        //             "barcode": "",
        //             "itemCode": "1737063795113_M",
        //             "discountPercentage": 10.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 10,
        //             "color": "red",
        //             "barcode": "",
        //             "itemCode": "1737063795113_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       // Adding more stocks
        //       {
        //         "stockId": 1737063795114, // New unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1500.0,
        //             "quantity": 30,
        //             "color": "blue",
        //             "barcode": "",
        //             "itemCode": "1737063795114_M",
        //             "discountPercentage": 5.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1600.0,
        //             "quantity": 15,
        //             "color": "green",
        //             "barcode": "",
        //             "itemCode": "1737063795114_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       {
        //         "stockId": 1737063795115, // Another unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 20,
        //             "color": "yellow",
        //             "barcode": "",
        //             "itemCode": "1737063795115_M",
        //             "discountPercentage": 15.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 40,
        //             "color": "pink",
        //             "barcode": "",
        //             "itemCode": "1737063795115_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       }
        //     ]
        //   },
        //   {
        //     "id": 2,
        //     "name": "Cool Short",
        //     "category": "Clothing",
        //     "subCategory": "short",
        //     "image":
        //         "C:\\Users\\Malith\\Documents/{3EE7CDAF-D1A3-4745-B883-FAB5697542C6}.png",
        //     "stock": [
        //       {
        //         "stockId": 1737063795113,
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 50,
        //             "color": "black",
        //             "barcode": "",
        //             "itemCode": "1737063795113_M",
        //             "discountPercentage": 10.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 10,
        //             "color": "red",
        //             "barcode": "",
        //             "itemCode": "1737063795113_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       // Adding more stocks
        //       {
        //         "stockId": 1737063795114, // New unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1500.0,
        //             "quantity": 30,
        //             "color": "blue",
        //             "barcode": "",
        //             "itemCode": "1737063795114_M",
        //             "discountPercentage": 5.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1600.0,
        //             "quantity": 15,
        //             "color": "green",
        //             "barcode": "",
        //             "itemCode": "1737063795114_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       {
        //         "stockId": 1737063795115, // Another unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 20,
        //             "color": "yellow",
        //             "barcode": "",
        //             "itemCode": "1737063795115_M",
        //             "discountPercentage": 15.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 40,
        //             "color": "pink",
        //             "barcode": "",
        //             "itemCode": "1737063795115_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       }
        //     ]
        //   },
        //   {
        //     "id": 2,
        //     "name": "Cool Short",
        //     "category": "Clothing",
        //     "subCategory": "short",
        //     "image":
        //         "C:\\Users\\Malith\\Documents/{3EE7CDAF-D1A3-4745-B883-FAB5697542C6}.png",
        //     "stock": [
        //       {
        //         "stockId": 1737063795113,
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 50,
        //             "color": "black",
        //             "barcode": "",
        //             "itemCode": "1737063795113_M",
        //             "discountPercentage": 10.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 10,
        //             "color": "red",
        //             "barcode": "",
        //             "itemCode": "1737063795113_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       // Adding more stocks
        //       {
        //         "stockId": 1737063795114, // New unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1500.0,
        //             "quantity": 30,
        //             "color": "blue",
        //             "barcode": "",
        //             "itemCode": "1737063795114_M",
        //             "discountPercentage": 5.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1600.0,
        //             "quantity": 15,
        //             "color": "green",
        //             "barcode": "",
        //             "itemCode": "1737063795114_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       {
        //         "stockId": 1737063795115, // Another unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 20,
        //             "color": "yellow",
        //             "barcode": "",
        //             "itemCode": "1737063795115_M",
        //             "discountPercentage": 15.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 40,
        //             "color": "pink",
        //             "barcode": "",
        //             "itemCode": "1737063795115_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       }
        //     ]
        //   },
        //   {
        //     "id": 2,
        //     "name": "Cool Short",
        //     "category": "Clothing",
        //     "subCategory": "short",
        //     "image":
        //         "C:\\Users\\Malith\\Documents/{3EE7CDAF-D1A3-4745-B883-FAB5697542C6}.png",
        //     "stock": [
        //       {
        //         "stockId": 1737063795113,
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 50,
        //             "color": "black",
        //             "barcode": "",
        //             "itemCode": "1737063795113_M",
        //             "discountPercentage": 10.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 10,
        //             "color": "red",
        //             "barcode": "",
        //             "itemCode": "1737063795113_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       // Adding more stocks
        //       {
        //         "stockId": 1737063795114, // New unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1500.0,
        //             "quantity": 30,
        //             "color": "blue",
        //             "barcode": "",
        //             "itemCode": "1737063795114_M",
        //             "discountPercentage": 5.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1600.0,
        //             "quantity": 15,
        //             "color": "green",
        //             "barcode": "",
        //             "itemCode": "1737063795114_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       {
        //         "stockId": 1737063795115, // Another unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 20,
        //             "color": "yellow",
        //             "barcode": "",
        //             "itemCode": "1737063795115_M",
        //             "discountPercentage": 15.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 40,
        //             "color": "pink",
        //             "barcode": "",
        //             "itemCode": "1737063795115_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       }
        //     ]
        //   },
        //   {
        //     "id": 2,
        //     "name": "Cool Short",
        //     "category": "Clothing",
        //     "subCategory": "short",
        //     "image":
        //         "C:\\Users\\Malith\\Documents/{3EE7CDAF-D1A3-4745-B883-FAB5697542C6}.png",
        //     "stock": [
        //       {
        //         "stockId": 1737063795113,
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 50,
        //             "color": "black",
        //             "barcode": "",
        //             "itemCode": "1737063795113_M",
        //             "discountPercentage": 10.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 10,
        //             "color": "red",
        //             "barcode": "",
        //             "itemCode": "1737063795113_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       // Adding more stocks
        //       {
        //         "stockId": 1737063795114, // New unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1500.0,
        //             "quantity": 30,
        //             "color": "blue",
        //             "barcode": "",
        //             "itemCode": "1737063795114_M",
        //             "discountPercentage": 5.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1600.0,
        //             "quantity": 15,
        //             "color": "green",
        //             "barcode": "",
        //             "itemCode": "1737063795114_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       {
        //         "stockId": 1737063795115, // Another unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 20,
        //             "color": "yellow",
        //             "barcode": "",
        //             "itemCode": "1737063795115_M",
        //             "discountPercentage": 15.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 40,
        //             "color": "pink",
        //             "barcode": "",
        //             "itemCode": "1737063795115_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       }
        //     ]
        //   },
        //   {
        //     "id": 2,
        //     "name": "Cool Short",
        //     "category": "Clothing",
        //     "subCategory": "short",
        //     "image":
        //         "C:\\Users\\Malith\\Documents/{3EE7CDAF-D1A3-4745-B883-FAB5697542C6}.png",
        //     "stock": [
        //       {
        //         "stockId": 1737063795113,
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 50,
        //             "color": "black",
        //             "barcode": "",
        //             "itemCode": "1737063795113_M",
        //             "discountPercentage": 10.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 10,
        //             "color": "red",
        //             "barcode": "",
        //             "itemCode": "1737063795113_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       // Adding more stocks
        //       {
        //         "stockId": 1737063795114, // New unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1500.0,
        //             "quantity": 30,
        //             "color": "blue",
        //             "barcode": "",
        //             "itemCode": "1737063795114_M",
        //             "discountPercentage": 5.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1600.0,
        //             "quantity": 15,
        //             "color": "green",
        //             "barcode": "",
        //             "itemCode": "1737063795114_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       {
        //         "stockId": 1737063795115, // Another unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 20,
        //             "color": "yellow",
        //             "barcode": "",
        //             "itemCode": "1737063795115_M",
        //             "discountPercentage": 15.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 40,
        //             "color": "pink",
        //             "barcode": "",
        //             "itemCode": "1737063795115_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       }
        //     ]
        //   },
        //   {
        //     "id": 2,
        //     "name": "Cool Short",
        //     "category": "Clothing",
        //     "subCategory": "short",
        //     "image":
        //         "C:\\Users\\Malith\\Documents/{3EE7CDAF-D1A3-4745-B883-FAB5697542C6}.png",
        //     "stock": [
        //       {
        //         "stockId": 1737063795113,
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 50,
        //             "color": "black",
        //             "barcode": "",
        //             "itemCode": "1737063795113_M",
        //             "discountPercentage": 10.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 10,
        //             "color": "red",
        //             "barcode": "",
        //             "itemCode": "1737063795113_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       // Adding more stocks
        //       {
        //         "stockId": 1737063795114, // New unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1500.0,
        //             "quantity": 30,
        //             "color": "blue",
        //             "barcode": "",
        //             "itemCode": "1737063795114_M",
        //             "discountPercentage": 5.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1600.0,
        //             "quantity": 15,
        //             "color": "green",
        //             "barcode": "",
        //             "itemCode": "1737063795114_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       {
        //         "stockId": 1737063795115, // Another unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 20,
        //             "color": "yellow",
        //             "barcode": "",
        //             "itemCode": "1737063795115_M",
        //             "discountPercentage": 15.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 40,
        //             "color": "pink",
        //             "barcode": "",
        //             "itemCode": "1737063795115_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       }
        //     ]
        //   },
        //   {
        //     "id": 2,
        //     "name": "Cool Short",
        //     "category": "Clothing",
        //     "subCategory": "short",
        //     "image":
        //         "C:\\Users\\Malith\\Documents/{3EE7CDAF-D1A3-4745-B883-FAB5697542C6}.png",
        //     "stock": [
        //       {
        //         "stockId": 1737063795113,
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 50,
        //             "color": "black",
        //             "barcode": "",
        //             "itemCode": "1737063795113_M",
        //             "discountPercentage": 10.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 10,
        //             "color": "red",
        //             "barcode": "",
        //             "itemCode": "1737063795113_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       // Adding more stocks
        //       {
        //         "stockId": 1737063795114, // New unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1500.0,
        //             "quantity": 30,
        //             "color": "blue",
        //             "barcode": "",
        //             "itemCode": "1737063795114_M",
        //             "discountPercentage": 5.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1600.0,
        //             "quantity": 15,
        //             "color": "green",
        //             "barcode": "",
        //             "itemCode": "1737063795114_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       {
        //         "stockId": 1737063795115, // Another unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 20,
        //             "color": "yellow",
        //             "barcode": "",
        //             "itemCode": "1737063795115_M",
        //             "discountPercentage": 15.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 40,
        //             "color": "pink",
        //             "barcode": "",
        //             "itemCode": "1737063795115_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       }
        //     ]
        //   },
        //   {
        //     "id": 2,
        //     "name": "Cool Short",
        //     "category": "Clothing",
        //     "subCategory": "short",
        //     "image":
        //         "C:\\Users\\Malith\\Documents/{3EE7CDAF-D1A3-4745-B883-FAB5697542C6}.png",
        //     "stock": [
        //       {
        //         "stockId": 1737063795113,
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 50,
        //             "color": "black",
        //             "barcode": "",
        //             "itemCode": "1737063795113_M",
        //             "discountPercentage": 10.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 10,
        //             "color": "red",
        //             "barcode": "",
        //             "itemCode": "1737063795113_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       // Adding more stocks
        //       {
        //         "stockId": 1737063795114, // New unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1500.0,
        //             "quantity": 30,
        //             "color": "blue",
        //             "barcode": "",
        //             "itemCode": "1737063795114_M",
        //             "discountPercentage": 5.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1600.0,
        //             "quantity": 15,
        //             "color": "green",
        //             "barcode": "",
        //             "itemCode": "1737063795114_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       {
        //         "stockId": 1737063795115, // Another unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 20,
        //             "color": "yellow",
        //             "barcode": "",
        //             "itemCode": "1737063795115_M",
        //             "discountPercentage": 15.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 40,
        //             "color": "pink",
        //             "barcode": "",
        //             "itemCode": "1737063795115_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       }
        //     ]
        //   },
        //   {
        //     "id": 2,
        //     "name": "Cool Short",
        //     "category": "Clothing",
        //     "subCategory": "short",
        //     "image":
        //         "C:\\Users\\Malith\\Documents/{3EE7CDAF-D1A3-4745-B883-FAB5697542C6}.png",
        //     "stock": [
        //       {
        //         "stockId": 1737063795113,
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 50,
        //             "color": "black",
        //             "barcode": "",
        //             "itemCode": "1737063795113_M",
        //             "discountPercentage": 10.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 10,
        //             "color": "red",
        //             "barcode": "",
        //             "itemCode": "1737063795113_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       // Adding more stocks
        //       {
        //         "stockId": 1737063795114, // New unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1500.0,
        //             "quantity": 30,
        //             "color": "blue",
        //             "barcode": "",
        //             "itemCode": "1737063795114_M",
        //             "discountPercentage": 5.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1600.0,
        //             "quantity": 15,
        //             "color": "green",
        //             "barcode": "",
        //             "itemCode": "1737063795114_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       {
        //         "stockId": 1737063795115, // Another unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 20,
        //             "color": "yellow",
        //             "barcode": "",
        //             "itemCode": "1737063795115_M",
        //             "discountPercentage": 15.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 40,
        //             "color": "pink",
        //             "barcode": "",
        //             "itemCode": "1737063795115_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       }
        //     ]
        //   },
        //   {
        //     "id": 2,
        //     "name": "Cool Short",
        //     "category": "Clothing",
        //     "subCategory": "short",
        //     "image":
        //         "C:\\Users\\Malith\\Documents/{3EE7CDAF-D1A3-4745-B883-FAB5697542C6}.png",
        //     "stock": [
        //       {
        //         "stockId": 1737063795113,
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 50,
        //             "color": "black",
        //             "barcode": "",
        //             "itemCode": "1737063795113_M",
        //             "discountPercentage": 10.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 10,
        //             "color": "red",
        //             "barcode": "",
        //             "itemCode": "1737063795113_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       // Adding more stocks
        //       {
        //         "stockId": 1737063795114, // New unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1500.0,
        //             "quantity": 30,
        //             "color": "blue",
        //             "barcode": "",
        //             "itemCode": "1737063795114_M",
        //             "discountPercentage": 5.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1600.0,
        //             "quantity": 15,
        //             "color": "green",
        //             "barcode": "",
        //             "itemCode": "1737063795114_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       {
        //         "stockId": 1737063795115, // Another unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 20,
        //             "color": "yellow",
        //             "barcode": "",
        //             "itemCode": "1737063795115_M",
        //             "discountPercentage": 15.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 40,
        //             "color": "pink",
        //             "barcode": "",
        //             "itemCode": "1737063795115_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       }
        //     ]
        //   },
        //   {
        //     "id": 2,
        //     "name": "Cool Short",
        //     "category": "Clothing",
        //     "subCategory": "short",
        //     "image":
        //         "C:\\Users\\Malith\\Documents/{3EE7CDAF-D1A3-4745-B883-FAB5697542C6}.png",
        //     "stock": [
        //       {
        //         "stockId": 1737063795113,
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 50,
        //             "color": "black",
        //             "barcode": "",
        //             "itemCode": "1737063795113_M",
        //             "discountPercentage": 10.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 10,
        //             "color": "red",
        //             "barcode": "",
        //             "itemCode": "1737063795113_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       // Adding more stocks
        //       {
        //         "stockId": 1737063795114, // New unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1500.0,
        //             "quantity": 30,
        //             "color": "blue",
        //             "barcode": "",
        //             "itemCode": "1737063795114_M",
        //             "discountPercentage": 5.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1600.0,
        //             "quantity": 15,
        //             "color": "green",
        //             "barcode": "",
        //             "itemCode": "1737063795114_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       {
        //         "stockId": 1737063795115, // Another unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 20,
        //             "color": "yellow",
        //             "barcode": "",
        //             "itemCode": "1737063795115_M",
        //             "discountPercentage": 15.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 40,
        //             "color": "pink",
        //             "barcode": "",
        //             "itemCode": "1737063795115_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       }
        //     ]
        //   },
        //   {
        //     "id": 2,
        //     "name": "Cool Short",
        //     "category": "Clothing",
        //     "subCategory": "short",
        //     "image":
        //         "C:\\Users\\Malith\\Documents/{3EE7CDAF-D1A3-4745-B883-FAB5697542C6}.png",
        //     "stock": [
        //       {
        //         "stockId": 1737063795113,
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 50,
        //             "color": "black",
        //             "barcode": "",
        //             "itemCode": "1737063795113_M",
        //             "discountPercentage": 10.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 10,
        //             "color": "red",
        //             "barcode": "",
        //             "itemCode": "1737063795113_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       // Adding more stocks
        //       {
        //         "stockId": 1737063795114, // New unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1500.0,
        //             "quantity": 30,
        //             "color": "blue",
        //             "barcode": "",
        //             "itemCode": "1737063795114_M",
        //             "discountPercentage": 5.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1600.0,
        //             "quantity": 15,
        //             "color": "green",
        //             "barcode": "",
        //             "itemCode": "1737063795114_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       {
        //         "stockId": 1737063795115, // Another unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 20,
        //             "color": "yellow",
        //             "barcode": "",
        //             "itemCode": "1737063795115_M",
        //             "discountPercentage": 15.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 40,
        //             "color": "pink",
        //             "barcode": "",
        //             "itemCode": "1737063795115_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       }
        //     ]
        //   },
        //   {
        //     "id": 2,
        //     "name": "Cool Short",
        //     "category": "Clothing",
        //     "subCategory": "short",
        //     "image":
        //         "C:\\Users\\Malith\\Documents/{3EE7CDAF-D1A3-4745-B883-FAB5697542C6}.png",
        //     "stock": [
        //       {
        //         "stockId": 1737063795113,
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 50,
        //             "color": "black",
        //             "barcode": "",
        //             "itemCode": "1737063795113_M",
        //             "discountPercentage": 10.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 10,
        //             "color": "red",
        //             "barcode": "",
        //             "itemCode": "1737063795113_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       // Adding more stocks
        //       {
        //         "stockId": 1737063795114, // New unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1500.0,
        //             "quantity": 30,
        //             "color": "blue",
        //             "barcode": "",
        //             "itemCode": "1737063795114_M",
        //             "discountPercentage": 5.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1600.0,
        //             "quantity": 15,
        //             "color": "green",
        //             "barcode": "",
        //             "itemCode": "1737063795114_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       {
        //         "stockId": 1737063795115, // Another unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 20,
        //             "color": "yellow",
        //             "barcode": "",
        //             "itemCode": "1737063795115_M",
        //             "discountPercentage": 15.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 40,
        //             "color": "pink",
        //             "barcode": "",
        //             "itemCode": "1737063795115_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       }
        //     ]
        //   },
        //   {
        //     "id": 2,
        //     "name": "Cool Short",
        //     "category": "Clothing",
        //     "subCategory": "short",
        //     "image":
        //         "C:\\Users\\Malith\\Documents/{3EE7CDAF-D1A3-4745-B883-FAB5697542C6}.png",
        //     "stock": [
        //       {
        //         "stockId": 1737063795113,
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 50,
        //             "color": "black",
        //             "barcode": "",
        //             "itemCode": "1737063795113_M",
        //             "discountPercentage": 10.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 10,
        //             "color": "red",
        //             "barcode": "",
        //             "itemCode": "1737063795113_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       // Adding more stocks
        //       {
        //         "stockId": 1737063795114, // New unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1500.0,
        //             "quantity": 30,
        //             "color": "blue",
        //             "barcode": "",
        //             "itemCode": "1737063795114_M",
        //             "discountPercentage": 5.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1600.0,
        //             "quantity": 15,
        //             "color": "green",
        //             "barcode": "",
        //             "itemCode": "1737063795114_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       {
        //         "stockId": 1737063795115, // Another unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 20,
        //             "color": "yellow",
        //             "barcode": "",
        //             "itemCode": "1737063795115_M",
        //             "discountPercentage": 15.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 40,
        //             "color": "pink",
        //             "barcode": "",
        //             "itemCode": "1737063795115_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       }
        //     ]
        //   },
        //   {
        //     "id": 2,
        //     "name": "Cool Short",
        //     "category": "Clothing",
        //     "subCategory": "short",
        //     "image":
        //         "C:\\Users\\Malith\\Documents/{3EE7CDAF-D1A3-4745-B883-FAB5697542C6}.png",
        //     "stock": [
        //       {
        //         "stockId": 1737063795113,
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 50,
        //             "color": "black",
        //             "barcode": "",
        //             "itemCode": "1737063795113_M",
        //             "discountPercentage": 10.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 10,
        //             "color": "red",
        //             "barcode": "",
        //             "itemCode": "1737063795113_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       // Adding more stocks
        //       {
        //         "stockId": 1737063795114, // New unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1500.0,
        //             "quantity": 30,
        //             "color": "blue",
        //             "barcode": "",
        //             "itemCode": "1737063795114_M",
        //             "discountPercentage": 5.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1600.0,
        //             "quantity": 15,
        //             "color": "green",
        //             "barcode": "",
        //             "itemCode": "1737063795114_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       {
        //         "stockId": 1737063795115, // Another unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 20,
        //             "color": "yellow",
        //             "barcode": "",
        //             "itemCode": "1737063795115_M",
        //             "discountPercentage": 15.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 40,
        //             "color": "pink",
        //             "barcode": "",
        //             "itemCode": "1737063795115_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       }
        //     ]
        //   },
        //   {
        //     "id": 2,
        //     "name": "Cool Short",
        //     "category": "Clothing",
        //     "subCategory": "short",
        //     "image":
        //         "C:\\Users\\Malith\\Documents/{3EE7CDAF-D1A3-4745-B883-FAB5697542C6}.png",
        //     "stock": [
        //       {
        //         "stockId": 1737063795113,
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 50,
        //             "color": "black",
        //             "barcode": "",
        //             "itemCode": "1737063795113_M",
        //             "discountPercentage": 10.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 10,
        //             "color": "red",
        //             "barcode": "",
        //             "itemCode": "1737063795113_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       // Adding more stocks
        //       {
        //         "stockId": 1737063795114, // New unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1500.0,
        //             "quantity": 30,
        //             "color": "blue",
        //             "barcode": "",
        //             "itemCode": "1737063795114_M",
        //             "discountPercentage": 5.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1600.0,
        //             "quantity": 15,
        //             "color": "green",
        //             "barcode": "",
        //             "itemCode": "1737063795114_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       {
        //         "stockId": 1737063795115, // Another unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 20,
        //             "color": "yellow",
        //             "barcode": "",
        //             "itemCode": "1737063795115_M",
        //             "discountPercentage": 15.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 40,
        //             "color": "pink",
        //             "barcode": "",
        //             "itemCode": "1737063795115_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       }
        //     ]
        //   },
        //   {
        //     "id": 2,
        //     "name": "Cool Short",
        //     "category": "Clothing",
        //     "subCategory": "short",
        //     "image":
        //         "C:\\Users\\Malith\\Documents/{3EE7CDAF-D1A3-4745-B883-FAB5697542C6}.png",
        //     "stock": [
        //       {
        //         "stockId": 1737063795113,
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 50,
        //             "color": "black",
        //             "barcode": "",
        //             "itemCode": "1737063795113_M",
        //             "discountPercentage": 10.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 10,
        //             "color": "red",
        //             "barcode": "",
        //             "itemCode": "1737063795113_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       // Adding more stocks
        //       {
        //         "stockId": 1737063795114, // New unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1500.0,
        //             "quantity": 30,
        //             "color": "blue",
        //             "barcode": "",
        //             "itemCode": "1737063795114_M",
        //             "discountPercentage": 5.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1600.0,
        //             "quantity": 15,
        //             "color": "green",
        //             "barcode": "",
        //             "itemCode": "1737063795114_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       {
        //         "stockId": 1737063795115, // Another unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 20,
        //             "color": "yellow",
        //             "barcode": "",
        //             "itemCode": "1737063795115_M",
        //             "discountPercentage": 15.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 40,
        //             "color": "pink",
        //             "barcode": "",
        //             "itemCode": "1737063795115_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       }
        //     ]
        //   },
        //   {
        //     "id": 2,
        //     "name": "Cool Short",
        //     "category": "Clothing",
        //     "subCategory": "short",
        //     "image":
        //         "C:\\Users\\Malith\\Documents/{3EE7CDAF-D1A3-4745-B883-FAB5697542C6}.png",
        //     "stock": [
        //       {
        //         "stockId": 1737063795113,
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 50,
        //             "color": "black",
        //             "barcode": "",
        //             "itemCode": "1737063795113_M",
        //             "discountPercentage": 10.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 10,
        //             "color": "red",
        //             "barcode": "",
        //             "itemCode": "1737063795113_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       // Adding more stocks
        //       {
        //         "stockId": 1737063795114, // New unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1500.0,
        //             "quantity": 30,
        //             "color": "blue",
        //             "barcode": "",
        //             "itemCode": "1737063795114_M",
        //             "discountPercentage": 5.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1600.0,
        //             "quantity": 15,
        //             "color": "green",
        //             "barcode": "",
        //             "itemCode": "1737063795114_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       {
        //         "stockId": 1737063795115, // Another unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 20,
        //             "color": "yellow",
        //             "barcode": "",
        //             "itemCode": "1737063795115_M",
        //             "discountPercentage": 15.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 40,
        //             "color": "pink",
        //             "barcode": "",
        //             "itemCode": "1737063795115_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       }
        //     ]
        //   },
        //   {
        //     "id": 2,
        //     "name": "Cool Short",
        //     "category": "Clothing",
        //     "subCategory": "short",
        //     "image":
        //         "C:\\Users\\Malith\\Documents/{3EE7CDAF-D1A3-4745-B883-FAB5697542C6}.png",
        //     "stock": [
        //       {
        //         "stockId": 1737063795113,
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 50,
        //             "color": "black",
        //             "barcode": "",
        //             "itemCode": "1737063795113_M",
        //             "discountPercentage": 10.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 10,
        //             "color": "red",
        //             "barcode": "",
        //             "itemCode": "1737063795113_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       // Adding more stocks
        //       {
        //         "stockId": 1737063795114, // New unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1500.0,
        //             "quantity": 30,
        //             "color": "blue",
        //             "barcode": "",
        //             "itemCode": "1737063795114_M",
        //             "discountPercentage": 5.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1600.0,
        //             "quantity": 15,
        //             "color": "green",
        //             "barcode": "",
        //             "itemCode": "1737063795114_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       {
        //         "stockId": 1737063795115, // Another unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 20,
        //             "color": "yellow",
        //             "barcode": "",
        //             "itemCode": "1737063795115_M",
        //             "discountPercentage": 15.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 40,
        //             "color": "pink",
        //             "barcode": "",
        //             "itemCode": "1737063795115_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       }
        //     ]
        //   },
        //   {
        //     "id": 2,
        //     "name": "Cool Short",
        //     "category": "Clothing",
        //     "subCategory": "short",
        //     "image":
        //         "C:\\Users\\Malith\\Documents/{3EE7CDAF-D1A3-4745-B883-FAB5697542C6}.png",
        //     "stock": [
        //       {
        //         "stockId": 1737063795113,
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 50,
        //             "color": "black",
        //             "barcode": "",
        //             "itemCode": "1737063795113_M",
        //             "discountPercentage": 10.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 10,
        //             "color": "red",
        //             "barcode": "",
        //             "itemCode": "1737063795113_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       // Adding more stocks
        //       {
        //         "stockId": 1737063795114, // New unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1500.0,
        //             "quantity": 30,
        //             "color": "blue",
        //             "barcode": "",
        //             "itemCode": "1737063795114_M",
        //             "discountPercentage": 5.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1600.0,
        //             "quantity": 15,
        //             "color": "green",
        //             "barcode": "",
        //             "itemCode": "1737063795114_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       },
        //       {
        //         "stockId": 1737063795115, // Another unique stock ID
        //         "details": [
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1450.0,
        //             "quantity": 20,
        //             "color": "yellow",
        //             "barcode": "",
        //             "itemCode": "1737063795115_M",
        //             "discountPercentage": 15.0
        //           },
        //           {
        //             "unit": "shirt",
        //             "priceFormat": "Rs",
        //             "price": 1550.0,
        //             "quantity": 40,
        //             "color": "pink",
        //             "barcode": "",
        //             "itemCode": "1737063795115_S",
        //             "discountPercentage": 0.0
        //           }
        //         ]
        //       }
        //     ]
        //   }
        // ];

        posItems.addAll(items); // Append the new items to the list
        _isLoading = false; // Stop loading
        if (items.isEmpty) {
          // _hasMoreData = false; // No more data available
        } else {
          _page++; // Increment the page for the next request
        }
      });
    } catch (e) {
      print("Error fetching posItems: $e");
      setState(() {
        _isLoading = false; // Stop loading on error
      });
    }
  }

  toggleMenu([bool end = false]) {
    if (end) {
      final _state = _sideMenuKey.currentState!;
      if (_state.isOpened) {
        _state.closeSideMenu();
      } else {
        _state.openSideMenu();
      }
    } else {
      final _state = _endSideMenuKey.currentState!;
      if (_state.isOpened) {
        _state.closeSideMenu();
      } else {
        _state.openSideMenu();
      }
    }
  }

  void _openPanel(Map<String, dynamic> item) {
    showItemPanelDialog(context, item);
  }

  // Callback to handle the selected stocks data
  void handleSelectedStocks(List<Map<String, dynamic>> stocks) {
    setState(() {
      Map<String, dynamic> stock =
          stocks[0]; // Assuming you're working with the first stock in the list

      // Get values from the selected stock
      var selectedQuantity =
          stock['selectedQuantity'] ?? 0; // Default to 0 if no quantity
      var totalPrice =
          stock['totalprice'] ?? 0.0; // Default to 0.0 if no totalPrice
      var warrantyStartDate = stock['warrantyStartDate'] ??
          ''; // Default to empty string if no warranty start date
      var warrantyEndDate = stock['warrantyEndDate'] ??
          ''; // Default to empty string if no warranty end date

      checkoutItems.add({
        'id': stock['id'],
        'name': stock['name'],
        'category': stock['category'],
        'subCategory': stock['subCategory'],
        'image': stock['image'],
        'stockId': stock['stockId'],
        'itemCode': stock['itemCode'],
        'itemprice': stock['itemprice'],
        'unit': stock['unit'],
        'size': stock['size'],
        'discount': stock['discount'],
        'totalprice': totalPrice,
        'finalprice': stock['finalprice'] ?? 0.0,
        'finalpricereson':
            stock['finalpricereson'] != '' ? stock['finalpricereson'] : '',
        'additional': stock['additional'] ?? '',
        'selectedQuantity': selectedQuantity,
        'quantity': stock['quantity'],
        'priceFormat': stock['priceFormat'] ?? 'Rs',
        'warrantyStartDate': warrantyStartDate,
        'warrantyEndDate': warrantyEndDate,
      });
      print(checkoutItems);
      // Calculate the subtotal after adding the item
      double formattedSubtotal = checkoutItems.fold(
          0.0, (sum, item) => sum + (item['finalprice'] ?? 0.0));

      // Format the subtotal
      subtotal =
          '${stock['priceFormat']}. ${formattedSubtotal.toStringAsFixed(2)}';

      // Adjust panel height based on items in the checkout list
      minPanelHeight = MediaQuery.of(context).size.height * 0.25;
    });
  }

  void showItemPanelDialog(
      BuildContext context, Map<String, dynamic> yourItemData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ItemPanel(
          item: yourItemData,
          onSelectedStocksChanged: handleSelectedStocks,
        ); // Passing yourItemData to the ItemPanel
      },
    );
  }

  void _openViewPanel(
      BuildContext context, Map<String, dynamic>? item, int index) {
    // Check if item is null
    if (item == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text("Item data is missing or null."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Close"),
              ),
            ],
          );
        },
      );
      return; // Return early to avoid further execution
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ItemDetailDialog(item: item);
      },
    );
  }

// Function to get the key of the selected price (the one with value true)
  String getSelectedPriceKey(Map<String, bool> selectedPrices) {
    // Find the key where the value is true
    String selectedKey = '';

    selectedPrices.forEach((key, value) {
      if (value == true) {
        selectedKey = key; // Set the key where value is true
      }
    });

    return selectedKey;
  }

  @override
  void dispose() {
    _searchController.removeListener(_fetchPosItems);
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if the screen is mobile, tablet, or desktop
    bool isDesktop = MediaQuery.of(context).size.width > 1100;
    bool isTablet = MediaQuery.of(context).size.width > 900 &&
        MediaQuery.of(context).size.width <= 1100;

    return SideMenu(
      key: _endSideMenuKey,
      inverse: true, // end side menu
      background: Colors.white,
      type: SideMenuType.slideNRotate,
      menu: const Padding(
        padding: EdgeInsets.only(left: 25.0),
        child: MenuWidget(),
      ),
      onChange: (_isOpened) {
        setState(() => isOpened = _isOpened);
      },
      child: SideMenu(
        key: _sideMenuKey,
        menu: const MenuWidget(),
        type: SideMenuType.slideNRotate,
        background: AppColors.primaryColor,
        onChange: (_isOpened) {
          setState(() => isOpened = _isOpened);
        },
        child: IgnorePointer(
          ignoring: isOpened,
          child: Scaffold(
            appBar: (Platform.isWindows || Platform.isAndroid)
                ? CustomAppBar(
                    title: '',
                  )
                : null, // No AppBar for other platforms

            body: Stack(
              children: [
                isDesktop
                    ? Row(
                        children: <Widget>[
                          // Left side (3/4 of the screen)
                          Expanded(
                            flex: 3,
                            child: _body(), // Main content on the left side
                          ),
                          // Right side (1/4 of the screen)
                          Expanded(
                            flex: 1,
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: Offset(4, 4),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: _buildPanelContent(ScrollController()),
                              ),
                            ),
                          ),
                        ],
                      )
                    : isTablet
                        ? Row(
                            children: <Widget>[
                              // Left side (2/3 of the screen for tablet)
                              Expanded(
                                flex: 2,
                                child: _body(), // Main content on the left side
                              ),
                              // Right side (1/3 of the screen for tablet)
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.height,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          offset: Offset(4, 4),
                                          blurRadius: 10,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child:
                                        _buildPanelContent(ScrollController()),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : SlidingUpPanel(
                            controller: _panelController,
                            parallaxEnabled: true,
                            parallaxOffset: .5,
                            minHeight: minPanelHeight,
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.75,
                            body: _body(),
                            panelBuilder: (sc) => _buildPanelContent(sc),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(18.0),
                              topRight: Radius.circular(18.0),
                            ),
                            onPanelSlide: (double pos) {
                              setState(() {});
                            },
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Body Widget for displaying data
  Widget _body() {
    return Column(
      children: [
        // Top bar with search and barcode scan button
        Container(
          padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween, // Space between search box and barcode button
            children: [
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => toggleMenu(true),
                color: AppColors.primaryColor,
              ),
              // Search Box centered
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: 5, top: 5, left: 10, right: 10),
                  child: Container(
                    height:
                        45, // Adjust this value to set the height of the search box
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 53, 52, 52),
                            fontSize: 14),
                        contentPadding:
                            const EdgeInsets.only(left: 15, right: 15),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 240, 236, 236),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                  icon: const FaIcon(FontAwesomeIcons.barcode),
                  color: AppColors.primaryColor,
                  iconSize: 14,
                  onPressed: () {
                    print("Pressed");
                  })
            ],
          ),
        ),

        // GridView with items
        Expanded(
          child: _isLoading
              ? FullScreenLoader()
              : posItems.isEmpty
                  ? const Center(child: Text('No Results Found'))
                  : GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(15.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _getCrossAxisCount(context),
                        crossAxisSpacing: 15.0,
                        mainAxisSpacing: 15.0,
                      ),
                      itemCount: posItems.length,
                      itemBuilder: (context, index) {
                        var item = posItems[index];

                        return GestureDetector(
                          onTap: () => _openPanel(item),
                          child: Card(
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                alignment: Alignment
                                    .center, // Centers the child widgets
                                children: [
                                  // Background image of the item
                                  Image.file(
                                    File(item['image']),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                  // Text centered in the middle of the image
                                  Positioned(
                                    bottom: 10, // Adjusted for better alignment
                                    left: 0,
                                    right: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        item[
                                            'name'], // Display the name of the item
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              14, // Adjusted font size for better readability
                                          color: Colors
                                              .white, // Set text color for contrast
                                          shadows: [
                                            Shadow(
                                              color: Colors.black54,
                                              offset: Offset(2, 2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign
                                            .center, // Center-align the text
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildPanelContent(ScrollController sc) {
    bool isDesktop = MediaQuery.of(context).size.width > 1100;
    bool isTablet = MediaQuery.of(context).size.width > 900 &&
        MediaQuery.of(context).size.width <= 1100;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed Header (Checkout Items section)
          Center(
            child: Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Checkout Items:',
                style: TextStyle(
                  fontSize: isDesktop
                      ? 16
                      : isTablet
                          ? 16
                          : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (checkoutItems.isNotEmpty)
                Row(
                  children: [
                    Text(
                      '(${checkoutItems.length} items)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(
                        width: 10), // Add space between the text and the button
                    IconButton(
                      icon: const Icon(Icons.clear_all, color: Colors.red),
                      onPressed: () {
                        // Show confirmation dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Clear Checkout Items'),
                              content: const Text(
                                  'Are you sure you want to clear all checkout items?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    // If user confirms, clear the checkout items
                                    setState(() {
                                      checkoutItems.clear();
                                      subtotal = '0';
                                      minPanelHeight =
                                          MediaQuery.of(context).size.height *
                                              0;
                                    });
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                  child: const Text('Yes',
                                      style: TextStyle(color: Colors.red)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog if canceled
                                  },
                                  child: const Text('No'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    )
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Scrollable List of Items
          Expanded(
            child: ListView.builder(
              controller: sc,
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: checkoutItems.length,
              itemBuilder: (context, index) {
                var item = checkoutItems[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Stack(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 6),
                          title: Row(
                            children: [
                              Text(
                                item['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${item['size'] ?? ''}${item['unit'] ?? ''}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${item['additional'] ?? ''}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Qty: ${item['selectedQuantity']}',
                                style: TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 3),
                            ],
                          ),
                          trailing: Padding(
                            padding: const EdgeInsets.only(top: 21),
                            child: Text(
                              '${item['priceFormat']} ${(item['finalprice'] ?? 0.0).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 4,
                          top: 2, // Adjusted for top-right corner
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _buildRoundButton(
                                icon: Icons.visibility,
                                iconColor: AppColors.primaryColor,
                                onPressed: () {
                                  _openViewPanel(
                                      context, item, index); // Open view panel
                                },
                              ),
                              const SizedBox(
                                  width: 8), // Spacer between buttons
                              _buildRoundButton(
                                icon: Icons.delete,
                                iconColor: Colors.red,
                                onPressed: () {
                                  setState(() {
                                    checkoutItems.removeAt(
                                        index); // Remove the item at the given index
                                    // Update subtotal after removal
                                    double formattedSubtotal =
                                        checkoutItems.fold(
                                            0.0,
                                            (sum, item) =>
                                                sum +
                                                (item['totalPrice'] ?? 0.0));

                                    // Format the subtotal with Rs. currency symbol
                                    subtotal =
                                        '${item['priceFormat']}. ${formattedSubtotal.toStringAsFixed(2)}';
                                    if (checkoutItems.isEmpty) {
                                      minPanelHeight =
                                          MediaQuery.of(context).size.height *
                                              0;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Display the Subtotal at the bottom
          if (checkoutItems.isNotEmpty)
            Column(
              children: [
                const SizedBox(height: 20),
                Divider(color: Colors.grey[400]),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Subtotal:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      subtotal,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, // Makes the button take full width
                  child: ElevatedButton(
                    onPressed: () async {
                      final pdfGenerator = PDFGenerator();
                      final filePath =
                          await pdfGenerator.generateAndSavePDF(checkoutItems);

                      try {
                        if (Platform.isAndroid || Platform.isIOS) {
                          // Get the Downloads directory for Android
                          final downloadDirectory =
                              Directory('/storage/emulated/0/Download');
                          if (!await downloadDirectory.exists()) {
                            await downloadDirectory.create(recursive: true);
                          }

                          final fileName = 'invoice.pdf';
                          final newFilePath =
                              '${downloadDirectory.path}/$fileName';

                          final file = File(filePath);
                          await file.copy(newFilePath);

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('PDF downloaded to $newFilePath'),
                          ));
                        } else if (Platform.isWindows ||
                            Platform.isLinux ||
                            Platform.isMacOS) {
                          // For Desktop platforms, use FileSaver to save the file
                          final file = File(filePath);
                          final fileBytes = await file.readAsBytes();

                          // Use FileSaver to save the file
                          await FileSaver.instance.saveFile(
                            name: 'invoice', // File name without extension
                            bytes: fileBytes,
                            ext: 'pdf', // File extension
                          );

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'PDF downloaded to your default downloads folder'),
                          ));
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Error downloading PDF: $e'),
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor:
                          Colors.green, // Green color for the button
                      padding: const EdgeInsets.symmetric(
                        horizontal:
                            0, // Set horizontal padding to 0 for full width
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30), // Rounded corners
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Pay'),
                  ),
                )
              ],
            ),
        ],
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 3;
    } else if (width < 1100) {
      return 4;
    } else {
      return 6;
    }
  }
}

Widget _buildRoundButton({
  required IconData icon,
  required Color iconColor,
  required VoidCallback onPressed,
}) {
  return Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3), // Shadow color with opacity
          spreadRadius: 1, // Shadow spread
          blurRadius: 6, // Shadow blur radius for a 3D effect
          offset: const Offset(2, 2), // Shadow direction (X, Y offset)
        ),
      ],
    ),
    child: CircleAvatar(
      radius: 12, // Button size
      backgroundColor: Colors.white,
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: 12), // Icon size
        onPressed: onPressed,
        padding: EdgeInsets.zero, // Remove default padding to center the icon
      ),
    ),
  );
}
