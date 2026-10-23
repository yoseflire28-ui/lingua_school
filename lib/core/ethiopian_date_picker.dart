// ─────────────────────────────────────────────────────────────────────────────
// Lingua School — Ethiopian Date Picker Utility
// Computes and builds Ethiopian Calendar dates and custom modal dialog.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// Simple Ethiopian Date representation (Year, Month 1-13, Day 1-30).
class EthiopianDate {
  final int year;
  final int month;
  final int day;

  const EthiopianDate({
    required this.year,
    required this.month,
    required this.day,
  });

  /// Format as DD/MM/YYYY
  String format() {
    final d = day.toString().padLeft(2, '0');
    final m = month.toString().padLeft(2, '0');
    return '$d/$m/$year';
  }

  /// Ethiopian Month names in Amharic & English
  static const List<String> monthNamesEn = [
    'Meskerem', 'Tikimt', 'Hidar', 'Tahsas', 'Tir', 'Yakatit',
    'Magabit', 'Miyazya', 'Genbot', 'Sene', 'Hamle', 'Nehase', 'Pagume'
  ];

  static const List<String> monthNamesAm = [
    'መስከረም', 'ጥቅምት', 'ህዳር', 'ታህሳስ', 'ጥር', 'የካቲት',
    'መጋቢት', 'ሚያዝያ', 'ግንቦት', 'ሰኔ', 'ሐምሌ', 'ነሐሴ', 'ጳጉሜ'
  ];

  String get monthName => monthNamesEn[(month - 1).clamp(0, 12)];

  /// Converts a standard Gregorian DateTime to Ethiopian Date.
  factory EthiopianDate.fromGregorian(DateTime date) {
    int year = date.year;

    // Ethiopian New Year is Sep 11 (or Sep 12 in leap year before Ethiopian leap year)
    int ethYear = year - 8;
    bool isGregorianLeap = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
    int newYearDay = isGregorianLeap ? 12 : 11;

    DateTime ethNewYear = DateTime(year, 9, newYearDay);

    if (date.isBefore(ethNewYear)) {
      ethYear = year - 8;
      DateTime prevEthNewYear = DateTime(year - 1, 9, ((year - 1) % 4 == 3) ? 12 : 11);
      int diffDays = date.difference(prevEthNewYear).inDays;
      int ethMonth = (diffDays ~/ 30) + 1;
      int ethDay = (diffDays % 30) + 1;
      return EthiopianDate(year: ethYear, month: ethMonth, day: ethDay);
    } else {
      ethYear = year - 7;
      int diffDays = date.difference(ethNewYear).inDays;
      int ethMonth = (diffDays ~/ 30) + 1;
      int ethDay = (diffDays % 30) + 1;
      return EthiopianDate(year: ethYear, month: ethMonth, day: ethDay);
    }
  }

  /// Today's Ethiopian Date
  factory EthiopianDate.now() => EthiopianDate.fromGregorian(DateTime.now());

  /// Helper to parse DD/MM/YYYY
  static EthiopianDate? tryParse(String val) {
    final parts = val.split('/');
    if (parts.length == 3) {
      final d = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final y = int.tryParse(parts[2]);
      if (d != null && m != null && y != null) {
        return EthiopianDate(year: y, month: m, day: d);
      }
    }
    return null;
  }
}

/// Ethiopian Date Picker Modal Dialog
Future<EthiopianDate?> showEthiopianDatePicker({
  required BuildContext context,
  EthiopianDate? initialDate,
}) {
  final initial = initialDate ?? EthiopianDate.now();
  int selectedYear = initial.year;
  int selectedMonth = initial.month;
  int selectedDay = initial.day;

  return showDialog<EthiopianDate>(
    context: context,
    builder: (BuildContext ctx) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final maxDays = (selectedMonth == 13) ? ((selectedYear % 4 == 3) ? 6 : 5) : 30;
          if (selectedDay > maxDays) selectedDay = maxDays;

          return AlertDialog(
            backgroundColor: isDark ? AppColors.darkTealGreen : AppColors.crispWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Column(
              children: [
                Text(
                  'Ethiopian Calendar',
                  style: TextStyle(
                    color: isDark ? AppColors.vibrantGold : AppColors.darkForestGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${selectedDay.toString().padLeft(2, '0')}/${selectedMonth.toString().padLeft(2, '0')}/$selectedYear E.C.',
                  style: TextStyle(
                    color: AppColors.brightOrange,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                // Month selector
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Month:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.crispWhite : AppColors.darkCharcoal,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: DropdownButton<int>(
                        value: selectedMonth,
                        isExpanded: true,
                        dropdownColor: isDark ? AppColors.darkForestGreen : AppColors.crispWhite,
                        items: List.generate(13, (i) {
                          final m = i + 1;
                          final name = EthiopianDate.monthNamesEn[i];
                          return DropdownMenuItem<int>(
                            value: m,
                            child: Text('$m - $name', style: const TextStyle(fontSize: 14)),
                          );
                        }),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              selectedMonth = val;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Day Selector
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Day (1-$maxDays):',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.crispWhite : AppColors.darkCharcoal,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: DropdownButton<int>(
                        value: selectedDay,
                        isExpanded: true,
                        dropdownColor: isDark ? AppColors.darkForestGreen : AppColors.crispWhite,
                        items: List.generate(maxDays, (i) {
                          final d = i + 1;
                          return DropdownMenuItem<int>(
                            value: d,
                            child: Text(d.toString().padLeft(2, '0')),
                          );
                        }),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => selectedDay = val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Year Selector
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Year (E.C.):',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.crispWhite : AppColors.darkCharcoal,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: DropdownButton<int>(
                        value: selectedYear,
                        isExpanded: true,
                        dropdownColor: isDark ? AppColors.darkForestGreen : AppColors.crispWhite,
                        items: List.generate(20, (i) {
                          final y = 2010 + i;
                          return DropdownMenuItem<int>(
                            value: y,
                            child: Text('$y E.C.'),
                          );
                        }),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => selectedYear = val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, null),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.vibrantGold,
                  foregroundColor: AppColors.darkCharcoal,
                  minimumSize: const Size(100, 40),
                ),
                onPressed: () {
                  Navigator.pop(
                    ctx,
                    EthiopianDate(
                      year: selectedYear,
                      month: selectedMonth,
                      day: selectedDay,
                    ),
                  );
                },
                child: const Text('Select'),
              ),
            ],
          );
        },
      );
    },
  );
}
