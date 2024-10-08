import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Import Material package for ElevatedButton
import '../common/color_extension.dart';

class IconItemSButton extends StatelessWidget {
  final String title;
  final String icon;
  final String value; // Change the type to String for button text
  final Function(String) didChange; // Update the function parameter type

  const IconItemSButton({
    super.key,
    required this.title,
    required this.icon,
    required this.didChange,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Image.asset(
            icon,
            width: 20,
            height: 20,
            color: TColor.gray20,
          ),
          const SizedBox(
            width: 15,
          ),
          Text(
            title,
            style: TextStyle(
              color: TColor.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          const SizedBox(
            width: 8,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFBBC05), // Firebase Yellow
                  Color(0xFFEA4335), // Firebase Red
                  Color(0xFF4285F4), // Firebase Blue
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8), // Adjust border radius
            ),
            child: ElevatedButton(
              onPressed: () => didChange(value), // Call didChange with value
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0, // Remove elevation
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Match border radius
                ),
              ),
              child: Text(
                value, // Display the value as button text
                style: TextStyle(color: TColor.white), // Text color
              ),
            ),
          ),
        ],
      ),
    );
  }
}
