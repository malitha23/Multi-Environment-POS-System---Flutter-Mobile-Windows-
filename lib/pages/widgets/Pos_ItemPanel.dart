import 'package:flutter/material.dart';
import 'package:shop_pos_system_app/constants/app_colors.dart';
import 'package:shop_pos_system_app/pages/widgets/calculator_bottom_sheet.dart';

class ItemPanel extends StatefulWidget {
  final Map<String, dynamic> item;
  final Function(List<Map<String, dynamic>>) onSelectedStocksChanged;

  // Constructor to receive the item data
  ItemPanel(
      {Key? key, required this.item, required this.onSelectedStocksChanged})
      : super(key: key);

  @override
  _ItemPanelState createState() => _ItemPanelState();
}

class _ItemPanelState extends State<ItemPanel> {
  Map<String, bool> selectedPrices = {};
  double selectedQuantity = 1.0;
  double totalPrice = 0.0;
  double aditionalAddBeforeedtotalPrice = 0.0;
  String aditionalAddedPrice = '';
  String priceFormat = '';
  String warrantyEndDate = '';
  bool isWarrantyChecked = false;
  List<Map<String, dynamic>> selectedStocks = [];
  String discountLabel = '';
  String errorMessage = '';
  Map<String, dynamic> warrantyData = {
    'warrantyYears': 0,
    'warrantyMonths': 0,
    'warrantyDays': 0,
    'warrantyEndDate': '',
  };

  @override
  void initState() {
    super.initState();
    priceFormat = widget.item['priceFormat'] ?? 'Rs'; // Set priceFormat
    _initializeSelectedPrices();
  }

  // Initialize selectedPrices with the details of the stock items
  void _initializeSelectedPrices() {
    List<dynamic> stock = widget.item['stock'];
    for (var stockItem in stock) {
      for (var detail in stockItem['details']) {
        selectedPrices[detail['itemCode']] =
            false; // Default to false (not selected)
      }
    }
  }

  // Update the total price based on the selected prices
  void updateTotalPrice() {
    setState(() {
      // Get the current date as the warranty start date
      String warrantyStartDate = DateTime.now().toString().split(' ')[0];

      // Clear any previous error message
      errorMessage = '';

      // Iterate over each stock item
      for (var stockItem in widget.item['stock']) {
        for (var detail in stockItem['details']) {
          // Check if the current itemCode is selected
          if (selectedPrices[detail['itemCode']] == true) {
            // Check if the selected quantity is greater than available quantity
            if (selectedQuantity > detail['quantity']) {
              // Set an error message if the quantity exceeds available stock
              errorMessage = 'Quantity exceeds available stock!';
              return; // Exit early to avoid updating the selected stock
            } else {
              totalPrice = _calculateTotalPrice(
                  selectedPrices, selectedQuantity, widget.item);

              if (aditionalAddBeforeedtotalPrice == 0.0) {
                aditionalAddBeforeedtotalPrice = totalPrice;
              }
              // Proceed with updating the selected stock
              int existingIndex = selectedStocks.indexWhere((element) =>
                  element['stockId'] == stockItem['stockId'] &&
                  element['itemCode'] == detail['itemCode']);

              if (existingIndex != -1) {
                // If it exists, update the entry
                selectedStocks[existingIndex] = {
                  'id': widget.item['id'],
                  'name': widget.item['name'],
                  'category': widget.item['category'],
                  'subCategory': widget.item['subCategory'],
                  'image': widget.item['image'],
                  'stockId': stockItem['stockId'],
                  'itemCode': detail['itemCode'],
                  'itemprice': detail['price'],
                  'unit': detail['unit'],
                  'size': detail['size'],
                  'discount': detail['discountPercentage'],
                  'totalprice': totalPrice,
                  'finalprice': aditionalAddBeforeedtotalPrice,
                  'finalpricereson':
                      aditionalAddedPrice != '' ? aditionalAddedPrice : '',
                  'additional': detail['additional'],
                  'selectedQuantity': selectedQuantity,
                  'quantity': detail['quantity'],
                  'priceFormat': detail['priceFormat'],
                  'warrantyStartDate':
                      isWarrantyChecked ? warrantyStartDate : null,
                  'warrantyEndDate': isWarrantyChecked
                      ? warrantyData['warrantyEndDate']
                      : null,
                };
              } else {
                // If it doesn't exist, add a new entry
                selectedStocks.add({
                  'id': widget.item['id'],
                  'name': widget.item['name'],
                  'category': widget.item['category'],
                  'subCategory': widget.item['subCategory'],
                  'image': widget.item['image'],
                  'stockId': stockItem['stockId'],
                  'itemCode': detail['itemCode'],
                  'itemprice': detail['price'],
                  'unit': detail['unit'],
                  'size': detail['size'],
                  'discount': detail['discountPercentage'],
                  'totalprice': totalPrice,
                  'finalprice': aditionalAddBeforeedtotalPrice,
                  'finalpricereson':
                      aditionalAddedPrice != '' ? aditionalAddedPrice : '',
                  'additional': detail['additional'],
                  'selectedQuantity': selectedQuantity,
                  'quantity': detail['quantity'],
                  'priceFormat': detail['priceFormat'],
                  'warrantyStartDate':
                      isWarrantyChecked ? warrantyStartDate : null,
                  'warrantyEndDate': isWarrantyChecked
                      ? warrantyData['warrantyEndDate']
                      : null,
                });
              }
            }
          }
        }
      }
    });
  }

