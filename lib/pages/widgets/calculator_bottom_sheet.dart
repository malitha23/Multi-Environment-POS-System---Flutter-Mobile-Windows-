import 'package:flutter/material.dart';
import 'package:shop_pos_system_app/constants/app_colors.dart';

class CalculatorBottomSheet extends StatefulWidget {
  final double totalPrice; // Accept totalPrice as a parameter
  final Function(double) onPriceSet;

  const CalculatorBottomSheet(
      {Key? key, required this.totalPrice, required this.onPriceSet})
      : super(key: key);

  @override
  _CalculatorBottomSheetState createState() => _CalculatorBottomSheetState();
}

class _CalculatorBottomSheetState extends State<CalculatorBottomSheet> {
  String _currentInput = ''; // Current input being processed
  String _previousInput = ''; // Previous input (for operations)
  String _operation = ''; // Current operation (+, -, *, /)
  bool _isResult = false; // Flag to determine if the result is displayed

  @override
  void initState() {
    super.initState();
    _currentInput = widget.totalPrice.toStringAsFixed(2);
  }

  // Function to handle button presses
  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _currentInput = '';
        _previousInput = '';
        _operation = '';
      } else if (value == '=') {
        // Evaluate the expression when '=' is pressed
        _evaluateExpression();
      } else if (value == '.' && !_currentInput.contains('.')) {
        // Add a decimal point if not already present
        _currentInput += value;
      } else if ('0123456789'.contains(value)) {
        // Add numbers to the current input
        if (_isResult) {
          _currentInput = value;
          _isResult = false;
        } else {
          _currentInput += value;
        }
      } else {
        // Handle operators (+, -, *, /)
        if (_operation.isEmpty) {
          _previousInput = _currentInput;
          _currentInput = '';
        }
        _operation = value;
      }
    });
  }

  // Function to evaluate the expression when '=' is pressed
  void _evaluateExpression() {
    double result = 0;

    // Handle the operation and calculate the result
    double num1 = double.parse(_previousInput);
    double num2 = double.parse(_currentInput);

    switch (_operation) {
      case '+':
        result = num1 + num2;
        break;
      case '-':
        result = num1 - num2;
        break;
      case '*':
        result = num1 * num2;
        break;
      case '/':
        result = num1 / num2;
        break;
      default:
        return;
    }

    // Update the display text and reset the current input
    _currentInput = result.toString();
    _operation = '';
    _isResult = true;
  }

  // Display for the calculator
  Widget _buildDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Show current input (most recent entry) on top
          Text(
            _currentInput.isEmpty
                ? '0' // Show '0' if input is empty
                : double.tryParse(_currentInput)?.toStringAsFixed(2) ??
                    'Invalid', // Convert to double and format
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
            textAlign: TextAlign.right,
          ),

          // Show the previous input + operation below
          Text(
            _previousInput.isEmpty
                ? ''
                : '$_previousInput $_operation', // Previous input and operation as plain text
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  // Grid of calculator buttons
  Widget _buildButtonGrid(BuildContext context) {
    List<String> buttonText = [
      '7',
      '8',
      '9',
      '/',
      '4',
      '5',
      '6',
      '*',
      '1',
      '2',
      '3',
      '-',
      '0',
      '.',
      '=',
      '+',
      'C'
    ];

    // Get the screen width to dynamically calculate button size
    double screenWidth = MediaQuery.of(context).size.width;

    // Determine the button size based on the screen width (smaller screen means smaller buttons)
    double buttonSize =
        screenWidth / 4 - 20; // Adjust for spacing between buttons

    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // 4 buttons in a row
          crossAxisSpacing: 10, // Spacing between buttons
          mainAxisSpacing: 10, // Spacing between buttons vertically
        ),
        itemCount: buttonText.length,
        itemBuilder: (context, index) {
          return _buildButton(buttonText[index], buttonSize);
        },
      ),
    );
  }

  // Updated _buildButton function to handle the new buttons
  Widget _buildButton(String text, double size) {
    return ElevatedButton(
      onPressed: () => _onButtonPressed(text),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(size, size), // Set button size dynamically
        backgroundColor: text == 'Save'
            ? Colors.green
            : text == 'Close'
                ? Colors.red
                : AppColors
                    .primaryColor, // Different colors for Save and Cancel
        padding: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // Calculate responsive font size based on screen width
  double _getFontSize(BuildContext context, double factor) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 360) {
      return 24 * factor; // Mobile
    } else if (screenWidth <= 720) {
      return 30 * factor; // Tablet
    } else {
      return 40 * factor; // Desktop
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 1100;
    bool isTablet = MediaQuery.of(context).size.width > 900 &&
        MediaQuery.of(context).size.width <= 1100;
    return Container(
      width: 390,
      height:
          MediaQuery.of(context).size.height, // Set height to half the screen
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDisplay(),
          const SizedBox(height: 20),
          _buildButtonGrid(context),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  final parsedValue = double.tryParse(_currentInput);

                  if (parsedValue != null) {
                    widget.onPriceSet(parsedValue);
                  } else {
                    // Handle the case where parsing fails (optional)
                    print('Invalid input, could not parse to double.');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors
                      .primaryColor, // Using successColor for Set Price button
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Set Price',
                    style: AppColors.buttonStyle, // Using buttonStyle for text
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the widget or screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.errorColor, // Using errorColor for Close button
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Close',
                    style: AppColors.buttonStyle, // Using buttonStyle for text
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          )
        ],
      ),
    );
  }
}
