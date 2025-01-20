import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shop_pos_system_app/constants/app_colors.dart';
import 'package:shop_pos_system_app/database/database_helper.dart';

class ShowAllPosItemsPage extends StatefulWidget {
  @override
  State<ShowAllPosItemsPage> createState() => _ShowAllPosItemsPageState();
}

class _ShowAllPosItemsPageState extends State<ShowAllPosItemsPage> {
  List<Map<String, dynamic>> items = []; // Initialize items
  final TextEditingController _searchController = TextEditingController();
  late ScrollController _scrollController;
  int _page = 1;
  bool _hasMoreData = true;
  bool _isLoading = false;
  final int pageSize = 20;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _fetchPosItems();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _page = 1;
        items = [];
      });
      _fetchPosItems();
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasMoreData) {
        _fetchPosItems();
      }
    }
  }

  Future<void> _fetchPosItems() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate fetching items
      await Future.delayed(const Duration(seconds: 1));
      final fetchedItems = await DatabaseHelper.getPosItems(
        searchtext: _searchController.text, // Pass the search text
        page: _page, // Current page
        pageSize: pageSize, // Page size
      );

      setState(() {
        items.addAll(fetchedItems);
        _isLoading = false;
        if (fetchedItems.isEmpty) {
          _hasMoreData = false;
        } else {
          _page++;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Items'),
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                hintText: 'Search items...',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      'No items found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: items.length + 1,
                    itemBuilder: (context, index) {
                      if (index == items.length) {
                        return _isLoading
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : const SizedBox.shrink();
                      }
                      final item = items[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 30, // Adjust the radius as needed
                              backgroundColor: Colors.grey[300],
                              backgroundImage: item['image'] != null &&
                                      item['image'].isNotEmpty
                                  ? FileImage(File(item[
                                      'image'])) // Display the image from the file
                                  : null, // If no image path is provided, fallback to default
                              child: item['image'] == null ||
                                      item['image'].isEmpty
                                  ? Icon(
                                      Icons.image,
                                      color: Colors.grey[600],
                                    )
                                  : null, // No icon needed if the image is loaded
                            ),
                            title: Text(
                              item['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              '${item['category']} - ${item['subCategory']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              _showItemDetailsDialog(context, item);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showItemDetailsDialog(BuildContext context, Map<String, dynamic> item) {
    print(item);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('Category: ${item['category']}'),
                Text('Subcategory: ${item['subCategory']}'),
                Text('Price: Rs ${item['price']}'),
                Text('Quantity: ${item['quantity']} ${item['unit']}'),
                Text('Discount: ${item['discount']}%'),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
