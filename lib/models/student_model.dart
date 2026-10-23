// ─────────────────────────────────────────────────────────────────────────────
// Lingua School — Student Model
// Encapsulates a student record with SQLite & CSV serialization.
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable model representing a single student record.
class Student {
  final int? id;
  final String firstName;
  final String lastName;
  final String phoneNumber;      // Always prefixed with +251
  final String gender;           // 'Male' or 'Female'
  final String section;          // 'Stage 1' | 'Stage 2' | 'Stage 3' | 'Stage 4'
  final String registrationDate; // Ethiopian Date DD/MM/YYYY or ISO8601 string
  final String branch;           // 'Main Office' | 'Kela' | 'Naremo' | 'Adebabayi'
  final String package;          // 'Foundation' | 'Standard' | 'Premium' | 'Regular' | 'VIP1' | 'VIP2' | 'VVIP' | 'Other'
  final bool firstMonthPaid;
  final bool secondMonthPaid;
  final String age;              // Numeric age as String
  final String grade;            // Grade / Class, e.g. "10th Grade"
  final String academicYear;     // Academic Year, e.g. "2018 E.C."
  final String schoolName;       // School Name

  const Student({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.gender,
    required this.section,
    required this.registrationDate,
    this.branch = 'Main Office',
    this.package = 'Foundation',
    this.firstMonthPaid = false,
    this.secondMonthPaid = false,
    this.age = '',
    this.grade = '',
    this.academicYear = '',
    this.schoolName = '',
  });

  /// Formatted student ID (e.g. LLS0001, LLS0025, LLS1000).
  String get formattedId {
    if (id == null) return 'LLS0000';
    return 'LLS${id.toString().padLeft(4, '0')}';
  }

  /// Full display name combining first and last name.
  String get fullName => '$firstName $lastName';

  // ─── SQLite Serialization ─────────────────────────────────────────────────

  /// Creates a [Student] from a SQLite row map.
  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id:               map['id'] as int?,
      firstName:        map['first_name'] as String,
      lastName:         map['last_name'] as String,
      phoneNumber:      map['phone_number'] as String,
      gender:           map['gender'] as String,
      section:          map['section'] as String,
      registrationDate: map['registration_date'] as String,
      branch:           (map['branch'] as String?) ?? 'Main Office',
      package:          (map['package'] as String?) ?? 'Foundation',
      firstMonthPaid:   (map['first_month_paid'] as int? ?? 0) == 1,
      secondMonthPaid:  (map['second_month_paid'] as int? ?? 0) == 1,
      age:              (map['age'] as String?) ?? '',
      grade:            (map['grade'] as String?) ?? '',
      academicYear:     (map['academic_year'] as String?) ?? '',
      schoolName:       (map['school_name'] as String?) ?? '',
    );
  }

  /// Converts this student to a SQLite row map (excludes null id).
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'first_name':        firstName,
      'last_name':         lastName,
      'phone_number':      phoneNumber,
      'gender':            gender,
      'section':           section,
      'registration_date': registrationDate,
      'branch':            branch,
      'package':           package,
      'first_month_paid':  firstMonthPaid  ? 1 : 0,
      'second_month_paid': secondMonthPaid ? 1 : 0,
      'age':               age,
      'grade':             grade,
      'academic_year':     academicYear,
      'school_name':       schoolName,
    };
  }

  // ─── CSV Serialization ────────────────────────────────────────────────────

  /// Ordered CSV column headers matching [toCsvRow].
  static List<String> get csvHeaders => const [
    'id', 'first_name', 'last_name', 'phone_number',
    'gender', 'section', 'registration_date',
    'branch', 'package', 'first_month_paid', 'second_month_paid',
    'age', 'grade', 'academic_year', 'school_name',
  ];

  /// Converts this student to an ordered list for CSV encoding.
  List<dynamic> toCsvRow() => [
    id ?? '',
    firstName,
    lastName,
    phoneNumber,
    gender,
    section,
    registrationDate,
    branch,
    package,
    firstMonthPaid  ? '1' : '0',
    secondMonthPaid ? '1' : '0',
    age,
    grade,
    academicYear,
    schoolName,
  ];

  /// Creates a [Student] from a CSV row map keyed by [csvHeaders].
  factory Student.fromCsvRow(Map<String, dynamic> row) {
    return Student(
      firstName:        _str(row['first_name']),
      lastName:         _str(row['last_name']),
      phoneNumber:      _str(row['phone_number']),
      gender:           _str(row['gender'], fallback: 'Male'),
      section:          _str(row['section'], fallback: 'Stage 1'),
      registrationDate: _str(row['registration_date'], fallback: DateTime.now().toIso8601String()),
      branch:           _str(row['branch'],   fallback: 'Main Office'),
      package:          _str(row['package'],  fallback: 'Foundation'),
      firstMonthPaid:   _str(row['first_month_paid'])  == '1',
      secondMonthPaid:  _str(row['second_month_paid']) == '1',
      age:              _str(row['age']),
      grade:            _str(row['grade']),
      academicYear:     _str(row['academic_year']),
      schoolName:       _str(row['school_name']),
    );
  }

  static String _str(dynamic v, {String fallback = ''}) =>
      (v?.toString() ?? fallback).trim();

  // ─── Mutation helper ──────────────────────────────────────────────────────

  Student copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? gender,
    String? section,
    String? registrationDate,
    String? branch,
    String? package,
    bool? firstMonthPaid,
    bool? secondMonthPaid,
    String? age,
    String? grade,
    String? academicYear,
    String? schoolName,
  }) {
    return Student(
      id:               id               ?? this.id,
      firstName:        firstName        ?? this.firstName,
      lastName:         lastName         ?? this.lastName,
      phoneNumber:      phoneNumber      ?? this.phoneNumber,
      gender:           gender           ?? this.gender,
      section:          section          ?? this.section,
      registrationDate: registrationDate ?? this.registrationDate,
      branch:           branch           ?? this.branch,
      package:          package          ?? this.package,
      firstMonthPaid:   firstMonthPaid   ?? this.firstMonthPaid,
      secondMonthPaid:  secondMonthPaid  ?? this.secondMonthPaid,
      age:              age              ?? this.age,
      grade:            grade            ?? this.grade,
      academicYear:     academicYear     ?? this.academicYear,
      schoolName:       schoolName       ?? this.schoolName,
    );
  }

  @override
  String toString() => 'Student($id, $fullName, $section)';
}
