// ─────────────────────────────────────────────────────────────────────────────
// Lingua School — Home Screen
// Displays the student list with multi-field search, dynamic sorting popup menu,
// high-visibility bulk delete action, custom formatted student IDs (LLS0001),
// dialer, bulk SMS selection, and inline edit/delete row actions.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_colors.dart';
import '../models/student_model.dart';
import '../providers/language_provider.dart';
import '../providers/student_provider.dart';
import '../widgets/student_list_tile.dart';
import 'student_detail_screen.dart';
import 'add_edit_student_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<void> _launchSms(BuildContext context) async {
    final provider = context.read<StudentProvider>();
    final students = provider.selectedStudents;
    if (students.isEmpty) return;

    final numbers = students.map((s) => s.phoneNumber).join(',');
    final uri     = Uri.parse('sms:$numbers');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      await provider.logBulkSms(students);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open SMS app.')),
        );
      }
    }
    provider.clearSelection();
  }

  Future<void> _confirmDeleteSingle(BuildContext context, Student student) async {
    final lang = context.read<LanguageProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title:   Text(lang.t('confirm_delete')),
        content: Text(lang.t('delete_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:     Text(lang.t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:     TextButton.styleFrom(foregroundColor: AppColors.error),
            child:     Text(lang.t('delete')),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<StudentProvider>().deleteStudent(student.id!);
    }
  }

  /// Bulk Deletion of ALL Students with High-Visibility Confirmation Dialog
  Future<void> _confirmDeleteAllStudents(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
            SizedBox(width: 8),
            Text('Delete All Students', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete ALL student records? This action cannot be undone.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.crispWhite,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final provider = context.read<StudentProvider>();
      await provider.deleteAllStudents();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All student records have been deleted.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _openDetail(BuildContext context, Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StudentDetailScreen(student: student)),
    );
  }

  void _openEdit(BuildContext context, Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditStudentScreen(student: student)),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final lang     = context.watch<LanguageProvider>();
    final provider = context.watch<StudentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: provider.isSelectionMode
            ? Text('${provider.selectedCount} ${lang.t('selected')}')
            : Text(lang.t('app_name')),
        actions: provider.isSelectionMode
            ? [
                TextButton.icon(
                  icon:    const Icon(Icons.select_all, color: AppColors.vibrantGold),
                  label:   Text(lang.t('select_all'),
                      style: const TextStyle(color: AppColors.vibrantGold)),
                  onPressed: provider.selectAll,
                ),
                IconButton(
                  icon:    const Icon(Icons.close, color: AppColors.crispWhite),
                  onPressed: provider.clearSelection,
                  tooltip: lang.t('clear'),
                ),
              ]
            : [
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Center(
                    child: Text(
                      '${provider.totalCount} ${lang.t('students')}',
                      style: const TextStyle(color: AppColors.mintGreen, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                // ── Sorting Popup Menu ("Sort By") ─────────────────────────
                PopupMenuButton<StudentSortOption>(
                  icon: const Icon(Icons.sort_rounded, color: AppColors.vibrantGold),
                  tooltip: 'Sort By',
                  onSelected: (option) => provider.setSortBy(option),
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      enabled: false,
                      child: Text(
                        'Sort By',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkForestGreen),
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: StudentSortOption.name,
                      child: Row(
                        children: [
                          Icon(Icons.sort_by_alpha,
                              color: provider.currentSort == StudentSortOption.name ? AppColors.brightOrange : Colors.grey),
                          const SizedBox(width: 8),
                          Text('Name (A-Z)',
                              style: TextStyle(
                                fontWeight: provider.currentSort == StudentSortOption.name ? FontWeight.bold : FontWeight.normal,
                              )),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: StudentSortOption.date,
                      child: Row(
                        children: [
                          Icon(Icons.calendar_month,
                              color: provider.currentSort == StudentSortOption.date ? AppColors.brightOrange : Colors.grey),
                          const SizedBox(width: 8),
                          Text('Registration Date',
                              style: TextStyle(
                                fontWeight: provider.currentSort == StudentSortOption.date ? FontWeight.bold : FontWeight.normal,
                              )),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: StudentSortOption.branch,
                      child: Row(
                        children: [
                          Icon(Icons.location_on,
                              color: provider.currentSort == StudentSortOption.branch ? AppColors.brightOrange : Colors.grey),
                          const SizedBox(width: 8),
                          Text('Branch',
                              style: TextStyle(
                                fontWeight: provider.currentSort == StudentSortOption.branch ? FontWeight.bold : FontWeight.normal,
                              )),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: StudentSortOption.package,
                      child: Row(
                        children: [
                          Icon(Icons.inventory_2,
                              color: provider.currentSort == StudentSortOption.package ? AppColors.brightOrange : Colors.grey),
                          const SizedBox(width: 8),
                          Text('Package',
                              style: TextStyle(
                                fontWeight: provider.currentSort == StudentSortOption.package ? FontWeight.bold : FontWeight.normal,
                              )),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: StudentSortOption.academicYear,
                      child: Row(
                        children: [
                          Icon(Icons.school,
                              color: provider.currentSort == StudentSortOption.academicYear ? AppColors.brightOrange : Colors.grey),
                          const SizedBox(width: 8),
                          Text('Academic Year',
                              style: TextStyle(
                                fontWeight: provider.currentSort == StudentSortOption.academicYear ? FontWeight.bold : FontWeight.normal,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
                // ── 3-Dot Overflow Menu for Bulk Actions ────────────────────
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.crispWhite),
                  onSelected: (val) {
                    if (val == 'delete_all') {
                      _confirmDeleteAllStudents(context);
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'delete_all',
                      child: Row(
                        children: [
                          Icon(Icons.delete_forever, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Delete All Students', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged:  (q) => provider.search(q),
              style:       const TextStyle(color: AppColors.darkCharcoal, fontSize: 14),
              decoration: InputDecoration(
                hintText:      'Search name, phone, stage, branch, package…',
                hintStyle:     TextStyle(color: Colors.grey.shade500, fontSize: 13),
                prefixIcon:    const Icon(Icons.search, color: AppColors.darkForestGreen),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon:      const Icon(Icons.clear, color: AppColors.darkForestGreen),
                        onPressed: () {
                          _searchCtrl.clear();
                          provider.search('');
                        },
                      )
                    : null,
                filled:      true,
                fillColor:   AppColors.crispWhite,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:   BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),

      // ── Student List ─────────────────────────────────────────────────────
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.darkForestGreen))
          : provider.students.isEmpty
              ? _EmptyState(message: lang.t('no_students'))
              : RefreshIndicator(
                  color: AppColors.darkForestGreen,
                  onRefresh: provider.loadStudents,
                  child: ListView.builder(
                    padding:     const EdgeInsets.only(top: 6, bottom: 100),
                    itemCount:   provider.students.length,
                    itemBuilder: (ctx, i) {
                      final student = provider.students[i];
                      return StudentListTile(
                        index:          i + 1,
                        student:        student,
                        isSelected:     provider.selectedIds.contains(student.id),
                        isSelectionMode: provider.isSelectionMode,
                        onTap: () {
                          if (provider.isSelectionMode) {
                            provider.toggleSelection(student.id!);
                          } else {
                            _openDetail(context, student);
                          }
                        },
                        onLongPress: () => provider.startSelection(student.id!),
                        onEdit:      () => _openEdit(context, student),
                        onDelete:    () => _confirmDeleteSingle(context, student),
                      );
                    },
                  ),
                ),

      // ── Floating Action Button (SMS) ──────────────────────────────────────
      floatingActionButton: provider.isSelectionMode && provider.selectedCount > 0
          ? FloatingActionButton.extended(
              onPressed:  () => _launchSms(context),
              icon:        const Icon(Icons.sms),
              label:       Text('${lang.t('send_sms')} (${provider.selectedCount})'),
              backgroundColor: AppColors.brightOrange,
            )
          : FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditStudentScreen()),
              ).then((_) => provider.loadStudents()),
              tooltip: lang.t('add_student'),
              child:   const Icon(Icons.person_add),
            ),
    );
  }
}

// ── Empty State Widget ─────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 72,
              color: AppColors.darkForestGreen.withAlpha(100)),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
