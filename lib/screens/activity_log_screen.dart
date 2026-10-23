// ─────────────────────────────────────────────────────────────────────────────
// Lingua School — Activity Log Screen
// Shows chronological history of phone calls and bulk SMS interactions.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../models/activity_log_model.dart';
import '../providers/language_provider.dart';
import '../providers/student_provider.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  @override
  void initState() {
    super.initState();
    // Load logs when screen first appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().loadActivityLogs();
    });
  }

  Future<void> _confirmClearLogs(BuildContext context) async {
    final lang      = context.read<LanguageProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title:   Text(lang.t('clear_logs')),
        content: const Text('All activity logs will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:     Text(lang.t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:     TextButton.styleFrom(foregroundColor: AppColors.error),
            child:     Text(lang.t('clear_logs')),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<StudentProvider>().clearActivityLogs();
    }
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('MMM d, yyyy  h:mm a').format(dt);
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang     = context.watch<LanguageProvider>();
    final provider = context.watch<StudentProvider>();
    final logs     = provider.activityLogs;

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.t('activity_log')),
        actions: [
          if (logs.isNotEmpty)
            IconButton(
              icon:    const Icon(Icons.delete_sweep_outlined),
              tooltip: lang.t('clear_logs'),
              onPressed: () => _confirmClearLogs(context),
            ),
        ],
      ),
      body: logs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 72,
                      color: AppColors.darkForestGreen.withAlpha(80)),
                  const SizedBox(height: 16),
                  Text(lang.t('no_logs'),
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            )
          : ListView.separated(
              padding:       const EdgeInsets.symmetric(vertical: 8),
              itemCount:     logs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 2),
              itemBuilder:  (ctx, i) => _LogTile(
                log:       logs[i],
                formattedDate: _formatDate(logs[i].timestamp),
              ),
            ),
    );
  }
}

// ── Log Tile ──────────────────────────────────────────────────────────────────
class _LogTile extends StatelessWidget {
  final ActivityLog log;
  final String      formattedDate;
  const _LogTile({required this.log, required this.formattedDate});

  @override
  Widget build(BuildContext context) {
    final isCall   = log.actionType == 'CALL';
    final iconData = isCall ? Icons.call : Icons.sms;
    final color    = isCall ? AppColors.darkForestGreen : AppColors.brightOrange;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(20),
          child: Icon(iconData, color: color, size: 20),
        ),
        title: Text(
          log.studentNames,
          maxLines:  2,
          overflow:  TextOverflow.ellipsis,
          style:     Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              log.details,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style:    Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              formattedDate,
              style: TextStyle(
                fontSize: 11,
                color:    AppColors.vibrantGold,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color:        color.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border:       Border.all(color: color.withAlpha(80)),
          ),
          child: Text(
            log.actionType,
            style: TextStyle(
              color:      color,
              fontSize:   10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
