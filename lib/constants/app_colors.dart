import 'package:flutter/material.dart';

class AppColors {
  // Primary Color (Dark Blue for brand identity or main theme color)
  static const Color primaryColor = Color(0xFF003366); // Dark blue

  // Secondary Color (A lighter shade of blue or complementary color)
  static const Color secondaryColor =
      Color(0xFF4CAF50); // Green for a fresh contrast

  // Discount Color (A bright, noticeable red)
  static const Color discountColor =
      Color(0xFFE53935); // Red for highlighting offers

  // Background Color (Neutral light grey background for a clean look)
  static const Color backgroundColor =
      Color(0xFFF5F5F5); // Light grey background

  // Text Color (Dark grey for readability with good contrast against the background)
  static const Color textColor = Color(0xFF212121); // Dark grey/black text

  // Grey Text Color (Subtle, for secondary or less important text)
  static const Color greyTextColor =
      Color(0xFF757575); // Medium grey for subtitles

  // Button Text Color (White text on buttons for contrast)
  static const Color buttonTextColor = Colors.white;

  // Disabled Color (Muted grey for disabled elements)
  static const Color disabledColor =
      Color(0xFFB0BEC5); // Light grey for disabled

  // Text Styles for different UI components

  // Title Text Style (Used for headers, important text)
  static const TextStyle titleStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18,
    color: textColor,
  );

  // Subtitle Text Style (Used for smaller, secondary text)
  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 14,
    color: greyTextColor,
  );

  // Button Style (For buttons with white text on them)
  static const TextStyle buttonStyle = TextStyle(
    color: buttonTextColor,
    fontWeight: FontWeight.bold,
  );

  // Card Background Color (Neutral white background for cards)
  static const Color cardBackgroundColor = Color(0xFFFFFFFF); // White for cards

  // Highlight Color (A soft yellow to highlight important elements)
  static const Color highlightColor = Color(0xFFFFD700); // Gold-ish yellow

  // Success Color (Green to represent success or positive actions)
  static const Color successColor = Color(0xFF4CAF50); // Green color

  // Error Color (For errors or alerts)
  static const Color errorColor = Color(0xFFF44336); // Red color for errors
}