  // Calculate the total price by summing the prices of the selected items
  double _calculateTotalPrice(Map<String, bool> selectedPrices,
      double selectedQuantity, Map<String, dynamic> item) {
    double total = 0.0;
    List<dynamic> stock = item['stock'];

    for (var stockItem in stock) {
      for (var detail in stockItem['details']) {
        if (selectedPrices[detail['itemCode']] == true) {
          // Calculate price based on the discountPercentage
          double itemPrice = detail['price'] * selectedQuantity;

          // If discountPercentage is greater than 0, apply the discount
          if (detail['discountPercentage'] > 0) {
            discountLabel = '${itemPrice} * ${detail['discountPercentage']}%';
            double discountAmount =
                (itemPrice * detail['discountPercentage']) / 100;
            itemPrice -= discountAmount; // Apply the discount
          } else {
            discountLabel = '';
          }

          total += itemPrice; // Add discounted price to the total
        }
      }
    }
    return total;
  }

  // Calculate the warranty end date
  void calculateWarrantyEndDate() {
    final now = DateTime.now();
    final warrantyYears = warrantyData['warrantyYears'] ?? 0;
    final warrantyMonths = warrantyData['warrantyMonths'] ?? 0;
    final warrantyDays = warrantyData['warrantyDays'] ?? 0;

    final totalWarrantyDays =
        warrantyYears * 365 + warrantyMonths * 30 + warrantyDays;

    final endDate = now.add(Duration(days: totalWarrantyDays));
    warrantyData['warrantyEndDate'] = '${endDate.toLocal()}'.split(' ')[0];
    setState(() {
      warrantyEndDate = '${endDate.toLocal()}'.split(' ')[0];
    });
    updateTotalPrice();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> stock = widget.item['stock'];
    stock = stock.map((e) => e as Map<String, dynamic>).toList();
    final double screenWidth = MediaQuery.of(context).size.width;
    return AlertDialog(
      titlePadding: EdgeInsets.all(8),
      contentPadding: EdgeInsets.only(left: 15, right: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      title: Container(
        width: screenWidth > 600 ? 600 : screenWidth * 0.9,
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          color: AppColors
              .primaryColor, // Replace with your AppColors.primaryColor
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: Text(
          '${widget.item['name']}',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: stock.map<Widget>((stockItem) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display only stockId initially
                    Text(
                      'Stock: ${stockItem['stockId']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    // Display price options for the stockId
                    Column(
                      children: stockItem['details'].map<Widget>((detail) {
                        return CheckboxListTile(
                          title: Row(
                            children: [
                              Text('${detail['size'] ?? ''}${detail['unit']}'),
                              const SizedBox(width: 8),
                              Text(
                                '$priceFormat ${detail['price']}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          value: selectedPrices[
                              detail['itemCode']], // Reflect selected state
                          onChanged: (bool? value) {
                            setState(() {
                              // Set the selected item to true and all others to false
                              selectedPrices.forEach((key, _) {
                                selectedPrices[key] = false; // Set all to false
                                totalPrice = 0.0;
                              });
                              selectedPrices[detail['itemCode']] =
                                  value ?? false; // Set selected to true
                              aditionalAddBeforeedtotalPrice = 0.0;
                              aditionalAddedPrice = '';
                            });
                            updateTotalPrice(); // Recalculate total price
                          },
                        );
                      }).toList(),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            TextField(
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Enter quantity',
                border: OutlineInputBorder(),
                // Add a conditional error message if quantity is invalid
                errorText: errorMessage.isNotEmpty
                    ? errorMessage
                    : null, // Display error if needed
              ),
              onChanged: (value) {
                setState(() {
                  // Reset the additional price and total price before validating quantity
                  aditionalAddBeforeedtotalPrice = 0.0;
                  aditionalAddedPrice = '';

                  // Parse the entered value as double, default to 1.0 if invalid
                  double enteredQuantity = double.tryParse(value) ?? 1.0;
                  // Update selected quantity
                  selectedQuantity = enteredQuantity;
                });

                // Recalculate total price based on quantity
                updateTotalPrice();
              },
            ),
            const SizedBox(height: 16),
            if (aditionalAddBeforeedtotalPrice != 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Price:', style: AppColors.subtitleStyle),
                  Text(
                    '$priceFormat ${totalPrice.toStringAsFixed(2)}',
                    style: AppColors.titleStyle,
                  ),
                ],
              ),
            SizedBox(
              height: 5,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (discountLabel != '')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (discountLabel
                          .isNotEmpty) // Check if discountLabel has value
                        Text(
                          'Discount: $discountLabel',
                          style: AppColors.subtitleStyle,
                        ),
                    ],
                  ),
                if (aditionalAddedPrice != '' &&
                    aditionalAddBeforeedtotalPrice != totalPrice)
                  Text(aditionalAddedPrice, style: AppColors.subtitleStyle),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            if (aditionalAddBeforeedtotalPrice != totalPrice)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Final Price:', style: AppColors.subtitleStyle),
                  Text(
                    '$priceFormat ${aditionalAddedPrice != '' ? aditionalAddBeforeedtotalPrice.toStringAsFixed(2) : totalPrice.toStringAsFixed(2)}',
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
                      double oldPrice = totalPrice;
                      _openBottomSheet(context, totalPrice, (updatedPrice) {
                        setState(() {
                          totalPrice = updatedPrice;
                          aditionalAddBeforeedtotalPrice = updatedPrice;
                          double priceDifference = updatedPrice - oldPrice;
                          if (priceDifference > 0) {
                            aditionalAddedPrice =
                                'Price increased by: $priceFormat  ${priceDifference.toStringAsFixed(2)}';
                          } else if (priceDifference < 0) {
                            aditionalAddedPrice =
                                'Additional Discount: $priceFormat  ${(-priceDifference).toStringAsFixed(2)}';
                          }
                          updateTotalPrice();
                          Navigator.of(context).pop();
                        });
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildRoundButton(
                    icon: Icons.remove,
                    iconColor: Colors.orange,
                    onPressed: () {
                      double oldPrice = totalPrice;
                      _openBottomSheet(context, totalPrice, (updatedPrice) {
                        setState(() {
                          totalPrice = updatedPrice;
                          aditionalAddBeforeedtotalPrice = updatedPrice;
                          double priceDifference = updatedPrice - oldPrice;
                          if (priceDifference > 0) {
                            aditionalAddedPrice =
                                'Price increased by: $priceFormat ${priceDifference.toStringAsFixed(2)}';
                          } else if (priceDifference < 0) {
                            aditionalAddedPrice =
                                'Additional Discount: $priceFormat ${(-priceDifference).toStringAsFixed(2)}';
                          }
                          updateTotalPrice();

                          Navigator.of(context).pop();
                        });
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Checkbox(
                  value: isWarrantyChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isWarrantyChecked = value ?? false;
                    });
                    if (isWarrantyChecked) {
                      calculateWarrantyEndDate();
                    }
                    updateTotalPrice();
                  },
                ),
                const Text('Include Warranty', style: TextStyle(fontSize: 16)),
              ],
            ),
            if (isWarrantyChecked) ...[
              const Text('Warranty:', style: TextStyle(fontSize: 16)),
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
                        warrantyData['warrantyYears'] =
                            int.tryParse(value) ?? 0;
                        calculateWarrantyEndDate();
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
                        warrantyData['warrantyMonths'] =
                            int.tryParse(value) ?? 0;
                        calculateWarrantyEndDate();
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
                        warrantyData['warrantyDays'] = int.tryParse(value) ?? 0;
                        calculateWarrantyEndDate();
                      },
                    ),
                  ),
                ],
              ),
              if (warrantyEndDate.isNotEmpty) ...[
                Text('Warranty End Date: $warrantyEndDate',
                    style: TextStyle(fontSize: 16)),
              ],
            ],
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
        ),
        TextButton(
          onPressed: () {
            // Only allow submission if there's no error
            if (errorMessage.isEmpty) {
              setState(() {
                widget.onSelectedStocksChanged(selectedStocks);
              });

              // Submit action logic here
              Navigator.pop(context);
            }
          },
          style: TextButton.styleFrom(
              backgroundColor: errorMessage.isEmpty
                  ? AppColors.primaryColor
                  : Colors.grey[300],
              foregroundColor:
                  errorMessage.isEmpty ? Colors.white : AppColors.primaryColor),
          child: Text(
            errorMessage.isEmpty ? 'Submit' : 'Fix errors before submitting',
            style: TextStyle(
              color:
                  errorMessage.isEmpty ? Colors.white : AppColors.primaryColor,
            ),
          ),
        )
      ],
    );
  }

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
