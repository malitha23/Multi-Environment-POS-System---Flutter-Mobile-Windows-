import 'dart:io'; // Import dart:io for file handling
import 'package:flutter/material.dart';

class ImageDisplay extends StatelessWidget {
  final Map<String, dynamic> item; // Item containing image data

  ImageDisplay({required this.item});

  @override
  Widget build(BuildContext context) {
    // Set width and height for the image (You can adjust these values)
    double imageWidth =
        MediaQuery.of(context).size.width * 0.8; // 80% of screen width
    double imageHeight = 200.0; // Fixed height

    return GestureDetector(
      onTap: () {
        // When tapped, open the image in full-screen dialog
        _openFullScreenImage(context);
      },
      child: Container(
        width: imageWidth,
        height: imageHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.file(
            File(item[
                'image']), // Use FileImage to load the image from the file system
            fit: BoxFit.cover, // Ensure image covers the space
          ),
        ),
      ),
    );
  }

  // Function to open image in full-screen dialog
  void _openFullScreenImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () {
            // Close the dialog when tapped
            Navigator.pop(context);
          },
          child: Container(
            width: MediaQuery.of(context).size.width, // Full width
            height: MediaQuery.of(context).size.height, // Full height
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(
                    File(item['image'])), // Use FileImage for local files
                fit: BoxFit
                    .contain, // Ensure the image is contained within the space
              ),
            ),
          ),
        ),
      ),
    );
  }
}
