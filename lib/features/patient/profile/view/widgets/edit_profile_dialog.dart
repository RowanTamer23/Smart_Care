import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_care/features/patient/profile/cubit/patient_profile_cubit.dart';
import 'package:smart_care/features/patient/profile/data/model/patient_profile_model.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_styles.dart';

class EditProfileDialog extends StatefulWidget {
  final PatientProfile profile;
  const EditProfileDialog({super.key, required this.profile});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _emergencyNameController;
  late final TextEditingController _emergencyPhoneController;
  late final TextEditingController _insuranceCompanyController;
  late final TextEditingController _insuranceNumberController;
  late final TextEditingController _allergiesController;
  late final TextEditingController _chronicDiseasesController;

  DateTime? _selectedDob;
  PatientGender? _selectedGender;
  BloodType? _selectedBloodType;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.profile.fullName ?? '');
    _addressController =
        TextEditingController(text: widget.profile.address ?? '');
    _emergencyNameController =
        TextEditingController(text: widget.profile.emergencyContactName ?? '');
    _emergencyPhoneController =
        TextEditingController(text: widget.profile.emergencyContact ?? '');
    _insuranceCompanyController =
        TextEditingController(text: widget.profile.insuranceCompany ?? '');
    _insuranceNumberController =
        TextEditingController(text: widget.profile.insuranceNumber ?? '');
    _allergiesController =
        TextEditingController(text: widget.profile.allergies.join(', '));
    _chronicDiseasesController =
        TextEditingController(text: widget.profile.chronicDiseases.join(', '));
    _selectedDob = widget.profile.dateOfBirth;
    _selectedGender = widget.profile.gender;
    _selectedBloodType = widget.profile.bloodType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _insuranceCompanyController.dispose();
    _insuranceNumberController.dispose();
    _allergiesController.dispose();
    _chronicDiseasesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: C.teal, size: 20),
      labelStyle: const TextStyle(color: C.txt2, fontSize: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: C.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: C.teal, width: 2),
      ),
      filled: true,
      fillColor: C.bg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Profile Info', style: hTextStyle(18, c: C.primary)),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration:
                            _inputDecoration('Full Name', Icons.person_rounded),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Please enter full name'
                                : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<PatientGender>(
                              value: _selectedGender,
                              decoration:
                                  _inputDecoration('Gender', Icons.wc_rounded),
                              items: PatientGender.values.map((g) {
                                return DropdownMenuItem<PatientGender>(
                                  value: g,
                                  child: Text(
                                    g.name == 'male' ? 'Male' : 'Female',
                                    style: hTextStyle(14),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedGender = val),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<BloodType>(
                              value: _selectedBloodType,
                              decoration: _inputDecoration(
                                  'Blood Type', Icons.water_drop_rounded),
                              items: BloodType.values.map((bt) {
                                return DropdownMenuItem<BloodType>(
                                  value: bt,
                                  child: Text(bt.value, style: hTextStyle(14)),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedBloodType = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDob ?? DateTime(1990, 1, 1),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => _selectedDob = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: C.bg,
                            border: Border.all(color: C.border),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.cake_rounded,
                                  color: C.teal, size: 20),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Date of Birth',
                                      style: lblTextStyle(c: C.txt3, s: 10)),
                                  const SizedBox(height: 2),
                                  Text(_formatDate(_selectedDob),
                                      style: bTextStyle(14, w: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressController,
                        decoration: _inputDecoration(
                            'Address', Icons.location_on_rounded),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emergencyNameController,
                        decoration: _inputDecoration('Emergency Contact Name',
                            Icons.contact_phone_rounded),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emergencyPhoneController,
                        decoration: _inputDecoration(
                            'Emergency Contact Phone', Icons.phone_rounded),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _insuranceCompanyController,
                        decoration: _inputDecoration(
                            'Insurance Company', Icons.business_rounded),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _insuranceNumberController,
                        decoration: _inputDecoration(
                            'Insurance Number', Icons.credit_card_rounded),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _allergiesController,
                        decoration: _inputDecoration(
                            'Allergies (comma separated)',
                            Icons.warning_rounded),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _chronicDiseasesController,
                        decoration: _inputDecoration(
                            'Chronic Diseases (comma separated)',
                            Icons.healing_rounded),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel',
                        style: bTextStyle(14, c: C.txt2, w: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: C.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Save',
                        style: bTextStyle(14, c: Colors.white, w: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final allergies = _allergiesController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      final chronicDiseases = _chronicDiseasesController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final updated = widget.profile.copyWith(
        fullName: _nameController.text,
        address:
            _addressController.text.isEmpty ? null : _addressController.text,
        emergencyContactName: _emergencyNameController.text.isEmpty
            ? null
            : _emergencyNameController.text,
        emergencyContact: _emergencyPhoneController.text.isEmpty
            ? null
            : _emergencyPhoneController.text,
        insuranceCompany: _insuranceCompanyController.text.isEmpty
            ? null
            : _insuranceCompanyController.text,
        insuranceNumber: _insuranceNumberController.text.isEmpty
            ? null
            : _insuranceNumberController.text,
        dateOfBirth: _selectedDob,
        gender: _selectedGender,
        bloodType: _selectedBloodType,
        allergies: allergies,
        chronicDiseases: chronicDiseases,
      );

      context.read<PatientProfileCubit>().updateProfile(updated);
      Navigator.of(context).pop();
    }
  }
}
