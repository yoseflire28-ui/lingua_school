// ─────────────────────────────────────────────────────────────────────────────
// Lingua School — Student Detail Screen
// Displays all student fields with a direct dialer tap on phone number.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_colors.dart';
import '../models/student_model.dart';
import '../providers/language_provider.dart';
import '../providers/student_provider.dart';
import 'add_edit_student_screen.dart';

class StudentDetailScreen extends StatelessWidget {
  final Student student;
  const StudentDetailScreen({super.key, required this.student});

  // ─── Launch native dialer ─────────────────────────────────────────────────
  Future<void> _launchDialer(BuildContext context, Student student) async {
    final uri = Uri.parse('tel:${student.phoneNumber}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      // Log the call interaction
      if (context.mounted) {
        await context.read<StudentProvider>().logCall(student);
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open dialer.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang   = context.watch<LanguageProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(student.fullName),
        actions: [
          IconButton(
            icon:    const Icon(Icons.edit_outlined),
            tooltip: lang.t('edit_student'),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => AddEditStudentScreen(student: student),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar Card ────────────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.darkForestGreen,
                    child: Text(
                      student.firstName.isNotEmpty
                          ? student.firstName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: AppColors.crispWhite,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    student.fullName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color:        AppColors.darkForestGreen.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                      border:       Border.all(color: AppColors.darkForestGreen.withAlpha(60)),
                    ),
                    child: Text(
                      student.section,
                      style: const TextStyle(
                        color:      AppColors.darkTealGreen,
                        fontWeight: FontWeight.w600,
                        fontSize:   13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Detail Fields ──────────────────────────────────────────────
            _DetailCard(
              children: [
                _DetailRow(
                  icon:  Icons.badge_outlined,
                  label: lang.t('student_id'),
                  value: student.formattedId,
                  valueColor: AppColors.brightOrange,
                ),
                _divider(isDark),
                _DetailRow(
                  icon:  Icons.person_outline,
                  label: lang.t('gender'),
                  value: student.gender,
                ),
                _divider(isDark),
                // Tappable phone number → native dialer
                InkWell(
                  onTap: () => _launchDialer(context, student),
                  child: _DetailRow(
                    icon:       Icons.phone_outlined,
                    label:      lang.t('phone_number'),
                    value:      student.phoneNumber,
                    valueColor: AppColors.darkForestGreen,
                    trailing:   const Icon(Icons.call, color: AppColors.darkForestGreen, size: 18),
                  ),
                ),
                _divider(isDark),
                if (student.age.isNotEmpty) ...[
                  _DetailRow(
                    icon:  Icons.cake_outlined,
                    label: 'Age',
                    value: student.age,
                  ),
                  _divider(isDark),
                ],
                if (student.grade.isNotEmpty) ...[
                  _DetailRow(
                    icon:  Icons.school_outlined,
                    label: 'Grade',
                    value: student.grade,
                  ),
                  _divider(isDark),
                ],
                if (student.academicYear.isNotEmpty) ...[
                  _DetailRow(
                    icon:  Icons.calendar_month_outlined,
                    label: 'Academic Year',
                    value: student.academicYear,
                  ),
                  _divider(isDark),
                ],
                if (student.schoolName.isNotEmpty) ...[
                  _DetailRow(
                    icon:  Icons.account_balance_outlined,
                    label: 'School Name',
                    value: student.schoolName,
                  ),
                  _divider(isDark),
                ],
                _DetailRow(
                  icon:  Icons.calendar_today_outlined,
                  label: 'Registration Date',
                  value: student.registrationDate,
                ),
                _divider(isDark),
                _DetailRow(
                  icon:  Icons.location_on_outlined,
                  label: lang.t('branch'),
                  value: student.branch,
                ),
                _divider(isDark),
                _DetailRow(
                  icon:  Icons.inventory_2_outlined,
                  label: lang.t('package'),
                  value: student.package,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Payment Status Card ────────────────────────────────────────
            _SectionHeader(title: lang.t('payment_status')),
            const SizedBox(height: 8),
            _DetailCard(
              children: [
                _PaymentRow(
                  label: lang.t('month_1'),
                  paid:  student.firstMonthPaid,
                  paidLabel:   lang.t('paid'),
                  unpaidLabel: lang.t('unpaid'),
                ),
                _divider(isDark),
                _PaymentRow(
                  label: lang.t('month_2'),
                  paid:  student.secondMonthPaid,
                  paidLabel:   lang.t('paid'),
                  unpaidLabel: lang.t('unpaid'),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _divider(bool isDark) => Divider(
        height: 1,
        thickness: 1,
        color: isDark
            ? AppColors.vibrantGold.withAlpha(40)
            : AppColors.divider,
      );
}

// ── Reusable detail card wrapper ────────────────────────────────────────────────
class _DetailCard extends StatelessWidget {
  final List<Widget> children;
  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(children: children),
      ),
    );
  }
}

// ── Single label-value row ────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final Color?   valueColor;
  final Widget?  trailing;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.darkForestGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

// ── Payment status row ─────────────────────────────────────────────────────────
class _PaymentRow extends StatelessWidget {
  final String label;
  final bool   paid;
  final String paidLabel;
  final String unpaidLabel;

  const _PaymentRow({
    required this.label,
    required this.paid,
    required this.paidLabel,
    required this.unpaidLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            paid ? Icons.check_circle : Icons.cancel_outlined,
            color: paid ? AppColors.paidGreen : AppColors.unpaidRed,
            size:  22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.titleMedium),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: paid
                  ? AppColors.paidGreen.withAlpha(20)
                  : AppColors.unpaidRed.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: paid ? AppColors.paidGreen : AppColors.unpaidRed,
              ),
            ),
            child: Text(
              paid ? paidLabel : unpaidLabel,
              style: TextStyle(
                color:      paid ? AppColors.paidGreen : AppColors.unpaidRed,
                fontWeight: FontWeight.w700,
                fontSize:   12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }
}
