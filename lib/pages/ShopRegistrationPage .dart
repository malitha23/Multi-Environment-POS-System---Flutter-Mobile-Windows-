import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shop_pos_system_app/constants/app_colors.dart';
import 'package:shop_pos_system_app/database/database_helper.dart';
import 'package:shop_pos_system_app/main.dart';
import 'package:shop_pos_system_app/pages/widgets/FullScreenLoader.dart';

class ShopRegisterPage extends StatefulWidget {
  @override
  _ShopRegisterPageState createState() => _ShopRegisterPageState();
}

class _ShopRegisterPageState extends State<ShopRegisterPage> {
  final _shopNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = true;

  String selectedCategory = "Clothing";
  List<String> selectedSubcategories = [];

  final Map<String, List<String>> categoriesWithItems = {
    "Clothing": ["Shirts", "Pants", "Shoes", "Accessories"],
    "Electronics": ["Mobile Phones", "Laptops", "Cameras", "Headphones"],
    "Grocery": ["Fruits", "Vegetables", "Dairy Products", "Snacks"],
    "Furniture": ["Tables", "Chairs", "Beds", "Cabinets"],
  };

  @override
  void initState() {
    super.initState();
    checkExistingShop();
  }

  Future<void> checkExistingShop() async {
    try {
      final db = await DatabaseHelper.getDatabase();
      final result = await db.query('shop');

      if (result.isNotEmpty) {
        Navigator.pushReplacementNamed(context, '/posHomePage');
      }
    } catch (e) {
      // Handle error if needed
      print("Error checking shop: $e");
    } finally {
      setState(() {
        isLoading = false; // Loading finished
      });
    }
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> registerShop() async {
    String shopName = _shopNameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    if (shopName.isEmpty || email.isEmpty || password.isEmpty) {
      _showAlertDialog('Please fill in all fields');
      return;
    }

    try {
      Map<String, dynamic> newShop = {
        'shopname': shopName,
        'shopcategory': selectedCategory,
        'email': email,
        'password': password,
      };

      await DatabaseHelper.insertShop(newShop);

      final db = await DatabaseHelper.getDatabase();
      final result = await db.query(
        'shop',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (result.isEmpty) {
        _showAlertDialog('Failed to retrieve shop details after insertion.');
        return;
      }

      int shopId = result.first['id'] as int;

      await DatabaseHelper.insertSubcategories(shopId, selectedSubcategories);
      Navigator.pushReplacementNamed(context, '/posHomePage');
      _showAlertDialog('Shop Registered Successfully!');
    } catch (e) {
      _showAlertDialog('Error: ${e.toString()}');
    }
  }

  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notification'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: (Platform.isWindows || Platform.isAndroid)
          ? CustomAppBar(
              title: '',
            )
          : null, // No AppBar for other platforms

      body: isLoading
          ? Center(
              child: FullScreenLoader(), // Show loader while loading
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: screenWidth > 600 ? 500 : double.infinity,
                        ),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    'Register Your Shop',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                TextField(
                                  controller: _shopNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Shop Name',
                                    prefixIcon: Icon(Icons.store),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                TextField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                SizedBox(height: 20),
                                TextField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: Icon(Icons.lock),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  obscureText: true,
                                ),
                                SizedBox(height: 20),
                                DropdownButtonFormField<String>(
                                  value: selectedCategory,
                                  onChanged: (newCategory) {
                                    setState(() {
                                      selectedCategory = newCategory!;
                                      selectedSubcategories =
                                          categoriesWithItems[
                                              selectedCategory]!;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Category',
                                    prefixIcon: Icon(Icons.category),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  items:
                                      categoriesWithItems.keys.map((category) {
                                    return DropdownMenuItem(
                                      value: category,
                                      child: Text(category),
                                    );
                                  }).toList(),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'Select Subcategories',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                ...categoriesWithItems[selectedCategory]!
                                    .map((subcategory) {
                                  return CheckboxListTile(
                                    title: Text(subcategory),
                                    value: selectedSubcategories
                                        .contains(subcategory),
                                    onChanged: (bool? isSelected) {
                                      setState(() {
                                        if (isSelected == true) {
                                          selectedSubcategories
                                              .add(subcategory);
                                        } else {
                                          selectedSubcategories
                                              .remove(subcategory);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                                SizedBox(height: 20),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: registerShop,
                                    child: Text('Register Shop'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 50,
                                        vertical: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
