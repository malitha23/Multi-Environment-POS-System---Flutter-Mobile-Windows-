import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shop_pos_system_app/constants/app_colors.dart';
import 'package:shop_pos_system_app/database/database_helper.dart';
import 'package:shop_pos_system_app/pages/widgets/ImageDisplay_widget.dart';
import 'package:shop_pos_system_app/pages/widgets/calculator_bottom_sheet.dart';
import 'package:shop_pos_system_app/pages/widgets/user_menu_widget.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PosHomePage extends StatefulWidget {
  @override
  State<PosHomePage> createState() => _PosHomePageState();
}

class _PosHomePageState extends State<PosHomePage> {
  // final List<Map<String, dynamic>> posItems = [
  //   {
  //     'name': 'Samsung S4',
  //     'category': 'Electronics',
  //     'subCategory': 'Mobile Phones',
  //     'price': {'1': 699.99, '0.5': 399.99, '0.25': 199.99},
  //     'quantity': 15,
  //     'unit': 'Piece',
  //     'image': 'assets/images/1.jpg',
  //     'barcode': '123456789012',
  //     'itemCode': 'MP001',
  //     'discount': 0,
  //     'priceFormat': 'Rs'
  //   },
  //   {
  //     'name': 'Shirt',
  //     'category': 'Clothing',
  //     'subCategory': 'Men\'s Wear',
  //     'price': {'1': 19.99, '0.5': 10.99, '0.25': 5.99},
  //     'quantity': 50,
  //     'unit': 'Piece',
  //     'image': 'assets/images/1.jpg',
  //     'barcode': '123456789013',
  //     'itemCode': 'CL001',
  //     'discount': 15,
  //     'priceFormat': 'Rs'
  //   },
  //   {
  //     'name': 'Laptop',
  //     'category': 'Electronics',
  //     'subCategory': 'Computers',
  //     'price': {'1': 999.99, '0.5': 599.99, '0.25': 299.99},
  //     'quantity': 10,
  //     'unit': 'Unit',
  //     'image': 'assets/images/1.jpg',
  //     'barcode': '123456789014',
  //     'itemCode': 'EC001',
  //     'discount': 5,
  //     'priceFormat': 'Rs'
  //   },
  //   {
  //     'name': 'T-shirt',
  //     'category': 'Clothing',
  //     'subCategory': 'Women\'s Wear',
  //     'price': {'1': 9.99, '0.5': 5.99, '0.25': 3.99},
  //     'quantity': 30,
  //     'unit': 'Piece',
  //     'image': 'assets/images/1.jpg',
  //     'barcode': '123456789015',
  //     'itemCode': 'CL002',
  //     'discount': 10,
  //     'priceFormat': 'Rs'
  //   },
  //   {
  //     'name': 'Bananas',
  //     'category': 'Grocery',
  //     'subCategory': 'Fruits',
  //     'price': {'1': 1.99, '0.5': 1.09, '0.25': 0.59},
  //     'quantity': 100,
  //     'unit': 'Kg',
  //     'image': 'assets/images/1.jpg',
  //     'barcode': '123456789016',
  //     'itemCode': 'GR001',
  //     'discount': 0,
  //     'priceFormat': 'Rs'
  //   },
  //   {
  //     'name': 'Dining Table',
  //     'category': 'Furniture',
  //     'subCategory': 'Living Room',
  //     'price': {'1': 199.99, '0.5': 119.99, '0.25': 59.99},
  //     'quantity': 5,
  //     'unit': 'Unit',
  //     'image': 'assets/images/1.jpg',
  //     'barcode': '123456789017',
  //     'itemCode': 'FR001',
  //     'discount': 20,
  //     'priceFormat': 'Rs'
  //   },
  //   {
  //     'name': 'Spaghetti',
  //     'category': 'Restaurant',
  //     'subCategory': 'Pasta',
  //     'price': {'1': 9.99, '0.5': 5.99, '0.25': 2.99},
  //     'quantity': 40,
  //     'unit': 'Plate',
  //     'image': 'assets/images/1.jpg',
  //     'barcode': '123456789029',
  //     'itemCode': 'RS002',
  //     'discount': 5,
  //     'priceFormat': 'Rs'
  //   },
  //   {
  //     'name': 'Caesar Salad',
  //     'category': 'Restaurant',
  //     'subCategory': 'Salad',
  //     'price': {'1': 7.99, '0.5': 4.49, '0.25': 2.49},
  //     'quantity': 60,
  //     'unit': 'Plate',
  //     'image': 'assets/images/1.jpg',
  //     'barcode': '123456789030',
  //     'itemCode': 'RS003',
  //     'discount': 10,
  //     'priceFormat': 'Rs'
  //   },
  //   {
  //     'name': 'Burger',
  //     'category': 'Restaurant',
  //     'subCategory': 'Fast Food',
  //     'price': {'1': 5.99, '0.5': 3.49, '0.25': 1.99},
  //     'quantity': 80,
  //     'unit': 'Piece',
  //     'image': 'assets/images/1.jpg',
  //     'barcode': '123456789031',
  //     'itemCode': 'RF004',
  //     'discount': 15,
  //     'priceFormat': 'Rs'
  //   },
  // ];

