// ─────────────────────────────────────────────────────────────────────────────
// Lingua School — Add / Edit Student Screen
// Production-ready implementation with 13 fields (Group A & Group B),
// strict validation, modal bottom sheets, Provider state management, and SQLite.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/ethiopian_date_picker.dart';
import '../models/student_model.dart';
import '../providers/language_provider.dart';
import '../providers/student_provider.dart';

class AddEditStudentScreen extends StatefulWidget {
  /// If [student] is provided, the form is in edit mode; otherwise add mode.
  final Student? student;
  const AddEditStudentScreen({super.key, this.student});

  @override
  State<AddEditStudentScreen> createState() => _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends State<AddEditStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── Group A: Direct Text Input Field Controllers ───────────────────────────
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _gradeCtrl;
  late TextEditingController _academicYearCtrl;
  late TextEditingController _schoolNameCtrl;

  // ── Group B: Navigation Arrow Selector State Variables ─────────────────────
  String _selectedGender        = 'Male';
  String _selectedStage         = 'Stage 1';
  String _selectedPaymentStatus = 'First Month Paid';
  String _selectedBranch        = 'Main Office';
  String _selectedPackage       = 'Foundation';
  String _selectedEthDate       = '';

  bool _isSaving = false;
  bool get _isEditMode => widget.student != null;

