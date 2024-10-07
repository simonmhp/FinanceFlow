import 'package:flutter/material.dart';
import '../common/color_extension.dart';

class RoundBudgetTextField extends StatelessWidget {
  final String title;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextAlign titleAlign;
  final bool obscureText;
  final Function(String)? onChanged; // Add onChanged parameter

  const RoundBudgetTextField({
    super.key,
    required this.title,
    this.titleAlign = TextAlign.left,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged, // Initialize onChanged in the constructor
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                textAlign: titleAlign,
                style: TextStyle(color: TColor.white, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 48,
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: TColor.gray60.withOpacity(0.05),
            border: Border.all(color: TColor.gray70),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                fillColor: Colors.amber,
              ),
              keyboardType: keyboardType,
              obscureText: obscureText,
              style: const TextStyle(color: Colors.white),
              onChanged: onChanged, // Pass the onChanged callback
            ),
          ),
        ),
      ],
    );
  }
}
