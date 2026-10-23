// ─────────────────────────────────────────────────────────────────────────────
// Lingua School — Settings Screen
// Dark mode, language selector, CSV backup/restore, activity log, social links,
// 1,000 mock student generator, and About Us.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_colors.dart';
import '../providers/language_provider.dart';
import '../providers/student_provider.dart';
import '../providers/theme_provider.dart';
import '../services/csv_service.dart';
import 'activity_log_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open: $url')),
        );
      }
    }
  }

  Future<void> _exportCsv(BuildContext context) async {
    final lang     = context.read<LanguageProvider>();
    final provider = context.read<StudentProvider>();
    final path     = await CsvService.exportStudents(provider.studentsForExport);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            path != null ? lang.t('export_success') : lang.t('error'),
          ),
          backgroundColor:
              path != null ? AppColors.darkForestGreen : AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _importCsv(BuildContext context) async {
    final lang     = context.read<LanguageProvider>();
    final provider = context.read<StudentProvider>();
    final students = await CsvService.importStudents();
    if (context.mounted) {
      if (students == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:         Text(lang.t('import_failed')),
            backgroundColor: AppColors.error,
          ),
        );
      } else {
        await provider.importStudents(students);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:         Text('${lang.t('import_success')} (${students.length})'),
              backgroundColor: AppColors.darkForestGreen,
              behavior:        SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _generateMock(BuildContext context) async {
    final provider = context.read<StudentProvider>();
    await provider.generateMockStudents();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:         Text('Successfully generated 1,000 mock students with formatted IDs (LLS0001 - LLS1000)!'),
          backgroundColor: AppColors.darkForestGreen,
          behavior:        SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final lang = context.read<LanguageProvider>();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(lang.t('select_language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(
              label:      lang.t('english'),
              isSelected: lang.language == AppLanguage.english,
              onTap: () {
                ctx.read<LanguageProvider>().setLanguage(AppLanguage.english);
                Navigator.pop(ctx);
              },
            ),
            const Divider(height: 1),
            _LanguageOption(
              label:      lang.t('amharic'),
              isSelected: lang.language == AppLanguage.amharic,
              onTap: () {
                ctx.read<LanguageProvider>().setLanguage(AppLanguage.amharic);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final lang = context.read<LanguageProvider>();
    showAboutDialog(
      context:      context,
      applicationName:    'Lingua School',
      applicationVersion: '1.0.0',
      applicationIcon: const CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.darkForestGreen,
        child: Text('LS',
            style: TextStyle(color: AppColors.vibrantGold,
                fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      children: [
        const SizedBox(height: 8),
        Text(lang.t('about_text')),
      ],
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final lang     = context.watch<LanguageProvider>();
    final theme    = context.watch<ThemeProvider>();
    final provider = context.watch<StudentProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(lang.t('settings'))),
      body: ListView(
        children: [
          // ── Appearance ───────────────────────────────────────────────────
          _SectionHeader(title: 'Appearance'),

          SwitchListTile(
            value:    theme.isDarkMode,
            onChanged: (_) => context.read<ThemeProvider>().toggleDarkMode(),
            secondary: Icon(
              theme.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: theme.isDarkMode ? AppColors.vibrantGold : AppColors.darkForestGreen,
            ),
            title:    Text(lang.t('dark_mode')),
            subtitle: Text(theme.isDarkMode ? 'Dark' : 'Light'),
          ),

          const Divider(indent: 16, endIndent: 16),

          ListTile(
            leading: const Icon(Icons.language),
            title:   Text(lang.t('language')),
            subtitle: Text(lang.isAmharic ? lang.t('amharic') : lang.t('english')),
            trailing: const Icon(Icons.chevron_right),
            onTap:   () => _showLanguageDialog(context),
          ),

          const SizedBox(height: 8),

          // ── Activity & Notifications ──────────────────────────────────────
          _SectionHeader(title: lang.t('activity_log')),

          ListTile(
            leading: const Icon(Icons.history),
            title:   Text(lang.t('activity_log')),
            subtitle: Text('${provider.activityLogs.length} records'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ActivityLogScreen()),
            ).then((_) => provider.loadActivityLogs()),
          ),

          const SizedBox(height: 8),

          // ── Backup & Restore ──────────────────────────────────────────────
          _SectionHeader(title: lang.t('backup_restore')),

          ListTile(
            leading: const Icon(Icons.upload_file),
            title:   Text(lang.t('csv_export')),
            subtitle: Text('${provider.totalCount} ${lang.t('students')}'),
            onTap:   () => _exportCsv(context),
          ),

          ListTile(
            leading: const Icon(Icons.download_for_offline_outlined),
            title:   Text(lang.t('csv_import')),
            subtitle: const Text('Select a .csv backup file'),
            onTap:   () => _importCsv(context),
          ),

          const Divider(indent: 16, endIndent: 16),

          // ── Mock Data Generator (1,000 Mock Students) ─────────────────────
          ListTile(
            leading: const Icon(Icons.people_alt_outlined,
                color: AppColors.brightOrange),
            title: const Text(
              'Generate 1,000 Mock Students',
              style: TextStyle(color: AppColors.brightOrange, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Populates 1,000 test records with IDs LLS0001-LLS1000 across all 13 fields'),
            trailing: provider.isLoading
                ? const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: AppColors.brightOrange),
                  )
                : const Icon(Icons.bolt, color: AppColors.brightOrange),
            onTap: provider.isLoading ? null : () => _generateMock(context),
          ),

          const SizedBox(height: 8),

          // ── Help & Support ────────────────────────────────────────────────
          _SectionHeader(title: lang.t('help_support')),

          _SocialTile(
            label:    lang.t('telegram'),
            icon:     Icons.telegram,
            color:    const Color(0xFF0088CC),
            onTap:    () => _launchUrl(context, 'https://t.me/linguaschool'),
          ),
          _SocialTile(
            label:    lang.t('instagram'),
            icon:     Icons.camera_alt_outlined,
            color:    const Color(0xFFE1306C),
            onTap:    () => _launchUrl(context, 'https://instagram.com/linguaschool'),
          ),
          _SocialTile(
            label:    lang.t('facebook'),
            icon:     Icons.facebook,
            color:    const Color(0xFF1877F2),
            onTap:    () => _launchUrl(context, 'https://facebook.com/linguaschool'),
          ),
          _SocialTile(
            label:    lang.t('whatsapp'),
            icon:     Icons.chat_outlined,
            color:    const Color(0xFF25D366),
            onTap:    () => _launchUrl(context, 'https://wa.me/251000000000'),
          ),

          const SizedBox(height: 8),

          // ── About ─────────────────────────────────────────────────────────
          _SectionHeader(title: lang.t('about_us')),

          ListTile(
            leading: const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.darkForestGreen,
              child: Text('LS',
                  style: TextStyle(
                      color: AppColors.vibrantGold,
                      fontWeight: FontWeight.w800,
                      fontSize: 12)),
            ),
            title:   Text(lang.t('about_us')),
            subtitle: const Text('Lingua School v1.0.0'),
            trailing: const Icon(Icons.info_outline),
            onTap:   () => _showAboutDialog(context),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Section Header ─────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize:      11,
          fontWeight:    FontWeight.w700,
          color:         AppColors.darkForestGreen,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Social Media Tile ─────────────────────────────────────────────────────────
class _SocialTile extends StatelessWidget {
  final String   label;
  final IconData icon;
  final Color    color;
  final VoidCallback onTap;
  const _SocialTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: color.withAlpha(25),
        child: Icon(icon, color: color, size: 20),
      ),
      title:   Text(label),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap:   onTap,
    );
  }
}

// ── Language Option Row ────────────────────────────────────────────────────────
class _LanguageOption extends StatelessWidget {
  final String   label;
  final bool     isSelected;
  final VoidCallback onTap;
  const _LanguageOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
          color:      isSelected ? AppColors.darkForestGreen : null,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.darkForestGreen)
          : null,
      onTap: onTap,
    );
  }
}
