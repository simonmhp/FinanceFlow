import 'package:flutter/material.dart';
import '../common/color_extension.dart';

class RoundDropdown extends StatelessWidget {
  final String title;
  final String? selectedValue;
  final TextAlign titleAlign;
  final List<String> items;
  final ValueChanged<String?>? onChanged;

  const RoundDropdown({
    super.key,
    required this.title,
    this.titleAlign = TextAlign.center,
    required this.items,
    this.selectedValue,
    this.onChanged,
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
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              onChanged: onChanged,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      item,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }).toList(),
              dropdownColor: TColor.gray60,
              isExpanded: true,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "Select Category",
                  style: TextStyle(color: TColor.gray30),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
