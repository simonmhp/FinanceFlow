import 'package:flutter/material.dart';
import '../common/color_extension.dart';

class HomeIncomeList extends StatelessWidget {
  final Map sObj;
  final VoidCallback onPressed;

  const HomeIncomeList(
      {super.key, required this.sObj, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    // Get current date in dd format
    String formattedDate = sObj['date'].substring(8, 10);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Container(
          height: 64,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              color: TColor.border.withOpacity(0.15),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Row(
            children: [
              // Replacing icon with date in 'dd' format
              Text(
                formattedDate,
                style: TextStyle(
                  color: TColor.secondaryG,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Text(
                  sObj["name"],
                  style: TextStyle(
                      color: TColor.secondaryG,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                "${sObj["price"]}",
                style: TextStyle(
                    color: Colors.green.shade200,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
