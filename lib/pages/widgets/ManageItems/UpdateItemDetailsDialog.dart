import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shop_pos_system_app/database/database_helper.dart';
import 'package:path/path.dart' as path;

class UpdateItemDetailsDialog extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onClose;

  const UpdateItemDetailsDialog({Key? key, required this.item, this.onClose})
      : super(key: key);

  @override
  _UpdateItemDetailsDialogState createState() =>
      _UpdateItemDetailsDialogState();
}

class _UpdateItemDetailsDialogState extends State<UpdateItemDetailsDialog> {
  DatabaseHelper dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 800 ? 600.0 : screenWidth * 0.9;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: widget.item['image'] != null &&
                              File(widget.item['image']).existsSync()
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image(
                                image: FileImage(File(widget.item['image'])),
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.item['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Category: ${widget.item['category']}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Subcategory: ${widget.item['subCategory']}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                'Stocks:',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.item['stock'].length,
                itemBuilder: (BuildContext context, int stockIndex) {
                  final stock = widget.item['stock'][stockIndex];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stock ID: ${stock['stockId']}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: stock['details'].length,
                              itemBuilder:
                                  (BuildContext context, int detailIndex) {
                                final detail = stock['details'][detailIndex];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Price: ${detail['priceFormat']} ${detail['price']}'),
                                      Text(
                                          'Unit: ${detail['unit']} (${detail['size']})'),
                                      Text('Quantity: ${detail['quantity']}'),
                                      if (detail['additional'] != null &&
                                          detail['additional'].isNotEmpty)
                                        Text(
                                            'Additional: ${detail['additional']}'),
                                      if (detail['barcode'] != null &&
                                          detail['barcode'].isNotEmpty)
                                        Text('Barcode: ${detail['barcode']}'),
                                      Text('Item Code: ${detail['itemCode']}'),
                                      Text(
                                          'Discount: ${detail['discountPercentage']}%'),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        // Open UpdateForm as a new dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return UpdateForm(
                              item: widget.item,
                              onClose: _refreshData,
                            );
                          },
                        );
                      },
                      child: const Text(
                        'Update Product',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Close',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _refreshData() {
    widget.onClose?.call();
  }
}

class UpdateForm extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onClose;

  const UpdateForm({Key? key, required this.item, this.onClose})
      : super(key: key);

  @override
  _UpdateFormState createState() => _UpdateFormState();
}

