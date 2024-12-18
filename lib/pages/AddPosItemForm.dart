import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shop_pos_system_app/database/database_helper.dart';
import 'package:path/path.dart' as path;
import 'package:shop_pos_system_app/constants/app_colors.dart';

class AddPosItemForm extends StatefulWidget {
  @override
  _AddPosItemFormState createState() => _AddPosItemFormState();
}

class _AddPosItemFormState extends State<AddPosItemForm> {
  final _formKey = GlobalKey<FormState>();

  // Controller for other fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _itemCodeController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _priceFormatController = TextEditingController();

  // Dynamic category and subcategory options
  List<String> categories = [];
  Map<String, List<String>> subcategories = {};
  String? selectedCategory;
  String? selectedSubCategory;
  String? priceUnit;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    fetchShopData();
    _priceFormatController.text = 'Rs';
    priceUnit = '';
  }

  Future<void> _pickImage() async {
    // For Android
    if (Platform.isAndroid) {
      // Request storage permission
      PermissionStatus permissionStatus = await Permission.storage.request();

      // Check if permission is granted
      if (permissionStatus.isGranted) {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);

        if (pickedFile != null) {
          // Crop the image after picking
          _cropImage(pickedFile.path);
        } else {
          print('No image selected.');
        }
      } else {
        // Permission denied, show a message
        print('Storage permission denied');
      }
    }
    // For Windows
    else if (Platform.isWindows) {
      // Windows doesn't support cropping, so we just pick the image
      final result = await FilePicker.platform.pickFiles(type: FileType.image);

      if (result != null) {
        setState(() {
          _selectedImage =
              File(result.files.single.path!); // Directly set the image file
        });
      } else {
        print('No image selected.');
      }
    }
  }

  // Function to crop the image with default size 300x300
  Future<void> _cropImage(String imagePath) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,

      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset
              .square, // Ensure square aspect ratio for 300x300
          lockAspectRatio: true, // Lock aspect ratio to square
          cropFrameColor: Colors.transparent,
          backgroundColor: Colors.black.withOpacity(0.7),
        ),
        IOSUiSettings(
          minimumAspectRatio: 1.0,
          resetButtonHidden: true,
          showCancelConfirmationDialog: true,
          aspectRatioLockEnabled: true, // Lock aspect ratio to square
        ),
        WebUiSettings(
          context: context,
        ),
      ],

      maxWidth: 300, // Set maximum width of cropped image to 300px
      maxHeight: 300, // Set maximum height of cropped image to 300px
    );

    if (croppedFile != null) {
      setState(() {
        _selectedImage = File(croppedFile.path);
      });
    } else {
      print('Image cropping canceled.');
    }
  }

  // Initial price inputs map where each key-value pair represents priceUnit and price
  Map<String, double> priceInputs = {
    '1': 0.0, // Predefined priceUnit value and price
  };

  // Counter to keep track of the number of inputs added
  int _inputCounter =
      2; // Start from 4 since you already have 3 predefined values

  // Function to add a new price input with an empty priceUnit value
  void _addNewPriceInput() {
    setState(() {
      // Generate a unique incrementing key
      String newpriceUnit = _inputCounter.toString();
      priceInputs[newpriceUnit] =
          0.0; // Add new entry with incremented key and 0.0 price
      _inputCounter++; // Increment counter for the next input
    });
  }

  void _removePriceInput(String priceUnit) {
    setState(() {
      priceInputs.remove(priceUnit);
    });
  }

  // Function to handle changes in priceUnit and price inputs
  void _onPriceChanged(String priceUnit, String value) {
    setState(() {
      priceInputs[priceUnit] = double.tryParse(value) ??
          0.0; // Update price for the given priceUnit value
    });
  }

  // Function to handle changes in priceUnit input field
  void _onpriceUnitChanged(String priceUnit, String value) {
    setState(() {
      // Allow user to enter any custom priceUnit value
      if (double.tryParse(value) != null) {
        priceInputs.remove(
            priceUnit); // Remove the old priceUnit if it's updated to a new value
        priceInputs[value] = priceInputs[priceUnit] ??
            0.0; // Store the new priceUnit with its corresponding price
      }
    });
  }

  Future<void> fetchShopData() async {
    try {
      // Initialize the database and fetch shop data
      await DatabaseHelper.getDatabase();
      List<Map<String, dynamic>> shops =
          await DatabaseHelper.getShopsWithSubcategories();

      // Populate categories and subcategories
      setState(() {
        categories =
            shops.map((shop) => shop['shopcategory'] as String).toList();
        for (var shop in shops) {
          subcategories[shop['shopcategory']] =
              List<String>.from(shop['subcategories'] as List);
        }
      });
    } catch (e) {
      print("Error fetching shop data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add POS Item',
          style: TextStyle(
            fontSize: 20, // Adjust the font size for readability
            fontWeight: FontWeight.bold, // Make the text bold for prominence
            color: Colors.white, // Set text color to white for contrast
          ),
        ),
        centerTitle: true, // Center the title to make it visually balanced
        backgroundColor: AppColors
            .primaryColor, // Set the AppBar background color (customizable)
        elevation: 4, // Add slight shadow for depth
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.white), // Back button icon
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to the previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Item Name',
                    labelStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    hintText: 'Enter item name',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    prefixIcon: const Icon(
                      Icons.shopping_cart,
                      color: AppColors.primaryColor,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: AppColors.primaryColor, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.red, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.red, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 15.0),
                    fillColor: Colors.grey[200],
                    filled: true,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the item name';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Button to Pick Image
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon:
                          const Icon(Icons.upload_rounded, color: Colors.white),
                      label: const Text(
                        'Upload Image',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Show selected image preview
                    if (_selectedImage != null)
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImage!,
                            height: 120,
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          'No image selected',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: const TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12), // More rounded corners
                      borderSide: BorderSide(
                        color: AppColors.primaryColor
                            .withOpacity(0.6), // Light blue border
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryColor
                            .withOpacity(0.3), // Lighter border when inactive
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color:
                            AppColors.primaryColor, // Blue border when focused
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    filled: true,
                    fillColor: Colors.grey
                        .shade100, // Light background color for the dropdown
                  ),
                  items: categories
                      .map((category) => DropdownMenuItem<String>(
                            value: category,
                            child: Text(
                              category,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                      selectedSubCategory = null; // Reset subcategory
                      if (selectedCategory != 'Grocery') {
                        priceUnit = 'Piece';
                        _unitController.text = 'Piece';
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                // Subcategory Dropdown
                DropdownButtonFormField<String>(
                  value: selectedSubCategory,
                  decoration: InputDecoration(
                    labelText: 'Sub Category',
                    labelStyle: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12), // More rounded corners
                      borderSide: BorderSide(
                        color: AppColors.primaryColor
                            .withOpacity(0.6), // Light blue border
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryColor
                            .withOpacity(0.3), // Lighter border when inactive
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            AppColors.primaryColor, // Blue border when focused
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    filled: true,
                    fillColor: Colors.grey
                        .shade100, // Light background color for the dropdown
                  ),
                  items: (selectedCategory != null
                          ? subcategories[selectedCategory] ?? []
                          : [])
                      .map((subcategory) => DropdownMenuItem<String>(
                            value: subcategory,
                            child: Text(
                              subcategory,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSubCategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a subcategory';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                // Unit TextFormField
                TextFormField(
                  controller: _unitController,
                  decoration: InputDecoration(
                    labelText: 'Unit',
                    labelStyle: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    hintText:
                        'Enter unit', // Optional: provide a hint for the user
                    hintStyle: TextStyle(
                      color: Colors.grey.shade600, // Lighter hint text color
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corners
                      borderSide: BorderSide(
                        color: AppColors.primaryColor
                            .withOpacity(0.6), // Light blue border
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryColor
                            .withOpacity(0.3), // Lighter border when inactive
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            AppColors.primaryColor, // Blue border when focused
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    filled: true,
                    fillColor: Colors
                        .grey.shade100, // Light background color for the input
                  ),
                  onChanged: (value) {
                    setState(() {
                      priceUnit = value; // Update the unit dynamically
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the unit'; // Validation message
                    }
                    return null;
                  },
                ),

                const SizedBox(
                  height: 15,
                ),
                if (priceUnit != '')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price Section Header
                      Text(
                        'Prices (${priceUnit ?? "Kg"} & Price)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors
                              .primaryColor, // Accent color for emphasis
                        ),
                      ),
                      const SizedBox(
                          height: 15), // Space between header and price inputs

                      // Dynamic Price Inputs List
                      ...priceInputs.entries.map((entry) {
                        final unitKey = entry.key; // Current unit (e.g., kg)
                        final unitPrice = entry.value; // Corresponding price

                        return Padding(
                          padding: const EdgeInsets.only(
                              bottom: 12), // Space between each price input row
                          child: Row(
                            children: [
                              // Unit Input (e.g., Kg)
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: unitKey,
                                  decoration: InputDecoration(
                                    labelText: '${priceUnit ?? "Kg"}',
                                    labelStyle: TextStyle(
                                        color: AppColors.primaryColor),
                                    hintText: 'Enter unit (e.g., Kg)',
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: AppColors.primaryColor
                                              .withOpacity(0.5),
                                          width: 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: AppColors.primaryColor,
                                          width: 2),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) =>
                                      _onpriceUnitChanged(unitKey, value),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Enter a valid ${priceUnit ?? "unit"}';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Invalid ${priceUnit ?? "unit"}';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Price Input
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: unitPrice.toString(),
                                  decoration: InputDecoration(
                                    labelText: 'Price',
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: AppColors.primaryColor
                                              .withOpacity(0.5),
                                          width: 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: AppColors.primaryColor,
                                          width: 2),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) =>
                                      _onPriceChanged(unitKey, value),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Enter a valid price';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Invalid price';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Remove Button
                              IconButton(
                                icon: const Icon(Icons.remove_circle,
                                    color: Colors.red),
                                onPressed: () => _removePriceInput(unitKey),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      // Add New Price Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: _addNewPriceInput,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.primaryColor, // Button color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          child: const Text(
                            'Add New Price',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 16),

                // Quantity Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quantity Field
                    TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        labelStyle: TextStyle(color: AppColors.primaryColor),
                        hintText: 'Enter quantity',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.primaryColor.withOpacity(0.5),
                              width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.primaryColor, width: 2),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the quantity';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12), // Space between fields

                    // Barcode Field
                    TextFormField(
                      controller: _barcodeController,
                      decoration: InputDecoration(
                        labelText: 'Barcode',
                        labelStyle: TextStyle(color: AppColors.primaryColor),
                        hintText: 'Enter barcode',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.primaryColor.withOpacity(0.5),
                              width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.primaryColor, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Item Code Field
                    TextFormField(
                      controller: _itemCodeController,
                      decoration: InputDecoration(
                        labelText: 'Item Code',
                        labelStyle: TextStyle(color: AppColors.primaryColor),
                        hintText: 'Enter item code',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.primaryColor.withOpacity(0.5),
                              width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.primaryColor, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Discount Field
                    TextFormField(
                      controller: _discountController,
                      decoration: InputDecoration(
                        labelText: 'Discount',
                        labelStyle: TextStyle(color: AppColors.primaryColor),
                        hintText: 'Enter discount percentage',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.primaryColor.withOpacity(0.5),
                              width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.primaryColor, width: 2),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),

                    // Price Format Field
                    TextFormField(
                      controller: _priceFormatController,
                      decoration: InputDecoration(
                        labelText: 'Price Format',
                        labelStyle: TextStyle(color: AppColors.primaryColor),
                        hintText: 'Enter price format',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.primaryColor.withOpacity(0.5),
                              width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.primaryColor, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),

                // Submit Button
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Ensure a category is selected
                      if (selectedCategory == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please select a category')),
                        );
                        return;
                      }

                      // Ensure a subcategory is selected
                      if (selectedSubCategory == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please select a subcategory')),
                        );
                        return;
                      }

                      // Ensure an image is selected
                      if (_selectedImage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please select an image')),
                        );
                        return;
                      }

                      // Collect form data
                      final posItem = {
                        'name': _nameController.text,
                        'category': selectedCategory,
                        'subCategory': selectedSubCategory,
                        'quantity': int.tryParse(_quantityController.text) ?? 0,
                        'unit': _unitController.text,
                        'barcode': _barcodeController.text,
                        'itemCode': _itemCodeController.text,
                        'discount': _discountController.text.isNotEmpty
                            ? int.tryParse(_discountController.text) ?? 0
                            : 0,
                        'priceFormat': _priceFormatController.text,
                        'price':
                            priceInputs, // Ensure priceInputs is correctly formatted
                      };

                      try {
                        // Save the image locally
                        final directory =
                            await getApplicationDocumentsDirectory();
                        final imageName = path.basename(_selectedImage!.path);
                        final savedImage = await _selectedImage!
                            .copy('${directory.path}/$imageName');

                        // Add image path to the form data
                        posItem['image'] = savedImage.path;

                        // Insert data into the database
                        bool success =
                            await DatabaseHelper.insertPosItems([posItem]);

                        // Show feedback based on the result
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('POS Item added successfully!')),
                          );

                          // Reset the form
                          _formKey.currentState!.reset();
                          setState(() {
                            selectedCategory = null;
                            selectedSubCategory = null;
                            _selectedImage = null;
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Failed to add the POS Item.')),
                          );
                        }
                      } catch (e) {
                        // Handle unexpected errors
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(AppColors.primaryColor),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(vertical: 12, horizontal: 24)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16), // Rounded corners
                      ),
                    ),
                    elevation: MaterialStateProperty.all(
                        5), // Shadow for elevation effect
                    overlayColor: MaterialStateProperty.all(AppColors
                        .primaryColor
                        .withOpacity(0.1)), // Subtle hover effect
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold, // Bold text for emphasis
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