  List<Map<String, dynamic>> posItems = [];

  Map<String, dynamic>? selectedItem;

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
    Map<String, bool> selectedPrices = {};
    item['price'].keys.forEach((key) {
      selectedPrices[key] = false;
    });

    selectedPrices['1'] = false; // Default selection
    double selectedQuantity = 1.0;
    double totalPrice = 0; // Ensure price is a double
    double aditionalAddBeforeedtotalPrice = 0; // Ensure price is a double
    String aditionalAddedPrice = ''; // Ensure price is a string
    String priceFormat = item['priceFormat'] ?? '\$';

    String warrantyEndDate = '';
    bool isWarrantyChecked = false;
    Map<String, dynamic> warrantyData = {
      'warrantyYears': 0,
      'warrantyMonths': 0,
      'warrantyDays': 0,
      'warrantyEndDate': '',
    };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.all(8),
          contentPadding: EdgeInsets.only(left: 15, right: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              '${item['name']}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              void updateTotalPrice() {
                totalPrice = _calculateTotalPrice(
                    selectedPrices, selectedQuantity, item);
                aditionalAddBeforeedtotalPrice = totalPrice;
                setDialogState(() {});
              }

              void calculateWarrantyEndDate() {
                final now = DateTime.now();

                // Ensure warranty data is treated as integers before performing the calculation
                final warrantyYears = warrantyData['warrantyYears'] ?? 0;
                final warrantyMonths = warrantyData['warrantyMonths'] ?? 0;
                final warrantyDays = warrantyData['warrantyDays'] ?? 0;

                // Perform the calculation correctly after ensuring all values are numbers (int)
                final totalWarrantyDays =
                    warrantyYears * 365 + warrantyMonths * 30 + warrantyDays;

                final endDate = now.add(Duration(days: totalWarrantyDays));

                // Update the warrantyData map with the calculated end date
                warrantyData['warrantyEndDate'] =
                    '${endDate.toLocal()}'.split(' ')[0]; // Format the date
                setState(() {
                  warrantyEndDate = '${endDate.toLocal()}'.split(' ')[0];
                });
                setDialogState(
                    () {}); // Update the UI (use setState or similar if needed)
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Price Options:',
                        style: AppColors.subtitleStyle),
                    Column(
                      children: item['price'].keys.map<Widget>((key) {
                        return CheckboxListTile(
                          title: Text('$key ${item['unit']}'),
                          subtitle: Text('$priceFormat ${item['price'][key]}'),
                          value: selectedPrices[key],
                          onChanged: (bool? value) {
                            selectedPrices.keys.forEach((k) {
                              selectedPrices[k] = false;
                            });
                            selectedPrices[key] = value ?? false;
                            updateTotalPrice();
                            setDialogState(() {
                              aditionalAddedPrice = '';
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const Text('Quantity:', style: AppColors.subtitleStyle),
                    const SizedBox(height: 8),
                    TextField(
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        hintText: 'Enter quantity',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        selectedQuantity = double.tryParse(value) ?? 1.0;
                        updateTotalPrice();
                        setDialogState(() {
                          aditionalAddedPrice = '';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (item.containsKey('discount') &&
                        (item['discount'] > 0.0)) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Discount:',
                              style: AppColors.subtitleStyle),
                          Text(
                            '-${item['discount']}%',
                            style:
                                const TextStyle(color: AppColors.discountColor),
                          ),
                        ],
                      ),
                    ],
                    if (aditionalAddBeforeedtotalPrice != 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Price:',
                              style: AppColors.subtitleStyle),
                          Text(
                            '$priceFormat ${aditionalAddBeforeedtotalPrice.toStringAsFixed(2)}',
                            style: AppColors.titleStyle,
                          ),
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (aditionalAddedPrice != '')
                          Text(aditionalAddedPrice,
                              style: AppColors.subtitleStyle),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Final Price:',
                            style: AppColors.subtitleStyle),
                        Text(
                          '$priceFormat ${totalPrice.toStringAsFixed(2)}',
                          style: AppColors.titleStyle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildRoundButton(
                            icon: Icons.add,
                            iconColor: AppColors.primaryColor,
                            onPressed: () {
                              double oldPrice = aditionalAddBeforeedtotalPrice;
                              _openBottomSheet(
                                  context, aditionalAddBeforeedtotalPrice,
                                  (updatedPrice) {
                                setDialogState(() {
                                  totalPrice = updatedPrice;
                                  // Print change in price
                                  double priceDifference =
                                      updatedPrice - oldPrice;
                                  if (priceDifference > 0) {
                                    aditionalAddedPrice =
                                        'Price increased by: ${item['priceFormat']} ${priceDifference.toStringAsFixed(2)}';
                                  } else if (priceDifference < 0) {
                                    aditionalAddedPrice =
                                        'Discount added: ${item['priceFormat']} ${(-priceDifference).toStringAsFixed(2)}';
                                  }
                                });
                                Navigator.of(context).pop();
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildRoundButton(
                            icon: Icons.remove,
                            iconColor: Colors.orange,
                            onPressed: () {
                              double oldPrice = aditionalAddBeforeedtotalPrice;
                              _openBottomSheet(
                                  context, aditionalAddBeforeedtotalPrice,
                                  (updatedPrice) {
                                setDialogState(() {
                                  totalPrice = updatedPrice;
                                  // Print change in price
                                  double priceDifference =
                                      updatedPrice - oldPrice;
                                  if (priceDifference > 0) {
                                    aditionalAddedPrice =
                                        'Price increased by: ${item['priceFormat']} ${priceDifference.toStringAsFixed(2)}';
                                  } else if (priceDifference < 0) {
                                    aditionalAddedPrice =
                                        'Discount added: ${item['priceFormat']} ${(-priceDifference).toStringAsFixed(2)}';
                                  }
                                });
                                Navigator.of(context).pop();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: isWarrantyChecked,
                          onChanged: (bool? value) {
                            setDialogState(() {
                              isWarrantyChecked = value ?? false;
                            });
                          },
                        ),
                        const Text('Include Warranty',
                            style: AppColors.subtitleStyle),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (isWarrantyChecked) ...[
                      // Warranty Section
                      const Text('Warranty:', style: AppColors.subtitleStyle),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Years',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                // Ensure the value is parsed as an integer
                                warrantyData['warrantyYears'] =
                                    int.tryParse(value) ?? 0;
                                calculateWarrantyEndDate(); // Recalculate warranty end date
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Months',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                // Ensure the value is parsed as an integer
                                warrantyData['warrantyMonths'] =
                                    int.tryParse(value) ?? 0;
                                calculateWarrantyEndDate(); // Recalculate warranty end date
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Days',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                // Ensure the value is parsed as an integer
                                warrantyData['warrantyDays'] =
                                    int.tryParse(value) ?? 0;
                                calculateWarrantyEndDate(); // Recalculate warranty end date
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      if (warrantyEndDate.isNotEmpty)
                        Text(
                          'Warranty ends on: $warrantyEndDate',
                          style: AppColors.subtitleStyle,
                        ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (totalPrice <= 0) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Invalid Price'),
                        content: const Text(
                            'Please select a valid price before adding to the cart.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  setState(() {
                    checkoutItems.add({
                      'name': item['name'],
                      'selectedQuantity': selectedQuantity,
                      'selectedPrices': selectedPrices,
                      'totalPrice': totalPrice,
                      'unit': item['unit'],
                      'discount': item['discount'] ?? 0,
                      'category': item['category'],
                      'subCategory': item['subCategory'],
                      'price': item['price'],
                      'quantity': item['quantity'],
                      'image': item['image'],
                      'barcode': item['barcode'],
                      'itemCode': item['itemCode'],
                      'priceFormat': item['priceFormat'],
                      'aditionalAddedPrice':
                          aditionalAddedPrice, // Add this line
                      'aditionalAddBeforeedtotalPrice':
                          aditionalAddBeforeedtotalPrice,
                      'warrantyData': isWarrantyChecked ? warrantyData : {},
                    });

                    double formattedSubtotal = checkoutItems.fold(
                        0.0, (sum, item) => sum + item['totalPrice']);

                    subtotal =
                        '${item['priceFormat']}. ${formattedSubtotal.toStringAsFixed(2)}';
                    minPanelHeight = MediaQuery.of(context).size.height * 0.25;
                  });
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              child: const Text('Add to Cart', style: AppColors.buttonStyle),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Row _buildAdditionalPriceRow(String aditionalAddedPrice) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (aditionalAddedPrice.isNotEmpty)
          Text(
            aditionalAddedPrice,
            style: TextStyle(
              color: aditionalAddedPrice.contains('Discount')
                  ? Colors.green
                  : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  void _openUpdatePanel(Map<String, dynamic> item, int index) {
    Map<String, bool> selectedPrices = {};
    item['price'].keys.forEach((key) {
      selectedPrices[key] = false;
    });

    selectedPrices[getSelectedPriceKey(item['selectedPrices'])] =
        true; // Default selection
    double aditionalAddBeforeedtotalPrice =
        item['aditionalAddBeforeedtotalPrice'];
    String aditionalAddedPrice = item['aditionalAddedPrice'];
    double selectedQuantity = item['selectedQuantity'];
    double totalPrice = item['totalPrice']; // Ensure price is a double
    String priceFormat = item['priceFormat'] ?? '\$';
    // Create TextEditingController for each input field
    TextEditingController warrantyYearsController = TextEditingController();
    TextEditingController warrantyMonthsController = TextEditingController();
    TextEditingController warrantyDaysController = TextEditingController();

    String warrantyEndDate = '';
    bool isWarrantyChecked = false;
    Map<String, dynamic> warrantyData = {
      'warrantyYears': 0,
      'warrantyMonths': 0,
      'warrantyDays': 0,
      'warrantyEndDate': '',
    };

    if (item['warrantyData'] != null) {
      setState(() {
        // Update warrantyData with the data from 'item['warrantyData']'
        warrantyData = {
          'warrantyYears': item['warrantyData']['warrantyYears'] ?? 0,
          'warrantyMonths': item['warrantyData']['warrantyMonths'] ?? 0,
          'warrantyDays': item['warrantyData']['warrantyDays'] ?? 0,
          'warrantyEndDate': item['warrantyData']['warrantyEndDate'] ?? '',
        };
        warrantyYearsController.text = warrantyData['warrantyYears'].toString();
        warrantyMonthsController.text =
            warrantyData['warrantyMonths'].toString();
        warrantyDaysController.text = warrantyData['warrantyDays'].toString();

        // Update warrantyEndDate and isWarrantyChecked
        warrantyEndDate = warrantyData['warrantyEndDate'] ?? '';
        isWarrantyChecked = true;
      });
    } else {
      setState(() {
        isWarrantyChecked = false;
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              '${item['name']}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              // Update total price when any selection changes
              void updateTotalPrice() {
                totalPrice = _calculateTotalPrice(
                    selectedPrices, selectedQuantity, item);
                aditionalAddBeforeedtotalPrice = totalPrice;
                setDialogState(() {});
              }

              void calculateWarrantyEndDate() {
                final now = DateTime.now();

                // Ensure warranty data is treated as integers before performing the calculation
                final warrantyYears = warrantyData['warrantyYears'] ?? 0;
                final warrantyMonths = warrantyData['warrantyMonths'] ?? 0;
                final warrantyDays = warrantyData['warrantyDays'] ?? 0;

                // Perform the calculation correctly after ensuring all values are numbers (int)
                final totalWarrantyDays =
                    warrantyYears * 365 + warrantyMonths * 30 + warrantyDays;

                final endDate = now.add(Duration(days: totalWarrantyDays));

                // Update the warrantyData map with the calculated end date
                warrantyData['warrantyEndDate'] =
                    '${endDate.toLocal()}'.split(' ')[0]; // Format the date
                setState(() {
                  warrantyEndDate = '${endDate.toLocal()}'
                      .split(' ')[0]; // Set the end date for the UI
                });
                setDialogState(
                    () {}); // Update the UI (use setState or similar if needed)
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Price Options:',
                        style: AppColors.subtitleStyle),
                    Column(
                      children: item['price'].keys.map<Widget>((key) {
                        return CheckboxListTile(
                          title: Text('$key ${item['unit']}'),
                          subtitle: Text('$priceFormat ${item['price'][key]}'),
                          value: selectedPrices[key],
                          onChanged: (bool? value) {
                            selectedPrices.keys.forEach((k) {
                              selectedPrices[k] = false; // Deselect all
                            });
                            selectedPrices[key] =
                                value ?? false; // Select the clicked one
                            updateTotalPrice();
                            setDialogState(() {
                              aditionalAddedPrice = '';
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const Text('Quantity:', style: AppColors.subtitleStyle),
                    const SizedBox(height: 8),
                    TextField(
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: 'Enter quantity',
                        labelText: selectedQuantity.toString(),
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        selectedQuantity = double.tryParse(value) ?? 1.0;
                        updateTotalPrice();
                        setDialogState(() {
                          aditionalAddedPrice = '';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // If the item has a discount, show the discount value
                    if (item.containsKey('discount') &&
                        (item['discount'] > 0.0)) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Discount:',
                              style: AppColors.subtitleStyle),
                          Text(
                            '-${item['discount']}%',
                            style:
                                const TextStyle(color: AppColors.discountColor),
                          ),
                        ],
                      ),
                    ],
                    if (aditionalAddBeforeedtotalPrice != 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Price:',
                              style: AppColors.subtitleStyle),
                          Text(
                            '$priceFormat ${aditionalAddBeforeedtotalPrice.toStringAsFixed(2)}',
                            style: AppColors.titleStyle,
                          ),
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (aditionalAddedPrice != '')
                          Text(aditionalAddedPrice,
                              style: AppColors.subtitleStyle),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Final Price:',
                            style: AppColors.subtitleStyle),
                        Text(
                          '$priceFormat ${totalPrice.toStringAsFixed(2)}',
                          style: AppColors.titleStyle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildRoundButton(
                          icon: Icons.add,
                          iconColor: AppColors.primaryColor,
                          onPressed: () {
                            double oldPrice = aditionalAddBeforeedtotalPrice;
                            _openBottomSheet(
                                context, aditionalAddBeforeedtotalPrice,
                                (updatedPrice) {
                              setDialogState(() {
                                totalPrice = updatedPrice;
                                // Print change in price
                                double priceDifference =
                                    updatedPrice - oldPrice;
                                if (priceDifference > 0) {
                                  aditionalAddedPrice =
                                      'Price increased by: ${item['priceFormat']} ${priceDifference.toStringAsFixed(2)}';
                                } else if (priceDifference < 0) {
                                  aditionalAddedPrice =
                                      'Discount added: ${item['priceFormat']} ${(-priceDifference).toStringAsFixed(2)}';
                                }
                              });
                              Navigator.of(context).pop();
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildRoundButton(
                          icon: Icons.remove,
                          iconColor: Colors.orange,
                          onPressed: () {
                            double oldPrice = aditionalAddBeforeedtotalPrice;
                            _openBottomSheet(
                                context, aditionalAddBeforeedtotalPrice,
                                (updatedPrice) {
                              setDialogState(() {
                                totalPrice = updatedPrice;
                                // Print change in price
                                double priceDifference =
                                    updatedPrice - oldPrice;
                                if (priceDifference > 0) {
                                  aditionalAddedPrice =
                                      'Price increased by: ${item['priceFormat']} ${priceDifference.toStringAsFixed(2)}';
                                } else if (priceDifference < 0) {
                                  aditionalAddedPrice =
                                      'Discount added: ${item['priceFormat']} ${(-priceDifference).toStringAsFixed(2)}';
                                }
                              });
                              Navigator.of(context).pop();
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: isWarrantyChecked,
                          onChanged: (bool? value) {
                            setDialogState(() {
                              isWarrantyChecked = value ?? false;
                            });
                          },
                        ),
                        const Text('Include Warranty',
                            style: AppColors.subtitleStyle),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (isWarrantyChecked) ...[
                      // Warranty Section
                      const Text('Warranty:', style: AppColors.subtitleStyle),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: warrantyYearsController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Years',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                // Ensure the value is parsed as an integer and update warrantyData
                                warrantyData['warrantyYears'] =
                                    int.tryParse(value) ?? 0;
                                calculateWarrantyEndDate(); // Recalculate the warranty end date
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: warrantyMonthsController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Months',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                // Ensure the value is parsed as an integer and update warrantyData
                                warrantyData['warrantyMonths'] =
                                    int.tryParse(value) ?? 0;
                                calculateWarrantyEndDate(); // Recalculate the warranty end date
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: warrantyDaysController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Days',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                // Ensure the value is parsed as an integer and update warrantyData
                                warrantyData['warrantyDays'] =
                                    int.tryParse(value) ?? 0;
                                calculateWarrantyEndDate(); // Recalculate the warranty end date
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (warrantyEndDate.isNotEmpty)
                        Text(
                          'Warranty ends on: $warrantyEndDate',
                          style: AppColors.subtitleStyle,
                        ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Check if the totalPrice is <= 0
                if (totalPrice <= 0) {
                  // Show an alert if no valid price is selected
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Invalid Price'),
                        content: const Text(
                            'Please select a valid price before adding to the cart.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the alert
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  // Proceed with adding to the cart if price is valid
                  setState(() {
                    checkoutItems[index] = {
                      'name': item['name'],
                      'selectedQuantity': selectedQuantity,
                      'selectedPrices': selectedPrices,
                      'totalPrice': totalPrice,
                      'unit': item['unit'],
                      'discount': item['discount'] ?? 0,
                      'category': item['category'],
                      'subCategory': item['subCategory'],
                      'price': item['price'],
                      'quantity': item['quantity'],
                      'image': item['image'],
                      'barcode': item['barcode'],
                      'itemCode': item['itemCode'],
                      'priceFormat': item['priceFormat'],
                      'aditionalAddedPrice':
                          aditionalAddedPrice, // Add this line
                      'aditionalAddBeforeedtotalPrice':
                          aditionalAddBeforeedtotalPrice,
                      'warrantyData': isWarrantyChecked ? warrantyData : {},
                    };

                    double formattedSubtotal = checkoutItems.fold(
                        0.0, (sum, item) => sum + item['totalPrice']);

                    // Format the subtotal with Rs. currency symbol
                    subtotal =
                        '${item['priceFormat']}. ${formattedSubtotal.toStringAsFixed(2)}';
                    minPanelHeight = MediaQuery.of(context).size.height * 0.25;
                  });
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              child: const Text('Update', style: AppColors.buttonStyle),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _openViewPanel(
      BuildContext context, Map<String, dynamic> item, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            item['name'],
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.primaryColor),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Default Item Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                // Image display
                item['image'] != null ? ImageDisplay(item: item) : Container(),
                const SizedBox(height: 5),
                _buildDetailRow('Name:', item['name']),
                _buildDetailRow('Category:', item['category']),
                _buildDetailRow('SubCategory:', item['subCategory']),
                _buildPriceDetails(
                    item['price'], item['unit'], item['priceFormat']),
                _buildDetailRow(
                    'Item Quantities:', '${item['quantity']} ' + item['unit']),
                _buildDetailRow('Barcode:', item['barcode']),
                _buildDetailRow('Item Code:', item['itemCode']),
                const SizedBox(height: 20),

                // Selected Item Details Section
                const Text(
                  'Selected Item Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                    'Selected Quantity:', item['selectedQuantity'].toString()),

                // Display selectedPrices
                _buildSelectedPricesRow(item['selectedPrices'], item['unit'],
                    item['price'], item['priceFormat']),
                if (item['discount'].toString() != '0')
                  _buildDetailRow(
                      'Discount:', '${item['discount'].toString()}% Adeed.'),

                // Only show the previous total price if it is valid
                if (item['aditionalAddBeforeedtotalPrice'] != null &&
                    item['aditionalAddBeforeedtotalPrice'] != 0)
                  _buildDetailRow('Previous Total Price:',
                      '${item['priceFormat']} ${item['aditionalAddBeforeedtotalPrice'].toStringAsFixed(2)}'),

                // Only show the additional price if it is not empty or 0
                if (item['aditionalAddedPrice'] != '' &&
                    item['aditionalAddedPrice'] != '0')
                  _buildDetailRow(
                      'Additional Price:', item['aditionalAddedPrice']),

                _buildDetailRow('Final Price: ',
                    '${item['priceFormat']} ${item['totalPrice'].toStringAsFixed(2)}'),

                // Warranty Details Section
                if (item['warrantyData'] != null &&
                    item['warrantyData'].isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      const Text(
                        'Warranty Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Safely access warranty data with fallback
                      _buildDetailRow(
                        'Warranty Years:',
                        item['warrantyData']['warrantyYears']?.toString() ??
                            '0',
                      ),
                      _buildDetailRow(
                        'Warranty Months:',
                        item['warrantyData']['warrantyMonths']?.toString() ??
                            '0',
                      ),
                      _buildDetailRow(
                        'Warranty Days:',
                        item['warrantyData']['warrantyDays']?.toString() ?? '0',
                      ),
                      _buildDetailRow(
                        'Warranty End Date:',
                        item['warrantyData']['warrantyEndDate'] ?? 'N/A',
                      ),
                    ],
                  ),
                ]
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(color: AppColors.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

// Helper function to create detail rows with colors
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$label ',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.primaryColor),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textColor),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

// Helper function to display the price details
  Widget _buildPriceDetails(Map priceDetails, String unit, String priceFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: priceDetails.entries.map((entry) {
        return _buildDetailRow(
          'Price for ${entry.key + ' ' + unit} :',
          priceFormat + ' ' + entry.value.toString(),
        );
      }).toList(),
    );
  }

  Widget _buildSelectedPricesRow(
      Map selectedPrices, String unit, Map priceDetails, String priceFormat) {
    List<Widget> selectedPricesList = [];

    selectedPrices.forEach((key, value) {
      if (value) {
        // Get the price corresponding to the key (priceDetails)
        double? price = priceDetails[key];
        if (price != null) {
          selectedPricesList.add(
            Flexible(
              child: Column(
                children: [
                  Text(
                    '$key $unit',
                    style: const TextStyle(color: AppColors.textColor),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                  Text(
                    '${priceFormat} ${price.toString()}',
                    style: const TextStyle(color: AppColors.textColor),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ],
              ),
            ),
          );
        }
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selected Prices: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
          ...selectedPricesList,
        ],
      ),
    );
  }

// Function to calculate the total price based on selected options, quantity, and discount
  double _calculateTotalPrice(Map<String, bool?> selectedPrices,
      double selectedQuantity, Map<String, dynamic> item) {
    // Ensure the price is treated as a double
    double defaultPrice = (item['price']['1'] is double)
        ? item['price']['1']
        : (item['price']['1'] as int).toDouble();

    // Calculate the initial total price
    double total = defaultPrice * selectedQuantity;

    // Loop through selected price options and recalculate total if selected
    selectedPrices.forEach((key, value) {
      if (value == true) {
        double selectedPrice = (item['price'][key] is double)
            ? item['price'][key]
            : (item['price'][key] as int).toDouble();
        total = selectedPrice * selectedQuantity;
      }
    });

    // Apply discount if available (assuming discount is a percentage)
    if (item.containsKey('discount') && item['discount'] != null) {
      double discount = (item['discount'] is double)
          ? item['discount']
          : (item['discount'] as int).toDouble();
      total = total - (total / 100 * discount); // Apply discount percentage
    }

    return total;
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

  // Function to open the Bottom Sheet with the calculator
  void _openBottomSheet(
      BuildContext context, double totalPrice, Function(double) onPriceSet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return CalculatorBottomSheet(
          totalPrice: totalPrice,
          onPriceSet: (newPrice) {
            onPriceSet(newPrice);
          },
        );
      },
    );
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
            body: Stack(
              children: [
                SlidingUpPanel(
                  controller: _panelController,
                  parallaxEnabled: true,
                  parallaxOffset: .5,
                  body: _body(),
                  panelBuilder: (sc) => _buildPanelContent(sc),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18.0),
                    topRight: Radius.circular(18.0),
                  ),
                  onPanelSlide: (double pos) {
                    setState(() {});
                  },
                  minHeight: minPanelHeight,
                  maxHeight: MediaQuery.of(context).size.height,
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
          padding: const EdgeInsets.only(top: 10, left: 8, right: 8),
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
              ? const Center(child: CircularProgressIndicator())
              : posItems.isEmpty
                  ? const Center(child: Text('No Results Found'))
                  : GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _getCrossAxisCount(context),
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
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

// Build panel content to show the added items and subtotal
  Widget _buildPanelContent(ScrollController sc) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                const Text(
                  'Checkout Items:',
                  style: TextStyle(
                    fontSize: 18,
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
                          width:
                              10), // Add space between the text and the button
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
            // Display checkout items
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: checkoutItems.length,
              itemBuilder: (context, index) {
                var item = checkoutItems[index];
                String selectedPriceKey =
                    getSelectedPriceKey(item['selectedPrices']);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Stack(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 6),
                          title: Text(
                            item['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Quantity: ${item['selectedQuantity']}'),
                              const SizedBox(height: 3),
                              Text(
                                '$selectedPriceKey ${item['unit']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          trailing: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              '${item['priceFormat']} ${item['totalPrice'].toStringAsFixed(2)}',
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
                              // View Button
                              _buildRoundButton(
                                icon: Icons.visibility,
                                iconColor: Colors.blue,
                                onPressed: () {
                                  _openViewPanel(
                                      context, item, index); // Open view panel
                                },
                              ),
                              const SizedBox(
                                  width: 8), // Spacer between buttons
                              // Edit Button
                              _buildRoundButton(
                                icon: Icons.edit,
                                iconColor: Colors.orange,
                                onPressed: () {
                                  _openUpdatePanel(
                                      item, index); // Open edit panel
                                },
                              ),
                              const SizedBox(
                                  width: 8), // Spacer between buttons
                              // Remove Button
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
                                                sum + item['totalPrice']);

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

            if (checkoutItems.isNotEmpty)
              // Display the subtotal
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
                ],
              ),
          ],
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 3;
    } else if (width < 900) {
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