class _UpdateFormState extends State<UpdateForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _imageController;
  late List<TextEditingController> _priceControllers;
  late List<TextEditingController> _quantityControllers;
  late List<TextEditingController> _discountControllers;
  late List<TextEditingController> _sizeControllers;
  late List<TextEditingController> _unitControllers;
  late List<TextEditingController> _priceFormatControllers;
  late List<TextEditingController> _additionalControllers;

  String? selectedSubcategory;

  Map<String, List<String>> subcategories =
      {}; // Holds the categories and subcategories
  File? _selectedImage;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item['name']);
    _imageController = TextEditingController(text: widget.item['image']);

    // Initialize other controllers for stock details
    _priceControllers = [];
    _quantityControllers = [];
    _discountControllers = [];
    _sizeControllers = [];
    _unitControllers = [];
    _priceFormatControllers = [];
    _additionalControllers = [];

    // Populate stock data controllers
    for (var stock in widget.item['stock']) {
      for (var detail in stock['details']) {
        _priceControllers
            .add(TextEditingController(text: detail['price'].toString()));
        _quantityControllers
            .add(TextEditingController(text: detail['quantity'].toString()));
        _discountControllers.add(TextEditingController(
            text: detail['discountPercentage'].toString()));
        _sizeControllers.add(TextEditingController(text: detail['size'] ?? ''));
        _unitControllers.add(TextEditingController(text: detail['unit'] ?? ''));
        _priceFormatControllers
            .add(TextEditingController(text: detail['priceFormat'] ?? ''));
        _additionalControllers
            .add(TextEditingController(text: detail['additional'] ?? ''));
      }
    }

    // Fetch shop data (categories and subcategories)
    fetchShopData();
  }

  Future<void> fetchShopData() async {
    try {
      await DatabaseHelper.getDatabase();
      List<Map<String, dynamic>> shops =
          await DatabaseHelper.getShopsWithSubcategories();

      setState(() {
        // Populate categories and subcategories
        for (var shop in shops) {
          subcategories[widget.item["category"]] =
              List<String>.from(shop['subcategories'] as List);
        }
      });
    } catch (e) {
      print("Error fetching shop data: $e");
    }
  }

  Future<void> _pickImage() async {
    if (Platform.isAndroid) {
      await _pickImageForAndroid();
    } else if (Platform.isWindows) {
      await _pickImageForWindows();
    } else if (Platform.isIOS) {
      await _pickImageForIOS();
    } else {
      print("Platform not supported.");
    }
  }

  Future<void> _pickImageForAndroid() async {
    if (await Permission.camera.request().isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // Crop the image after picking
        await _cropImage(pickedFile.path);
      } else {
        print('No image selected.');
      }
    } else {
      // Permission denied, show a message
      print('Storage permission denied');
      await openAppSettings();
    }
  }

  Future<void> _pickImageForWindows() async {
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

  Future<void> _pickImageForIOS() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await _cropImage(pickedFile.path);
    } else {
      print('No image selected.');
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 800 ? 600.0 : screenWidth * 0.9;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Display the selected image
                GestureDetector(
                  onTap: _pickImage, // Trigger image picking when tapped
                  child: Container(
                    height: 200, // Adjust height as needed
                    width: double
                        .infinity, // Make image as wide as the parent container
                    child: _selectedImage != null
                        ? Image(
                            image: FileImage(
                                File(_selectedImage!.path)), // For local files
                            fit: BoxFit
                                .cover, // Adjust the image's fit within the container
                          )
                        : (_imageController.text.isNotEmpty
                            ? Image(
                                image: _imageController.text.startsWith('http')
                                    ? NetworkImage(
                                        _imageController.text) // For URLs
                                    : FileImage(File(_imageController
                                        .text)), // For local files
                                fit: BoxFit
                                    .cover, // Adjust the image's fit within the container
                              )
                            : Center(
                                child: Icon(
                                  Icons.add_a_photo,
                                  color: Colors.grey,
                                  size: 50,
                                ),
                              )), // Placeholder when no image is selected
                  ),
                ),

                SizedBox(
                  height: 10,
                ),
                // Editable field for name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter product name';
                    }
                    return null;
                  },
                ),

                if (widget.item["category"] != null)
                  DropdownButtonFormField<String>(
                    value: selectedSubcategory ??
                        (widget.item["subCategory"] == ''
                            ? (subcategories[widget.item["category"].toString()]
                                        ?.isNotEmpty ??
                                    false
                                ? subcategories[
                                        widget.item["category"].toString()]!
                                    .first
                                : null)
                            : widget.item[
                                "subCategory"]), // Check for existing subCategory first
                    onChanged: (newValue) {
                      setState(() {
                        selectedSubcategory = newValue;
                        widget.item["subCategory"] =
                            newValue; // Update item with selected subcategory
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Subcategory'),
                    items: (subcategories[widget.item["category"].toString()] !=
                                null
                            ? subcategories[widget.item["category"].toString()]!
                            : [] // If null, return an empty list
                        )
                        .map((subcategory) {
                      return DropdownMenuItem<String>(
                        value: subcategory,
                        child: Text(subcategory),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a valid subcategory';
                      }
                      return null;
                    },
                  ),

                const SizedBox(height: 20),

                // Stock details (price, quantity, etc.)
                for (var stock in widget.item['stock'])
                  for (var detail in stock['details'])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stock ID: ${stock['stockId']}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _priceControllers[
                                    widget.item['stock'].indexOf(stock) *
                                            stock['details'].length +
                                        stock['details'].indexOf(detail)],
                                keyboardType: TextInputType.number,
                                decoration:
                                    const InputDecoration(labelText: 'Price'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter price';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _quantityControllers[
                                    widget.item['stock'].indexOf(stock) *
                                            stock['details'].length +
                                        stock['details'].indexOf(detail)],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    labelText: 'Quantity'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter quantity';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _discountControllers[
                                    widget.item['stock'].indexOf(stock) *
                                            stock['details'].length +
                                        stock['details'].indexOf(detail)],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    labelText: 'Discount Percentage'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter discount percentage';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _sizeControllers[
                                    widget.item['stock'].indexOf(stock) *
                                            stock['details'].length +
                                        stock['details'].indexOf(detail)],
                                decoration:
                                    const InputDecoration(labelText: 'Size'),
                                validator: (value) {
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _unitControllers[
                                    widget.item['stock'].indexOf(stock) *
                                            stock['details'].length +
                                        stock['details'].indexOf(detail)],
                                decoration:
                                    const InputDecoration(labelText: 'Unit'),
                                validator: (value) {
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _priceFormatControllers[
                                    widget.item['stock'].indexOf(stock) *
                                            stock['details'].length +
                                        stock['details'].indexOf(detail)],
                                decoration: const InputDecoration(
                                    labelText: 'Price Format'),
                                validator: (value) {
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _additionalControllers[
                                    widget.item['stock'].indexOf(stock) *
                                            stock['details'].length +
                                        stock['details'].indexOf(detail)],
                                decoration: const InputDecoration(
                                    labelText: 'Additional Info'),
                                validator: (value) {
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      try {
                        // Get the application's document directory
                        final directory =
                            await getApplicationDocumentsDirectory();

                        // Create the posItemImages subdirectory if it doesn't exist
                        final posItemImagesDirectory =
                            Directory('${directory.path}/posItemImages');
                        if (!await posItemImagesDirectory.exists()) {
                          await posItemImagesDirectory.create(recursive: true);
                        }

                        String imagePath = _imageController.text;

                        // Check if a new image is selected
                        if (_selectedImage != null) {
                          // Check if the current image exists in the directory and delete it
                          if (imagePath.isNotEmpty) {
                            final existingImage = File(imagePath);
                            if (await existingImage.exists()) {
                              await existingImage
                                  .delete(); // Remove the old image
                            }
                          }

                          // Generate the image name and save the new image
                          final imageName = path.basename(_selectedImage!.path);
                          final savedImage = await _selectedImage!.copy(
                              '${posItemImagesDirectory.path}/$imageName');
                          imagePath = savedImage
                              .path; // Update imagePath with the new saved path
                        }

                        // Update item data with new values
                        setState(() {
                          widget.item["name"] = _nameController.text;
                          widget.item["subCategory"] = selectedSubcategory;
                          widget.item["image"] =
                              imagePath; // Update with the new image path

                          // Update stock details
                          int counter = 0;
                          for (var stock in widget.item['stock']) {
                            for (var detail in stock['details']) {
                              detail['price'] =
                                  double.parse(_priceControllers[counter].text);
                              detail['quantity'] =
                                  int.parse(_quantityControllers[counter].text);
                              detail['discountPercentage'] = double.parse(
                                  _discountControllers[counter].text);
                              detail['size'] = _sizeControllers[counter].text;
                              detail['unit'] = _unitControllers[counter].text;
                              detail['priceFormat'] =
                                  _priceFormatControllers[counter].text;
                              detail['additional'] =
                                  _additionalControllers[counter].text;
                              counter++;
                            }
                          }
                        });

                        // Prepare the updated item details
                        var updatedItem = {
                          "id": widget.item["id"],
                          "name": widget.item["name"],
                          "category": widget.item["category"],
                          "subCategory": widget.item["subCategory"],
                          "image": widget.item["image"],
                          "stock": [],
                        };

                        widget.item["stock"].forEach((stock) {
                          var updatedStock = {
                            "stockId": stock["stockId"],
                            "details": [],
                          };

                          stock["details"].forEach((detail) {
                            updatedStock["details"].add({
                              "itemCode": detail["itemCode"],
                              "unit": detail["unit"],
                              "priceFormat": detail["priceFormat"],
                              "price": detail["price"],
                              "size": detail["size"],
                              "quantity": detail["quantity"],
                              "discountPercentage":
                                  detail["discountPercentage"],
                              "additional": detail["additional"],
                              "barcode": detail["barcode"],
                            });
                          });

                          updatedItem["stock"].add(updatedStock);
                        });

                        // Update item in the database
                        bool success =
                            await DatabaseHelper.updateItem(updatedItem);

                        // Show success or error alert
                        if (success) {
                          _showAlert(context, DialogType.success, 'Success',
                              'Item updated successfully.');

                          Future.delayed(Duration(seconds: 1), () {
                            if (mounted) {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              widget.onClose?.call();
                            }
                          });
                        } else {
                          _showAlert(context, DialogType.error, 'Error',
                              'Failed to update item.');
                        }
                      } catch (e) {
                        // Handle exceptions and display error message
                        _showAlert(context, DialogType.error, 'Error',
                            'Failed to update price: $e');
                      }
                    }
                  },
                  child: const Text('Update Product'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to show alerts
  void _showAlert(BuildContext context, DialogType dialogType, String title,
      String message) {
    // Calculate dialog width based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 800 ? 600.0 : screenWidth * 0.8;

    Widget customHeader;
    switch (dialogType) {
      case DialogType.info:
        customHeader = FaIcon(
          FontAwesomeIcons.infoCircle,
          size: 50,
          color: Colors.blue,
        );
        break;
      case DialogType.warning:
        customHeader = FaIcon(
          FontAwesomeIcons.exclamationTriangle,
          size: 50,
          color: Colors.orange,
        );
        break;
      case DialogType.error:
        customHeader = FaIcon(
          FontAwesomeIcons.timesCircle,
          size: 50,
          color: Colors.red,
        );
        break;
      case DialogType.success:
        customHeader = FaIcon(
          FontAwesomeIcons.checkCircle,
          size: 50,
          color: Colors.green,
        );
        break;
      default:
        customHeader = FaIcon(
          FontAwesomeIcons.questionCircle,
          size: 50,
          color: Colors.grey,
        );
        break;
    }

    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      customHeader: customHeader,
      animType: AnimType.scale,
      title: title,
      desc: message,
      width: dialogWidth, // Set the dialog width here
      btnOkOnPress: () {},
    ).show();
  }
}
