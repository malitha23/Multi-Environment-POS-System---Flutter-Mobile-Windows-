import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shop_pos_system_app/database/database_helper.dart';

class ItemDetailsDialog extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onClose;

  const ItemDetailsDialog({Key? key, required this.item, this.onClose})
      : super(key: key);

  @override
  _ItemDetailsDialogState createState() => _ItemDetailsDialogState();
}

class _ItemDetailsDialogState extends State<ItemDetailsDialog> {
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
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () {
                                            // Call the function to delete price using item code, stock id, and item id
                                            deletePrice(
                                                context,
                                                widget.item['id'],
                                                stock['stockId'],
                                                detail['itemCode']);
                                          },
                                          child: const Text(
                                            'Delete Price',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            // Move the "Delete Stock" button here under stock name
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // Call the function to delete stock using stock id and item id
                                  deleteStock(context, widget.item['id'],
                                      stock['stockId']);
                                },
                                child: const Text(
                                  'Delete Stock',
                                  style: TextStyle(color: Colors.red),
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
                        // Handle product delete logic using item id
                        deleteProduct(context, widget.item['id']);
                      },
                      child: const Text(
                        'Delete Product',
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

// Function to delete product with confirmation
  Future<void> deleteProduct(BuildContext context, dynamic itemId) async {
    _confirmAction(
      context,
      'Delete Product',
      'Are you sure you want to delete this product?',
      () async {
        try {
          await dbHelper.deleteProduct(itemId);
          _showAlert(context, DialogType.success, 'Success',
              'Product deleted successfully.');
          Future.delayed(Duration(seconds: 1), () {
            if (mounted) {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }
            widget.onClose?.call();
          });
        } catch (e) {
          _showAlert(context, DialogType.error, 'Error',
              'Failed to delete product: $e');
        }
      },
    );
  }

  // Function to delete stock with confirmation
  Future<void> deleteStock(
      BuildContext context, dynamic itemId, dynamic stockId) async {
    _confirmAction(
      context,
      'Delete Stock',
      'Are you sure you want to delete this stock?',
      () async {
        try {
          await dbHelper.deleteStock(itemId, stockId);
          _showAlert(context, DialogType.success, 'Success',
              'Stock deleted successfully.');
          Future.delayed(Duration(seconds: 1), () {
            if (mounted) {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }
            widget.onClose?.call();
          });
        } catch (e) {
          _showAlert(
              context, DialogType.error, 'Error', 'Failed to delete stock: $e');
        }
      },
    );
  }

  Future<void> deletePrice(BuildContext context, dynamic itemId,
      dynamic stockId, dynamic itemCode) async {
    // Ensure the dialog is closed

    _confirmAction(
      context,
      'Delete Price',
      'Are you sure you want to delete this price?',
      () async {
        try {
          // Perform the deletion
          await dbHelper.deletePrice(itemId, stockId, itemCode);

          // Show success alert
          _showAlert(context, DialogType.success, 'Success',
              'Price deleted successfully.');

          Future.delayed(Duration(seconds: 1), () {
            if (mounted) {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }
            widget.onClose?.call();
          });
        } catch (e) {
          // Show error alert
          _showAlert(
            context,
            DialogType.error,
            'Error',
            'Failed to delete price: $e',
          );
        }
      },
    );
  }

// Helper method to confirm action
  void _confirmAction(BuildContext context, String title, String message,
      VoidCallback onConfirm) {
    // Calculate dialog width based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 800 ? 600.0 : screenWidth;

    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      customHeader: FaIcon(
        FontAwesomeIcons.questionCircle, // FontAwesome icon
        size: 50,
        color: Colors.blue, // Customize icon color
      ),
      animType: AnimType.bottomSlide,
      title: title,
      desc: message,
      width: dialogWidth, // Set the dialog width here
      btnCancelOnPress: () {},
      btnOkOnPress: onConfirm,
    ).show();
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
