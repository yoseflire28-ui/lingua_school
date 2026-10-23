// ─────────────────────────────────────────────────────────────────────────────
// Lingua School — Student List Tile Widget
// Renders a single numbered student row with payment badges, checkbox
// selection, and inline edit/delete actions.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/student_model.dart';

class StudentListTile extends StatelessWidget {
  final int       index;          // 1-based display number
  final Student   student;
  final bool      isSelected;
  final bool      isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const StudentListTile({
    super.key,
    required this.index,
    required this.student,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap:      onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // ── Index / Checkbox ──────────────────────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isSelectionMode
                    ? Checkbox(
                        key: const ValueKey('checkbox'),
                        value:    isSelected,
                        onChanged: (_) => onTap(),
                      )
                    : SizedBox(
                        key: const ValueKey('number'),
                        width: 64,
                        child: Text(
                          student.formattedId,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.vibrantGold : AppColors.darkForestGreen,
                            fontSize: 12,
                          ),
                        ),
                      ),
              ),

              // ── Avatar ────────────────────────────────────────────────────
              CircleAvatar(
                radius:          20,
                backgroundColor: isSelected
                    ? AppColors.vibrantGold
                    : (isDark ? AppColors.darkForestGreen : AppColors.mintGreen),
                child: Text(
                  student.firstName.isNotEmpty ? student.firstName[0].toUpperCase() : '?',
                  style: TextStyle(
                    color:      isSelected ? AppColors.darkCharcoal : AppColors.darkForestGreen,
                    fontWeight: FontWeight.w800,
                    fontSize:   15,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // ── Name & Section ────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        _SectionBadge(section: student.section),
                        const SizedBox(width: 6),
                        _PaymentDot(paid: student.firstMonthPaid,  label: 'M1'),
                        const SizedBox(width: 4),
                        _PaymentDot(paid: student.secondMonthPaid, label: 'M2'),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Action Buttons ────────────────────────────────────────────
              if (!isSelectionMode) ...[
                IconButton(
                  icon:    const Icon(Icons.edit_outlined, size: 20),
                  color:   AppColors.darkForestGreen,
                  tooltip: 'Edit',
                  onPressed: onEdit,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon:    const Icon(Icons.delete_outline, size: 20),
                  color:   AppColors.error,
                  tooltip: 'Delete',
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section Badge ─────────────────────────────────────────────────────────────
class _SectionBadge extends StatelessWidget {
  final String section;
  const _SectionBadge({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color:        AppColors.darkForestGreen.withAlpha(15),
        border:       Border.all(color: AppColors.darkForestGreen.withAlpha(80)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        section,
        style: const TextStyle(
          fontSize:   10,
          fontWeight: FontWeight.w600,
          color:      AppColors.darkTealGreen,
        ),
      ),
    );
  }
}

// ── Payment Indicator Dot ──────────────────────────────────────────────────────
class _PaymentDot extends StatelessWidget {
  final bool   paid;
  final String label;
  const _PaymentDot({required this.paid, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: paid ? AppColors.paidGreen : AppColors.brightOrange,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            fontSize:   9,
            color:      paid ? AppColors.paidGreen : AppColors.brightOrange,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
