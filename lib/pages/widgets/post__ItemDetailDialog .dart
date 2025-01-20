import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shop_pos_system_app/constants/app_colors.dart';

class ItemDetailDialog extends StatefulWidget {
  final Map<String, dynamic>? item;

  const ItemDetailDialog({Key? key, this.item}) : super(key: key);

  @override
  _ItemDetailDialogState createState() => _ItemDetailDialogState();
}

class _ItemDetailDialogState extends State<ItemDetailDialog> {
  @override
  Widget build(BuildContext context) {
    // Check for screen width (desktop view if width is more than 600px)
    bool isDesktopView = MediaQuery.of(context).size.width > 600;
    print(widget.item);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
      title: Text(
        widget.item?['name'] ?? 'Unknown Item',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
          fontSize: 20,
        ),
      ),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Item Details:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryColor,
                ),
              ),
              const SizedBox(height: 10),
              // Image display (preview) - if image exists
              if (widget.item?['image'] != null &&
                  widget.item?['image'].isNotEmpty)
                isDesktopView
                    // For desktop view, place image on the left and details on the right
                    ? Row(
                        children: [
                          _buildImagePreview(widget.item?['image']),
                          const SizedBox(width: 20),
                          Expanded(child: _buildDetailsColumn())
                        ],
                      )
                    : _buildImagePreview(widget.item?['image']),
              // Item details for smaller devices
              if (!isDesktopView) const SizedBox(height: 20),
              if (!isDesktopView) _buildDetailsColumn(),
            ],
          ),
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
  }

  // Helper method to display the image preview if the path is valid
  Widget _buildImagePreview(String imagePath) {
    // Convert string to File object (ensure it's a valid local path)
    File imageFile = File(imagePath);

    return imageFile.existsSync()
        ? Container(
            height: 150, // Set height for the image preview
            width: 150, // Set width for the image preview
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                imageFile,
                fit: BoxFit.cover, // Adjust the image to fit within the box
              ),
            ),
          )
        : const Text('No image available');
  }

  // Helper method to create a column for the details
  Widget _buildDetailsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.item?['id'] != null)
          _buildDetailRow('ID', widget.item?['id']?.toString() ?? 'N/A'),
        if (widget.item?['subCategory'] != null)
          _buildDetailRow(
              'SubCategory', widget.item?['subCategory']?.toString() ?? 'N/A'),
        if (widget.item?['stockId'] != null)
          _buildDetailRow(
              'Stock ID', widget.item?['stockId']?.toString() ?? 'N/A'),
        if (widget.item?['itemCode'] != null)
          _buildDetailRow(
              'Item Code', widget.item?['itemCode']?.toString() ?? 'N/A'),
        if (widget.item?['itemprice'] != null)
          _buildDetailRow('Price', _formatCurrency(widget.item?['itemprice'])),
        if (widget.item?['discount'] != null && widget.item?['discount'] > 0.0)
          _buildDetailRow(
              'Discount', _formatPercentage(widget.item?['discount'])),
        if (widget.item?['totalprice'] != null)
          _buildDetailRow(
              'Total Price', _formatCurrency(widget.item?['totalprice'])),
        if (widget.item?['finalprice'] != null)
          _buildDetailRow(
              'Final Price', _formatCurrency(widget.item?['finalprice'])),
        if (widget.item?['color'] != null)
          _buildDetailRow('Color', widget.item?['color']?.toString() ?? 'N/A'),
        if (widget.item?['selectedQuantity'] != null)
          _buildDetailRow('Selected Quantity',
              widget.item?['selectedQuantity']?.toString() ?? 'N/A'),
        if (widget.item?['quantity'] != null)
          _buildDetailRow(
              'Quantity', widget.item?['quantity']?.toString() ?? 'N/A'),
        if (widget.item?['warrantyStartDate'] != '')
          _buildDetailRow('Warranty Start Date',
              widget.item?['warrantyStartDate']?.toString() ?? 'N/A'),
        if (widget.item?['warrantyEndDate'] != '')
          _buildDetailRow('Warranty End Date',
              widget.item?['warrantyEndDate']?.toString() ?? 'N/A'),
        if (widget.item?['finalpricereson'] != '')
          _buildDetailRow('Final Price Reason',
              widget.item?['finalpricereson']?.toString() ?? 'N/A'),
      ],
    );
  }

  // Helper method to create a detail row widget for each key-value pair
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          Text(
            '$title: ',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
                fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.secondaryColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to format currency values
  String _formatCurrency(dynamic value) {
    if (value != null) {
      return 'Rs ${value.toString()}';
    }
    return 'N/A';
  }

  // Helper method to format discount as a percentage
  String _formatPercentage(dynamic value) {
    if (value != null) {
      return '${value.toString()}%';
    }
    return 'N/A';
  }
}
