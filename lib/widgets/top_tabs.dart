import 'package:flutter/material.dart';

class TopSearchBar extends StatelessWidget {
  final TextEditingController? searchController;
  final Function(String)? onSearchSubmitted;
  final String hintText;
  final VoidCallback? onTap;

  const TopSearchBar({
    super.key,
    this.searchController,
    this.onSearchSubmitted,
    this.onTap,
    this.hintText = "Search for profiles...",
  });

  @override
  Widget build(BuildContext context) {
    // Define a subtle, consistent primary color for the design
    const Color primaryColor = Color(0xFF8A2BE2); // Primary Violet

    return Padding(
      // Standard padding for a clean look
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Container(
        // ⭐ THE ENHANCEMENT: CONTAINER STYLING ⭐
        decoration: BoxDecoration(
            color: Colors.white, // White background
            borderRadius: BorderRadius.circular(30.0), // Highly rounded corners
            boxShadow: [
              // Subtle elevation/shadow for a floating effect
              BoxShadow(
                color: primaryColor.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: primaryColor.withOpacity(0.2),
              width: 1.0,
            )
        ),
        // Use an InkWell or GestureDetector to make the whole bar tappable,
        // which is common if this bar is a "trigger" for a dedicated search screen.
        child: InkWell(
          onTap: onTap, // Handled in the parent widget
          borderRadius: BorderRadius.circular(30.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // 🔍 Search Icon: Fixed color



                // ✏️ Flexible Search Text Field
                Expanded(
                  // Use IgnorePointer if onTap is provided, as the whole InkWell will handle the tap.
                  child: IgnorePointer(
                    ignoring: onTap != null,
                    child: TextField(
                      controller: searchController,
                      onSubmitted: onSearchSubmitted,
                      // Ensure the content fits the vertical padding of the Container
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400, // Lighter hint text
                        ),
                        // Remove the default border
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14.0),

                        // Clear Button
                        suffixIcon: searchController != null && searchController!.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear, size: 20, color: Colors.grey),
                          onPressed: () {
                            searchController!.clear();
                            // Call setState in the parent if needed
                          },
                        )
                            : null,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.black87,
                      ),
                      cursorColor: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}