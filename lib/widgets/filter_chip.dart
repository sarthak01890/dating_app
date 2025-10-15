import 'package:flutter/material.dart';

class FilterChipWidget extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback? onTap;

  const FilterChipWidget({
    super.key,
    required this.text,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Margin provides spacing *between* the chips
        margin: const EdgeInsets.only(right: 10.0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple.shade50 : Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
          border: isSelected ? Border.all(color: Colors.purple.shade700, width: 1.5) : null,
        ),
        // 👇 This is the Row at the location the error points to (line 17:16)
        child: Row(
          mainAxisSize: MainAxisSize.min, // ⬅️ Ensures the Row only takes the space needed by children
          children: [
            // Ensure icons and text have fixed spacing and no flexible widgets
            const Icon(Icons.tune, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.purple.shade700 : Colors.black87,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}