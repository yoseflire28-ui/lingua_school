// ─────────────────────────────────────────────────────────────────────────────
// Lingua School — CSV Service
// Handles CSV export (share sheet) and CSV import (file picker) for students.
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/student_model.dart';

/// Static utility class for student CSV backup and restore operations.
abstract final class CsvService {
  // ─── Export ───────────────────────────────────────────────────────────────

  /// Converts [students] to CSV, saves to the documents directory,
  /// and opens the native share sheet so the user can save/send the file.
  ///
  /// Returns the file path on success, or null on failure.
  static Future<String?> exportStudents(List<Student> students) async {
    try {
      // Build CSV rows: header + data
      final rows = <List<dynamic>>[Student.csvHeaders];
      for (final s in students) {
        rows.add(s.toCsvRow());
      }
      final csvString = const ListToCsvConverter().convert(rows);

      // Write to a timestamped file in the app documents directory
      final dir       = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file      = File('${dir.path}/lingua_school_backup_$timestamp.csv');
      await file.writeAsString(csvString);

      // Share via the native OS share sheet (allows Save to Files, email, etc.)
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        subject: 'Lingua School Student Backup',
        text:    'Lingua School — ${students.length} student records exported.',
      );

      return file.path;
    } catch (_) {
      return null;
    }
  }

  // ─── Import ───────────────────────────────────────────────────────────────

  /// Opens the system file picker limited to CSV files, parses the selected
  /// file, and returns a list of [Student] objects.
  ///
  /// Returns null if the user cancels, or if parsing fails.
  static Future<List<Student>?> importStudents() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type:              FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple:     false,
      );
      if (result == null || result.files.isEmpty) return null;

      final path = result.files.single.path;
      if (path == null) return null;

      final content = await File(path).readAsString();

      // Support both \r\n (Windows) and \n (Unix) line endings
      final rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
          .convert(content.replaceAll('\r\n', '\n'));

      if (rows.isEmpty) return [];

      // First row is the header
      final headers = rows.first.map((e) => e.toString().trim()).toList();
      final students = <Student>[];

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty) continue;

        // Build a map of header -> cell value for safe parsing
        final map = <String, dynamic>{};
        for (int j = 0; j < headers.length && j < row.length; j++) {
          map[headers[j]] = row[j];
        }
        students.add(Student.fromCsvRow(map));
      }

      return students;
    } catch (_) {
      return null;
    }
  }
}
