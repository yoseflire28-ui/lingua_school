// ─────────────────────────────────────────────────────────────────────────────
// Lingua School — Custom Segmented Control Widget
// A themed segmented button group using brand colors.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class CustomSegmentedControl extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;

  const CustomSegmentedControl({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selColor   = selectedColor   ?? AppColors.darkForestGreen;
    final unselColor = unselectedColor ?? (isDark ? AppColors.darkTealGreen : AppColors.crispWhite);
    final selText    = selectedTextColor   ?? AppColors.crispWhite;
    final unselText  = unselectedTextColor ?? (isDark ? AppColors.mintGreen : AppColors.darkCharcoal);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: selColor, width: 1.5),
        borderRadius: BorderRadius.circular(10),
        color: unselColor,
      ),
      child: Row(
        children: List.generate(options.length, (index) {
          final isSelected = index == selectedIndex;
          final isFirst    = index == 0;
          final isLast     = index == options.length - 1;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: isSelected ? selColor : Colors.transparent,
                  borderRadius: BorderRadius.horizontal(
                    left:  isFirst ? const Radius.circular(8.5) : Radius.zero,
                    right: isLast  ? const Radius.circular(8.5) : Radius.zero,
                  ),
                ),
                child: Text(
                  options[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:      isSelected ? selText : unselText,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize:   13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
