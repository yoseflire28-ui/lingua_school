// ─────────────────────────────────────────────────────────────────────────────
// Lingua School — Language Provider
// Supports English and Amharic (አማርኛ) UI translations via Provider.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

enum AppLanguage { english, amharic }

/// Provides UI string translations in English and Amharic.
class LanguageProvider extends ChangeNotifier {
  AppLanguage _language = AppLanguage.english;

  AppLanguage get language => _language;
  bool get isAmharic => _language == AppLanguage.amharic;

  /// Switches the active language and notifies UI listeners.
  void setLanguage(AppLanguage lang) {
    if (_language != lang) {
      _language = lang;
      notifyListeners();
    }
  }

  /// Returns the translated string for [key], falling back to English.
  String t(String key) {
    return _translations[_language]?[key]
        ?? _translations[AppLanguage.english]?[key]
        ?? key;
  }

  // ─── Translation Tables ───────────────────────────────────────────────────

  static const Map<AppLanguage, Map<String, String>> _translations = {
    // ── English ──────────────────────────────────────────────────────────────
    AppLanguage.english: {
      'app_name':          'Lingua School',
      'students':          'Students',
      'add_student':       'Add Student',
      'edit_student':      'Edit Student',
      'settings':          'Settings',
      'search_hint':       'Search by name, phone, section…',
      'first_name':        'First Name',
      'last_name':         'Last Name',
      'phone_number':      'Phone Number',
      'gender':            'Gender',
      'section':           'Section',
      'male_section':      'Male Section',
      'female_section':    'Female Section',
      'payment_status':    'Payment Status',
      'first_month_paid':  'First Month Paid',
      'second_month_paid': 'Second Month Paid',
      'both_paid':         'Both Paid',
      'save':              'Save',
      'cancel':            'Cancel',
      'delete':            'Delete',
      'confirm_delete':    'Confirm Delete',
      'delete_msg':        'Are you sure you want to delete this student?',
      'send_sms':          'Send SMS',
      'select_all':        'Select All',
      'clear':             'Clear',
      'dark_mode':         'Dark Mode',
      'language':          'Language',
      'activity_log':      'Activity Log',
      'csv_export':        'Export CSV Backup',
      'csv_import':        'Import CSV Backup',
      'help_support':      'Help & Support',
      'about_us':          'About Us',
      'backup_restore':    'Backup & Restore',
      'generate_mock':     'Generate 1,000 Mock Students',
      'student_id':        'Student ID',
      'reg_date':          'Registration Date',
      'branch':            'Branch',
      'package':           'Package',
      'paid':              'Paid',
      'unpaid':            'Unpaid',
      'month_1':           'Month 1',
      'month_2':           'Month 2',
      'no_students':       'No students found.',
      'no_logs':           'No activity logged yet.',
      'selected':          'selected',
      'clear_logs':        'Clear Logs',
      'seed_success':      '1,000 mock students generated.',
      'export_success':    'Backup exported successfully.',
      'import_success':    'Students imported successfully.',
      'import_failed':     'Import failed. Please check the CSV file.',
      'error':             'Error',
      'try_again':         'Please try again.',
      'stage_1':           'Stage 1',
      'stage_2':           'Stage 2',
      'stage_3':           'Stage 3',
      'stage_4':           'Stage 4',
      'about_text':
          'Lingua School is a modern student management platform for language schools. '
          'Manage students, track payments, and communicate efficiently.',
      'telegram':          'Telegram',
      'instagram':         'Instagram',
      'facebook':          'Facebook',
      'whatsapp':          'WhatsApp',
      'contact_us':        'Contact Us',
      'english':           'English',
      'amharic':           'አማርኛ (Amharic)',
      'select_language':   'Select Language',
      'call_logged':       'Called',
      'sms_logged':        'Bulk SMS sent to',
    },

    // ── Amharic ───────────────────────────────────────────────────────────────
    AppLanguage.amharic: {
      'app_name':          'ሊንጓ ስኩል',
      'students':          'ተማሪዎች',
      'add_student':       'ተማሪ ጨምር',
      'edit_student':      'ተማሪ አስተካክል',
      'settings':          'ቅንብሮች',
      'search_hint':       'በስም፣ ስልክ፣ ደረጃ ፈልግ…',
      'first_name':        'ስም',
      'last_name':         'የአባት ስም',
      'phone_number':      'ስልክ ቁጥር',
      'gender':            'ፆታ',
      'section':           'ክፍል',
      'male_section':      'የወንዶች ክፍል',
      'female_section':    'የሴቶች ክፍል',
      'payment_status':    'የክፍያ ሁኔታ',
      'first_month_paid':  'የ1ኛ ወር ክፍያ',
      'second_month_paid': 'የ2ኛ ወር ክፍያ',
      'both_paid':         'ሁለቱም ተከፍሏል',
      'save':              'አስቀምጥ',
      'cancel':            'ሰርዝ',
      'delete':            'አጥፋ',
      'confirm_delete':    'ማጥፋቱን አረጋግጥ',
      'delete_msg':        'ይህን ተማሪ መሰረዝ ይፈልጋሉ?',
      'send_sms':          'SMS ላክ',
      'select_all':        'ሁሉንም ምረጥ',
      'clear':             'አጽዳ',
      'dark_mode':         'ጨለማ ሁኔታ',
      'language':          'ቋንቋ',
      'activity_log':      'የተግባር ምዝግብ ማስታወሻ',
      'csv_export':        'CSV ምትኬ ወደ ውጭ ላክ',
      'csv_import':        'CSV ምትኬ አስገባ',
      'help_support':      'እርዳታ እና ድጋፍ',
      'about_us':          'ስለ እኛ',
      'backup_restore':    'ምትኬ እና ወደ ነበረበት ቀልብስ',
      'generate_mock':     '1,000 ናሙና ተማሪዎች ፍጠር',
      'student_id':        'ተማሪ መለያ',
      'reg_date':          'የምዝገባ ቀን',
      'branch':            'ቅርንጫፍ',
      'package':           'ፓኬጅ',
      'paid':              'ተከፍሏል',
      'unpaid':            'አልተከፈለም',
      'month_1':           '1ኛ ወር',
      'month_2':           '2ኛ ወር',
      'no_students':       'ምንም ተማሪ አልተገኘም።',
      'no_logs':           'ምንም ምዝገባ የለም።',
      'selected':          'ተመርጧል',
      'clear_logs':        'ምዝግብ አጽዳ',
      'seed_success':      '1,000 ናሙና ተማሪዎች ተፈጥረዋል።',
      'export_success':    'ምትኬ ተልኳል።',
      'import_success':    'ተማሪዎች ገብተዋል።',
      'import_failed':     'ማምጣቱ አልተሳካም። CSV ፋይሉን ያረጋግጡ።',
      'error':             'ስህተት',
      'try_again':         'እባክዎ እንደገና ይሞክሩ።',
      'stage_1':           'ደረጃ 1',
      'stage_2':           'ደረጃ 2',
      'stage_3':           'ደረጃ 3',
      'stage_4':           'ደረጃ 4',
      'about_text':
          'ሊንጓ ስኩል የቋንቋ ትምህርት ቤቶች ዘመናዊ የተማሪ አስተዳደር መድረክ ነው። '
          'ተማሪዎችን ያስተዳድሩ፣ ክፍያዎችን ይከታተሉ እና ቀልጣፋ ግንኙነት ያድርጉ።',
      'telegram':          'ቴሌግራም',
      'instagram':         'ኢንስታግራም',
      'facebook':          'ፌስቡክ',
      'whatsapp':          'ዋትስአፕ',
      'contact_us':        'ያግኙን',
      'english':           'English',
      'amharic':           'አማርኛ',
      'select_language':   'ቋንቋ ምረጥ',
      'call_logged':       'ደውሏል',
      'sms_logged':        'ቡልክ SMS ለ',
    },
  };
}
