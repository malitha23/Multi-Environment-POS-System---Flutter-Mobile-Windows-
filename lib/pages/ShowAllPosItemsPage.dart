import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shop_pos_system_app/constants/app_colors.dart';
import 'package:shop_pos_system_app/database/database_helper.dart';
import 'package:shop_pos_system_app/pages/widgets/ImageDisplay_widget.dart';
import 'package:intl/intl.dart';

class ShowAllPosItemsPage extends StatefulWidget {
  @override
  State<ShowAllPosItemsPage> createState() => _ShowAllPosItemsPageState();
}

class _ShowAllPosItemsPageState extends State<ShowAllPosItemsPage> {
  List<Map<String, dynamic>> items = [];
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
    // Initialize scroll controller and listener
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    // Fetch POS items
    _fetchPosItems();
    // Add listener for the search input field
    _searchController.addListener(_onSearchChanged);
  }

  // When the search text changes
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _page = 1;
        items = [];
      });
      _fetchPosItems(); // Fetch posItems after the delay
    });
  }

  // Scroll listener to detect when the user has reached the bottom
  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasMoreData) {
        _fetchPosItems();
      }
    }
  }

  // Fetch posItems with pagination and search text filter
  Future<void> _fetchPosItems() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch items based on current page and search text
      final fetchedItems = await DatabaseHelper.getPosItems(
        searchtext: _searchController.text, // Pass the search text
        page: _page, // Current page
        pageSize: pageSize, // Page size
      );

      setState(() {
        items.addAll(fetchedItems); // Append the new items to the list
        _isLoading = false; // Stop loading
        if (fetchedItems.isEmpty) {
          _hasMoreData = false; // No more data available
        } else {
          _page++; // Increment the page for the next request
        }
      });
    } catch (e) {
      print("Error fetching posItems: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(String date) {
    try {
      // Assuming 'createdate' is in a format like '2024-11-20T12:34:56'
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      return date; // In case of an error, return the original date string
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 10, left: 8, right: 8),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Space between search box and barcode button
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    // Implement menu toggle
                    Navigator.pop(context);
                  },
                  color: AppColors.primaryColor,
                ),
                // Search Box centered
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Container(
                      height:
                          45, // Adjust this value to set the height of the search box
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle:
                              const TextStyle(color: Colors.grey, fontSize: 14),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 15),
                          filled: true,
                          fillColor: const Color.fromARGB(255, 240, 236, 236),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          // Handle search change
                          print('Searching for: $value');
                        },
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.barcode),
                  color: AppColors.primaryColor,
                  iconSize: 20,
                  onPressed: () {
                    // Handle barcode action
                    print("Barcode button pressed");
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      'No data found', // Message for when no data is available
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            onTap: () {
                              // Show the dialog when the item is clicked
                              _showItemDetailsDialog(context, item);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                      height:
                                          8), // Space between image and text

                                  // Display Item Name, Category, Subcategory, and Created Date
                                  Text(
                                    item['name'],
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item['category']} - ${item['subCategory']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Created: ${_formatDate(item['createdate'])}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }

  // Function to show the dialog with the full item details
  void _showItemDetailsDialog(BuildContext context, Map<String, dynamic> item) {
    final price = item['price'][1];
    final imagePath = item['image'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(item['name']),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image (You might need to load the image differently if it's a local path)
                imagePath.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: ImageDisplay(item: item),
                      )
                    : const SizedBox.shrink(),

                const SizedBox(height: 12),

                // Full Item Details
                Text('Category: ${item['category']}'),
                Text('Subcategory: ${item['subCategory']}'),
                Text('Price: ${item['priceFormat']} ${price.toString()}'),
                Text('Quantity: ${item['quantity']} ${item['unit']}'),
                Text('Discount: ${item['discount']}%'),
                Text('Barcode: ${item['barcode']}'),
                Text('Item Code: ${item['itemCode']}'),
                Text(
                  'Created: ${_formatDate(item['createdate'])}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
