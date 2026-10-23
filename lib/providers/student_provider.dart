// ─────────────────────────────────────────────────────────────────────────────
// Lingua School — Student Provider
// Manages student list, search, bulk selection, CRUD, activity logging,
// CSV backup/restore, and mock data generation.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../models/activity_log_model.dart';
import '../services/database_helper.dart';

enum StudentSortOption {
  name,
  date,
  branch,
  package,
  academicYear,
}

class StudentProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  // ─── State Fields ─────────────────────────────────────────────────────────
  List<Student>     _allStudents      = [];
  List<Student>     _filteredStudents = [];
  List<ActivityLog> _activityLogs     = [];
  final Set<int>    _selectedIds      = {};
  bool              _isSelectionMode  = false;
  bool              _isLoading        = false;
  String            _searchQuery      = '';
  StudentSortOption _currentSort      = StudentSortOption.name;

  // ─── Getters ──────────────────────────────────────────────────────────────
  List<Student>     get students       => _filteredStudents;
  List<ActivityLog> get activityLogs   => _activityLogs;
  Set<int>          get selectedIds    => _selectedIds;
  bool              get isSelectionMode => _isSelectionMode;
  bool              get isLoading      => _isLoading;
  int               get selectedCount  => _selectedIds.length;
  int               get totalCount     => _allStudents.length;
  String            get searchQuery    => _searchQuery;
  StudentSortOption get currentSort    => _currentSort;

  /// All students currently selected (for SMS bulk action).
  List<Student> get selectedStudents => _filteredStudents
      .where((s) => s.id != null && _selectedIds.contains(s.id))
      .toList();

  // ─── Data Loading ─────────────────────────────────────────────────────────

  Future<void> loadStudents() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allStudents = await _db.getAllStudents();
      _applyFilterAndSort();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadActivityLogs() async {
    _activityLogs = await _db.getAllActivityLogs();
    notifyListeners();
  }

  // ─── Sorting ──────────────────────────────────────────────────────────────

  void setSortBy(StudentSortOption option) {
    _currentSort = option;
    _applyFilterAndSort();
    notifyListeners();
  }

  // ─── Search ───────────────────────────────────────────────────────────────

  /// Runs a DB-level indexed search for queries; local filter for empty query.
  Future<void> search(String query) async {
    _searchQuery = query;
    if (query.trim().isEmpty) {
      _applyFilterAndSort();
      notifyListeners();
      return;
    }
    final rawResults = await _db.searchStudents(query.trim());
    _filteredStudents = _sortList(rawResults);
    notifyListeners();
  }

  /// In-memory filter & sort.
  void _applyFilterAndSort() {
    List<Student> result;
    if (_searchQuery.trim().isEmpty) {
      result = List.from(_allStudents);
    } else {
      final q = _searchQuery.toLowerCase();
      result = _allStudents.where((s) {
        return s.firstName.toLowerCase().contains(q) ||
               s.lastName.toLowerCase().contains(q)  ||
               s.phoneNumber.contains(q)             ||
               s.section.toLowerCase().contains(q)   ||
               s.branch.toLowerCase().contains(q)    ||
               s.package.toLowerCase().contains(q);
      }).toList();
    }
    _filteredStudents = _sortList(result);
  }

  List<Student> _sortList(List<Student> list) {
    final sorted = List<Student>.from(list);
    switch (_currentSort) {
      case StudentSortOption.name:
        sorted.sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
        break;
      case StudentSortOption.date:
        sorted.sort((a, b) => a.registrationDate.compareTo(b.registrationDate));
        break;
      case StudentSortOption.branch:
        sorted.sort((a, b) => a.branch.toLowerCase().compareTo(b.branch.toLowerCase()));
        break;
      case StudentSortOption.package:
        sorted.sort((a, b) => a.package.toLowerCase().compareTo(b.package.toLowerCase()));
        break;
      case StudentSortOption.academicYear:
        sorted.sort((a, b) => a.academicYear.toLowerCase().compareTo(b.academicYear.toLowerCase()));
        break;
    }
    return sorted;
  }

  // ─── CRUD ─────────────────────────────────────────────────────────────────

  Future<void> addStudent(Student student) async {
    await _db.insertStudent(student);
    await loadStudents();
  }

  Future<void> updateStudent(Student student) async {
    await _db.updateStudent(student);
    await loadStudents();
  }

  Future<void> deleteStudent(int id) async {
    await _db.deleteStudent(id);
    _selectedIds.remove(id);
    await loadStudents();
  }

  /// Bulk Deletion: Deletes ALL student records from SQLite
  Future<void> deleteAllStudents() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _db.deleteAllStudents();
      _selectedIds.clear();
      _isSelectionMode = false;
      await loadStudents();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Bulk Selection ───────────────────────────────────────────────────────

  void startSelection(int studentId) {
    _isSelectionMode = true;
    _selectedIds.add(studentId);
    notifyListeners();
  }

  void toggleSelection(int studentId) {
    if (_selectedIds.contains(studentId)) {
      _selectedIds.remove(studentId);
    } else {
      _selectedIds.add(studentId);
    }
    if (_selectedIds.isEmpty) _isSelectionMode = false;
    notifyListeners();
  }

  void selectAll() {
    _isSelectionMode = true;
    _selectedIds.addAll(
      _filteredStudents.where((s) => s.id != null).map((s) => s.id!),
    );
    notifyListeners();
  }

  void clearSelection() {
    _selectedIds.clear();
    _isSelectionMode = false;
    notifyListeners();
  }

  // ─── Activity Logging ─────────────────────────────────────────────────────

  Future<void> logCall(Student student) async {
    await _db.insertActivityLog(ActivityLog(
      actionType:   'CALL',
      studentNames: student.fullName,
      details:      'Called ${student.phoneNumber}',
      timestamp:    DateTime.now().toIso8601String(),
    ));
    await loadActivityLogs();
  }

  Future<void> logBulkSms(List<Student> students) async {
    final names  = students.map((s) => s.fullName).join(', ');
    final phones = students.map((s) => s.phoneNumber).join(', ');
    await _db.insertActivityLog(ActivityLog(
      actionType:   'SMS',
      studentNames: names,
      details:      'Bulk SMS sent to ${students.length} student(s): $phones',
      timestamp:    DateTime.now().toIso8601String(),
    ));
    await loadActivityLogs();
  }

  Future<void> clearActivityLogs() async {
    await _db.clearActivityLogs();
    _activityLogs = [];
    notifyListeners();
  }

  // ─── CSV Backup / Restore ─────────────────────────────────────────────────

  List<Student> get studentsForExport => _allStudents;

  Future<void> importStudents(List<Student> students) async {
    await _db.insertStudentsBatch(students);
    await loadStudents();
  }

  // ─── Mock Data Generator (1,000 Students with 13 Fields) ─────────────────

  Future<void> generateMockStudents() async {
    _isLoading = true;
    notifyListeners();

    const firstNames = [
      'Meklit', 'Tinsae', 'Bereket', 'Sara',    'Abel',
      'Hana',   'Dawit',  'Rahel',   'Yonas',   'Tigist',
      'Samuel', 'Eden',   'Natnael', 'Bethlehem','Kidus',
      'Liya',   'Mikias', 'Selam',   'Biruk',   'Abreham',
      'Aster',  'Kaleb',  'Ephrem',  'Feven',   'Sami',
    ];
    const lastNames = [
      'Abebe',   'Kebede',  'Girma',   'Haile',   'Tesfaye',
      'Bekele',  'Tadesse', 'Wolde',   'Alemu',   'Lemma',
      'Mengistu','Desta',   'Berhane', 'Solomon', 'Negash',
      'Tekeste', 'Mulat',   'Gebre',   'Seid',    'Teka',
      'Getachew','Kassa',   'Assefa',  'Worku',   'Fikru',
    ];
    const stages   = ['Stage 1', 'Stage 2', 'Stage 3', 'Stage 4'];
    const genders  = ['Male', 'Female'];
    const branches = ['Main Office', 'Kela', 'Naremo', 'Adebabayi'];
    const packages = [
      'Foundation', 'Standard', 'Premium', 'Regular',
      'VIP1', 'VIP2', 'VVIP', 'Other'
    ];
    const grades = ['Grade 9', 'Grade 10', 'Grade 11', 'Grade 12', 'Level 1', 'Level 2', 'Level 3', 'Level 4'];
    const years  = ['2016 E.C.', '2017 E.C.', '2018 E.C.'];
    const schools = ['United Vision', 'Lingua Main', 'Hilltop School', 'Future Hope', 'Global Academy'];

    final mock = List.generate(1000, (i) {
      final fn = firstNames[i % firstNames.length];
      final ln = lastNames[i % lastNames.length];
      final paymentMod = i % 4;
      bool fPaid = paymentMod == 0 || paymentMod == 2;
      bool sPaid = paymentMod == 1 || paymentMod == 2;

      // Ethiopian date generation formatted as DD/MM/YYYY
      final day = ((i % 28) + 1).toString().padLeft(2, '0');
      final month = ((i % 12) + 1).toString().padLeft(2, '0');
      final ethDate = '$day/$month/2018 E.C.';

      return Student(
        firstName:        fn,
        lastName:         ln,
        phoneNumber:      '+2519${(10000000 + i).toString().substring(1)}',
        gender:           genders[i % genders.length],
        section:          stages[i % stages.length],
        registrationDate: ethDate,
        branch:           branches[i % branches.length],
        package:          packages[i % packages.length],
        firstMonthPaid:   fPaid,
        secondMonthPaid:  sPaid,
        age:              (15 + (i % 21)).toString(),
        grade:            grades[i % grades.length],
        academicYear:     years[i % years.length],
        schoolName:       schools[i % schools.length],
      );
    });

    await _db.insertStudentsBatch(mock);
    await loadStudents();
    _isLoading = false;
    notifyListeners();
  }
}
