import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class POSBillScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cart = [
    {
      'id': 1,
      'name': 'Rice',
      'category': 'Grocery',
      'subCategory': 'Dairy Products',
      'image': 'C:\\Users\\Malith\\Documents/download (22).jpg',
      'stockId': '2025-January-18',
      'itemCode': 'R9394',
      'itemprice': 120.0,
      'unit': 'Kg',
      'size': 1,
      'discount': 0.0,
      'totalprice': 1200.0,
      'finalprice': 1000.0,
      'finalpricereson': 'Additional Discount: Rs 200.00',
      'additional': '',
      'selectedQuantity': 10.0,
      'quantity': 500,
      'priceFormat': 'Rs',
      'warrantyStartDate': '2025-01-19',
      'warrantyEndDate': '2026-01-19'
    },
    {
      'id': 3,
      'name': 'Apple',
      'category': 'Grocery',
      'subCategory': 'Fruits',
      'image': 'C:\\Users\\Malith\\Documents/Untitled.png',
      'stockId': '2025-January-19',
      'itemCode': 'A6150',
      'itemprice': 60.0,
      'unit': 'item',
      'size': 1,
      'discount': 10.0,
      'totalprice': 540.0,
      'finalprice': 340.0,
      'finalpricereson': 'Additional Discount: Rs 200.00',
      'additional': '',
      'selectedQuantity': 10.0,
      'quantity': 60,
      'priceFormat': 'Rs',
      'warrantyStartDate': '',
      'warrantyEndDate': ''
    },
    {
      'id': 2,
      'name': 'Milk',
      'category': 'Grocery',
      'subCategory': 'Snacks',
      'image': 'C:\\Users\\Malith\\Documents/download (27).jpg',
      'stockId': '2025-January-18',
      'itemCode': 'M5868',
      'itemprice': 400.0,
      'unit': 'L',
      'size': 1,
      'discount': 0.0,
      'totalprice': 800.0,
      'finalprice': 800.0,
      'finalpricereson': '',
      'additional': 'white',
      'selectedQuantity': 2.0,
      'quantity': 500,
      'priceFormat': 'Rs',
      'warrantyStartDate': '',
      'warrantyEndDate': ''
    },
  ];

  Future<Uint8List> loadImageFromAsset(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List();
  }

  // Load the custom Unicode font
  Future<pw.Font> _loadCustomFont() async {
    final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
    final font = pw.Font.ttf(fontData);
    return font;
  }

  @override
  Widget build(BuildContext context) {
    double subtotal =
        cart.fold(0, (sum, item) => sum + (item['finalprice'] as double));
    double tax = subtotal * 0.1;
    double total = subtotal + tax;
    String priceFormat = cart[0]['priceFormat'];
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final pdf = pw.Document();
            // Load the custom font
            final customFont = await _loadCustomFont();
            final Uint8List imageBytes =
                await loadImageFromAsset('assets/images/posBillLogo.webp');
            final pw.ImageProvider pdfImage = pw.MemoryImage(imageBytes);
            // Set the page width to 58mm (converted to points)
            final pageWidth = 58 * 72 / 25.4; // 58mm in points

            // Set the page format with fixed width and dynamic height
            final pageFormat =
                PdfPageFormat(pageWidth, double.infinity); // auto fit height

            pdf.addPage(pw.Page(
              pageFormat: pageFormat,
              build: (pw.Context context) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    pw.Center(
                      child: pw.Column(
                        children: [
                          pw.Image(pdfImage, height: 70),
                          pw.Text('Store Name',
                              style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                  font: customFont)),
                          pw.SizedBox(height: 4),
                          pw.Text('123 Main Street, City, Country',
                              style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.normal,
                                  font: customFont)),
                          pw.Text('Contact: +123 456 7890',
                              style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.normal,
                                  font: customFont)),
                        ],
                      ),
                    ),

                    // Invoice Details
                    pw.Padding(
                      padding: pw.EdgeInsets.only(
                          left: 7,
                          right:
                              7), // Use EdgeInsets instead of EdgeInsetsDirectional
                      child: pw.Divider(color: PdfColor.fromHex('#E0E0E0')),
                    ),

                    pw.Padding(
                      padding: pw.EdgeInsets.only(
                          left: 7,
                          right:
                              7), // Use EdgeInsets instead of EdgeInsetsDirectional
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'DATE : 23/01/2025',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.normal,
                              font: customFont,
                            ),
                          ),
                          pw.Text(
                            'TIME : 11:12 AM',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.normal,
                              font: customFont,
                            ),
                          ),
                        ],
                      ),
                    ),

                    pw.Padding(
                      padding: pw.EdgeInsets.only(
                          left: 7,
                          right:
                              7), // Use EdgeInsets instead of EdgeInsetsDirectional
                      child: pw.Divider(color: PdfColor.fromHex('#E0E0E0')),
                    ),
                    pw.SizedBox(height: 0),
                    pw.Padding(
                      padding: pw.EdgeInsets.only(
                          left: 7,
                          right:
                              7), // Use EdgeInsets instead of EdgeInsetsDirectional
                      child: pw.Text(
                        'Invoice #12345',
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.normal,
                          font: customFont,
                        ),
                      ),
                    ),

                    pw.SizedBox(height: 0),
                    pw.Padding(
                      padding: pw.EdgeInsets.only(
                          left: 7,
                          right:
                              7), // Use EdgeInsets instead of EdgeInsetsDirectional
                      child: pw.Divider(color: PdfColor.fromHex('#E0E0E0')),
                    ),
                    // Item Details Table
                    pw.Padding(
                      padding: pw.EdgeInsets.only(
                          left: 7,
                          right:
                              7), // Use EdgeInsets instead of EdgeInsetsDirectional
                      child: pw.Table.fromTextArray(
                        border: pw.TableBorder.symmetric(),
                        headerStyle: pw.TextStyle(
                          fontSize: 7,
                          fontWeight: pw.FontWeight.bold,
                          font: customFont,
                        ),
                        columnWidths: {
                          0: pw.FlexColumnWidth(2),
                          1: pw.FlexColumnWidth(2),
                          2: pw.FlexColumnWidth(2),
                        },
                        data: [
                          // Header row with center alignment
                          [
                            pw.Align(
                              alignment: pw.Alignment.centerLeft,
                              child: pw.Text('Item',
                                  style: pw.TextStyle(
                                      fontSize: 7, font: customFont)),
                            ),
                            pw.Align(
                              alignment: pw.Alignment.center,
                              child: pw.Text('Qty',
                                  style: pw.TextStyle(
                                      fontSize: 7, font: customFont)),
                            ),
                            pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text('Total',
                                  style: pw.TextStyle(
                                      fontSize: 7, font: customFont)),
                            ),
                          ],
                          ...cart.map((item) => [
                                pw.Align(
                                  alignment: pw.Alignment
                                      .centerLeft, // Left-align 'Item'
                                  child: pw.Text(
                                    item['name'],
                                    style: pw.TextStyle(
                                        fontSize: 7, font: customFont),
                                  ),
                                ),
                                pw.Align(
                                  alignment:
                                      pw.Alignment.center, // Center-align 'Qty'
                                  child: pw.Text(
                                    '${item['selectedQuantity'].toInt()}',
                                    style: pw.TextStyle(
                                        fontSize: 7, font: customFont),
                                  ),
                                ),
                                pw.Align(
                                  alignment: pw.Alignment
                                      .centerRight, // Left-align 'Total'
                                  child: pw.Text(
                                    '${item['priceFormat']}${item['finalprice'].toStringAsFixed(2)}',
                                    style: pw.TextStyle(
                                        fontSize: 7, font: customFont),
                                  ),
                                ),
                              ]),
                        ],
                        cellStyle: pw.TextStyle(fontSize: 7, font: customFont),
                      ),
                    ),

                    // Total Section
                    pw.Padding(
                      padding: pw.EdgeInsets.only(
                          left: 7,
                          right:
                              7), // Use EdgeInsets instead of EdgeInsetsDirectional
                      child: pw.Divider(color: PdfColor.fromHex('#E0E0E0')),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.only(left: 5, right: 5),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Subtotal:',
                              style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.normal,
                                  font: customFont)),
                          pw.Text(
                              '${priceFormat} ${subtotal.toStringAsFixed(2)}',
                              style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.normal,
                                  font: customFont)),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 2),
                    pw.Padding(
                      padding: pw.EdgeInsets.only(left: 5, right: 5),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Tax (10%):',
                              style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.normal,
                                  font: customFont)),
                          pw.Text('${priceFormat} ${tax.toStringAsFixed(2)}',
                              style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.normal,
                                  font: customFont)),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 2),
                    pw.Padding(
                      padding: pw.EdgeInsets.only(left: 5, right: 5),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Total:',
                              style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold,
                                  font: customFont)),
                          pw.Text('${priceFormat} ${total.toStringAsFixed(2)}',
                              style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                                font: customFont,
                              )),
                        ],
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                          horizontal:
                              7.0), // Apply left and right padding to the entire column
                      child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Divider(color: PdfColor.fromHex('#E0E0E0')),
                            pw.Text('Discounted Items:',
                                style: pw.TextStyle(
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold,
                                    font: customFont)),
                            pw.SizedBox(height: 0),
                            ...cart
                                .where((item) =>
                                    item['discount'] > 0.0 ||
                                    (item['finalpricereson'] != null &&
                                        item['finalpricereson'].isNotEmpty))
                                .map(
                                  (item) => pw.Padding(
                                    padding:
                                        pw.EdgeInsets.symmetric(vertical: 4),
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Row(
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.spaceBetween,
                                          children: [
                                            pw.Text(
                                                '${item['name']} (${item['size']} ${item['unit']})',
                                                style: pw.TextStyle(
                                                    fontSize: 6,
                                                    fontWeight:
                                                        pw.FontWeight.normal,
                                                    font: customFont)),
                                            pw.Text(
                                                'Discount: Rs ${item['discount'].toStringAsFixed(2)}',
                                                style: pw.TextStyle(
                                                    fontSize: 6,
                                                    fontWeight:
                                                        pw.FontWeight.normal,
                                                    font: customFont,
                                                    color: PdfColor.fromHex(
                                                        '#4CAF50'))),
                                          ],
                                        ),
                                        if (item['finalpricereson'] != null &&
                                            item['finalpricereson'].isNotEmpty)
                                          pw.Padding(
                                            padding: pw.EdgeInsets.only(
                                                left: 8.0, top: 1.0),
                                            child: pw.Text(
                                                item['finalpricereson'],
                                                style: pw.TextStyle(
                                                    fontSize: 6,
                                                    fontStyle:
                                                        pw.FontStyle.italic,
                                                    color: PdfColor.fromHex(
                                                        '#9E9E9E'))),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                            pw.Divider(color: PdfColor.fromHex('#E0E0E0')),
                          ]),
                    ),
                    // Discounted Items Section

                    // Footer Section
                    pw.Center(
                      child: pw.Column(
                        children: [
                          pw.Text('Thank you for shopping with us!',
                              style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold,
                                  font: customFont)),
                          pw.Text('Visit us again at: www.store.com',
                              style:
                                  pw.TextStyle(fontSize: 7, font: customFont)),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 10),
                  ],
                );
              },
            ));

            final output = await getTemporaryDirectory();
            final file = File('${output.path}/invoice.pdf');
            await file.writeAsBytes(await pdf.save());

            // Open the PDF
            print('PDF saved at: ${file.path}');
          },
          child: Text('Generate PDF'),
        ),
      ),
    );
  }
}