  @override
  void initState() {
    super.initState();
    final s = widget.student;

    // Direct Text Input Controllers
    _firstNameCtrl    = TextEditingController(text: s?.firstName ?? '');
    _lastNameCtrl     = TextEditingController(text: s?.lastName  ?? '');
    _phoneCtrl        = TextEditingController(text: s?.phoneNumber.isNotEmpty == true ? s!.phoneNumber : '+251');
    _ageCtrl          = TextEditingController(text: s?.age ?? '');
    _gradeCtrl        = TextEditingController(text: s?.grade ?? '');
    _academicYearCtrl = TextEditingController(text: s?.academicYear ?? '');
    _schoolNameCtrl   = TextEditingController(text: s?.schoolName ?? '');

    // Group B Selector initial values
    if (s != null) {
      _selectedGender  = s.gender.isNotEmpty ? s.gender : 'Male';
      _selectedStage   = s.section.isNotEmpty ? s.section : 'Stage 1';
      _selectedBranch  = s.branch.isNotEmpty ? s.branch : 'Main Office';
      _selectedPackage = s.package.isNotEmpty ? s.package : 'Foundation';

      if (s.firstMonthPaid && s.secondMonthPaid) {
        _selectedPaymentStatus = 'Both';
      } else if (s.secondMonthPaid) {
        _selectedPaymentStatus = 'Second Month Paid';
      } else {
        _selectedPaymentStatus = 'First Month Paid';
      }

      _selectedEthDate = s.registrationDate.isNotEmpty
          ? s.registrationDate
          : EthiopianDate.now().format();
    } else {
      _selectedEthDate = EthiopianDate.now().format();
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _ageCtrl.dispose();
    _gradeCtrl.dispose();
    _academicYearCtrl.dispose();
    _schoolNameCtrl.dispose();
    super.dispose();
  }

  // ─── Modal Bottom Sheet Generic Helper ────────────────────────────────────
  Future<void> _showModalOptionPicker({
    required String title,
    required List<String> options,
    required String currentValue,
    required ValueChanged<String> onSelected,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? AppColors.darkTealGreen : AppColors.crispWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modal Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.vibrantGold : AppColors.darkForestGreen,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Modal Options List
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final item = options[index];
                      final isSelected = item == currentValue;
                      return ListTile(
                        title: Text(
                          item,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? AppColors.brightOrange
                                : (isDark ? AppColors.crispWhite : AppColors.darkCharcoal),
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: AppColors.brightOrange)
                            : null,
                        onTap: () {
                          onSelected(item);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Ethiopian Date Picker Trigger ────────────────────────────────────────
  Future<void> _pickEthiopianDate() async {
    final initialDate = EthiopianDate.tryParse(_selectedEthDate);
    final picked = await showEthiopianDatePicker(
      context: context,
      initialDate: initialDate,
    );
    if (picked != null) {
      setState(() {
        _selectedEthDate = picked.format();
      });
    }
  }

  // ─── Save Student Logic & Validation ──────────────────────────────────────
  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final provider = context.read<StudentProvider>();
    final lang     = context.read<LanguageProvider>();

    // Determine booleans for payment status
    bool firstPaid  = _selectedPaymentStatus == 'First Month Paid' || _selectedPaymentStatus == 'Both';
    bool secondPaid = _selectedPaymentStatus == 'Second Month Paid' || _selectedPaymentStatus == 'Both';

    // Serialize all 13 fields into Map / Student object
    final studentDataMap = <String, dynamic>{
      if (widget.student?.id != null) 'id': widget.student!.id,
      'first_name':        _firstNameCtrl.text.trim(),
      'last_name':         _lastNameCtrl.text.trim(),
      'phone_number':      _phoneCtrl.text.trim(),
      'gender':            _selectedGender,
      'section':           _selectedStage,
      'registration_date': _selectedEthDate,
      'branch':            _selectedBranch,
      'package':           _selectedPackage,
      'first_month_paid':  firstPaid ? 1 : 0,
      'second_month_paid': secondPaid ? 1 : 0,
      'age':               _ageCtrl.text.trim(),
      'grade':             _gradeCtrl.text.trim(),
      'academic_year':     _academicYearCtrl.text.trim(),
      'school_name':       _schoolNameCtrl.text.trim(),
    };

    final student = Student.fromMap(studentDataMap);

    try {
      if (_isEditMode) {
        await provider.updateStudent(student);
      } else {
        await provider.addStudent(student);
      }

      if (mounted) {
        // Immediate snackbar feedback upon successful insertion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'Student updated successfully!' : 'Student saved successfully!'),
            backgroundColor: AppColors.darkForestGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Clear and navigate back to the home screen list
        if (_isEditMode) {
          Navigator.pop(context);
        } else {
          _resetForm();
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.t('error')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _firstNameCtrl.clear();
    _lastNameCtrl.clear();
    _phoneCtrl.text = '+251';
    _ageCtrl.clear();
    _gradeCtrl.clear();
    _academicYearCtrl.clear();
    _schoolNameCtrl.clear();
    setState(() {
      _selectedGender        = 'Male';
      _selectedStage         = 'Stage 1';
      _selectedPaymentStatus = 'First Month Paid';
      _selectedBranch        = 'Main Office';
      _selectedPackage       = 'Foundation';
      _selectedEthDate       = EthiopianDate.now().format();
    });
  }

  // ─── Field Validators ──────────────────────────────────────────────────────
  String? _requiredValidator(String? v, String fieldName) {
    if (v == null || v.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  String? _phoneValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone number is required';
    if (!v.startsWith('+251')) return 'Phone number must start with +251';
    if (v.trim().length < 10) return 'Please enter a valid phone number';
    return null;
  }

  // ─── Build Method ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCharcoal : AppColors.mintGreen,
      appBar: AppBar(
        backgroundColor: AppColors.darkForestGreen,
        foregroundColor: AppColors.crispWhite,
        title: Text(
          _isEditMode ? 'Edit Student' : 'Add New Student',
          style: const TextStyle(
            color: AppColors.crispWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ═══════════════════════════════════════════════════════════════
              // GROUP A: DIRECT TEXT INPUT FIELDS
              // ═══════════════════════════════════════════════════════════════
              _buildSectionHeader('Personal Information (Group A)'),
              const SizedBox(height: 12),

              // 1. First Name (Required)
              _buildTextField(
                controller: _firstNameCtrl,
                label: 'First Name *',
                hint: 'Enter first name',
                icon: Icons.person_outline,
                validator: (v) => _requiredValidator(v, 'First Name'),
              ),
              const SizedBox(height: 12),

              // 2. Last Name (Required)
              _buildTextField(
                controller: _lastNameCtrl,
                label: 'Last Name *',
                hint: 'Enter last name',
                icon: Icons.person_outline,
                validator: (v) => _requiredValidator(v, 'Last Name'),
              ),
              const SizedBox(height: 12),

              // 3. Phone Number (+251 prefix, Required)
              _buildTextField(
                controller: _phoneCtrl,
                label: 'Phone Number *',
                hint: '+2519XXXXXXXX',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: _phoneValidator,
              ),
              const SizedBox(height: 12),

              // 4. Age (Numeric keyboard)
              _buildTextField(
                controller: _ageCtrl,
                label: 'Age',
                hint: 'Enter age (e.g., 16)',
                icon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              // 5. Grade (replacing 'Student Class')
              _buildTextField(
                controller: _gradeCtrl,
                label: 'Grade',
                hint: 'e.g. 10th Grade or Level 2',
                icon: Icons.school_outlined,
              ),
              const SizedBox(height: 12),

              // 6. Academic Year (replacing 'School Year')
              _buildTextField(
                controller: _academicYearCtrl,
                label: 'Academic Year',
                hint: 'e.g. 2018 E.C. / 2026',
                icon: Icons.calendar_month_outlined,
              ),
              const SizedBox(height: 12),

              // 7. School Name
              _buildTextField(
                controller: _schoolNameCtrl,
                label: 'School Name',
                hint: 'Enter school name',
                icon: Icons.account_balance_outlined,
              ),
              const SizedBox(height: 24),

              // ═══════════════════════════════════════════════════════════════
              // GROUP B: NAVIGATION ARROW SELECTORS (>)
              // ═══════════════════════════════════════════════════════════════
              _buildSectionHeader('School Options & Selectors (Group B)'),
              const SizedBox(height: 12),

              // 1. Gender Picker (STRICTLY "Male" and "Female")
              _buildNavigationSelectorRow(
                label: 'Gender',
                value: _selectedGender,
                icon: Icons.male_outlined,
                onTap: () => _showModalOptionPicker(
                  title: 'Select Gender',
                  options: const ['Male', 'Female'],
                  currentValue: _selectedGender,
                  onSelected: (val) => setState(() => _selectedGender = val),
                ),
              ),
              const SizedBox(height: 10),

              // 2. Stage Picker
              _buildNavigationSelectorRow(
                label: 'Stage',
                value: _selectedStage,
                icon: Icons.auto_graph_outlined,
                onTap: () => _showModalOptionPicker(
                  title: 'Select Stage',
                  options: const ['Stage 1', 'Stage 2', 'Stage 3', 'Stage 4'],
                  currentValue: _selectedStage,
                  onSelected: (val) => setState(() => _selectedStage = val),
                ),
              ),
              const SizedBox(height: 10),

              // 3. Payment Status Picker
              _buildNavigationSelectorRow(
                label: 'Payment Status',
                value: _selectedPaymentStatus,
                icon: Icons.payments_outlined,
                onTap: () => _showModalOptionPicker(
                  title: 'Select Payment Status',
                  options: const ['First Month Paid', 'Second Month Paid', 'Both'],
                  currentValue: _selectedPaymentStatus,
                  onSelected: (val) => setState(() => _selectedPaymentStatus = val),
                ),
              ),
              const SizedBox(height: 10),

              // 4. Branch Picker
              _buildNavigationSelectorRow(
                label: 'Branch',
                value: _selectedBranch,
                icon: Icons.location_on_outlined,
                onTap: () => _showModalOptionPicker(
                  title: 'Select Branch',
                  options: const ['Main Office', 'Kela', 'Naremo', 'Adebabayi'],
                  currentValue: _selectedBranch,
                  onSelected: (val) => setState(() => _selectedBranch = val),
                ),
              ),
              const SizedBox(height: 10),

              // 5. Packages Picker
              _buildNavigationSelectorRow(
                label: 'Package',
                value: _selectedPackage,
                icon: Icons.card_membership_outlined,
                onTap: () => _showModalOptionPicker(
                  title: 'Select Package',
                  options: const [
                    'Foundation',
                    'Standard',
                    'Premium',
                    'Regular',
                    'VIP1',
                    'VIP2',
                    'VVIP',
                    'Other'
                  ],
                  currentValue: _selectedPackage,
                  onSelected: (val) => setState(() => _selectedPackage = val),
                ),
              ),
              const SizedBox(height: 10),

              // 6. Ethiopian Date Picker
              _buildNavigationSelectorRow(
                label: 'Registration Date (Ethiopian Calendar)',
                value: _selectedEthDate,
                icon: Icons.today_outlined,
                onTap: _pickEthiopianDate,
              ),

              const SizedBox(height: 32),

              // ═══════════════════════════════════════════════════════════════
              // MAIN ACTION BUTTON
              // ═══════════════════════════════════════════════════════════════
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.vibrantGold, // Vibrant Gold (#E1A712)
                    foregroundColor: AppColors.darkCharcoal, // Dark Charcoal (#1A1A1A)
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSaving ? null : _saveStudent,
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.darkCharcoal,
                          ),
                        )
                      : const Text(
                          'Save Student',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper: Section Title ──────────────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColors.darkTealGreen,
        letterSpacing: 0.2,
      ),
    );
  }

  // ── Helper: TextFormField (Crisp White surface, Rounded corners) ───────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppColors.darkCharcoal, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.crispWhite, // Crisp White surface
        prefixIcon: Icon(icon, color: AppColors.darkForestGreen, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.darkForestGreen.withAlpha(40), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkForestGreen, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }

  // ── Helper: Navigation Selector ListTile with Trailing Chevron (>) ──────────
  Widget _buildNavigationSelectorRow({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.crispWhite, // Crisp White surface
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkForestGreen.withAlpha(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
        leading: Icon(icon, color: AppColors.darkForestGreen, size: 22),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          value.isNotEmpty ? value : 'Tap to select',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.darkCharcoal,
          ),
        ),
        trailing: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Accent Dot
            Icon(Icons.circle, color: AppColors.brightOrange, size: 8),
            SizedBox(width: 6),
            // Trailing Chevron Navigation Icon (>)
            Icon(Icons.chevron_right, color: AppColors.darkForestGreen, size: 24),
          ],
        ),
      ),
    );
  }
}
