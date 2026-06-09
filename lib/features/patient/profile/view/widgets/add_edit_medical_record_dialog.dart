import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_care/features/patient/profile/cubit/patient_profile_cubit.dart';
import 'package:smart_care/features/patient/profile/data/model/medical_record_model.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_styles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddEditMedicalRecordDialog extends StatefulWidget {
  final String patientProfileId;
  final MedicalRecord? record;
  const AddEditMedicalRecordDialog(
      {super.key, required this.patientProfileId, this.record});

  @override
  State<AddEditMedicalRecordDialog> createState() =>
      _AddEditMedicalRecordDialogState();
}

class _AddEditMedicalRecordDialogState
    extends State<AddEditMedicalRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedType;
  late final TextEditingController _symptomsController;
  late final TextEditingController _diagnosisController;
  late final TextEditingController _treatmentController;
  late final TextEditingController _notesController;
  late DateTime _selectedDate;
  late String _selectedLabStatus;

  List<Map<String, dynamic>> _doctorsList = [];
  String? _selectedDoctorId;
  bool _loadingDoctors = true;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.record?.recordType ?? 'visit';
    _symptomsController =
        TextEditingController(text: widget.record?.symptoms ?? '');
    _diagnosisController =
        TextEditingController(text: widget.record?.diagnosis ?? '');
    _treatmentController =
        TextEditingController(text: widget.record?.treatment ?? '');
    _notesController = TextEditingController(text: widget.record?.notes ?? '');
    _selectedDate = widget.record?.recordDate ?? DateTime.now();
    _selectedDoctorId = widget.record?.staffProfileId;
    _selectedLabStatus = widget.record?.doctorNotes ?? 'normal';
    _loadDoctors();
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    _diagnosisController.dispose();
    _treatmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctors() async {
    try {
      // Fetch from medical_staff_profiles, joining user profiles for the full name.
      // This maps the doctor dropdown IDs directly to medical_staff_profiles.id
      final res = await Supabase.instance.client
          .from('medical_staff_profiles')
          .select('id, profiles(full_name)');
      
      final list = (res as List).map((item) {
        final profile = item['profiles'] as Map<String, dynamic>?;
        return {
          'id': item['id'] as String,
          'full_name': profile?['full_name'] as String? ?? 'Unknown Doctor',
        };
      }).toList();

      if (mounted) {
        setState(() {
          _doctorsList = list;
          _loadingDoctors = false;
          
          // Re-validate if the loaded list contains _selectedDoctorId
          final hasSelected = _doctorsList.any((d) => d['id'] == _selectedDoctorId);
          if (!hasSelected && _doctorsList.isNotEmpty) {
            _selectedDoctorId = _doctorsList.first['id'] as String;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingDoctors = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
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
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.record == null ? 'Add Medical Record' : 'Edit Medical Record',
                style: hTextStyle(18, c: C.primary),
              ),
              const SizedBox(height: 16),
              if (_loadingDoctors)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: CircularProgressIndicator(color: C.teal),
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedType,
                          decoration: _inputDecoration(
                              'Record Type', Icons.category_rounded),
                          items: const [
                            DropdownMenuItem(
                                value: 'visit', child: Text('Doctor Visit')),
                            DropdownMenuItem(
                                value: 'surgery', child: Text('Surgery')),
                            DropdownMenuItem(
                                value: 'lab', child: Text('Lab Result')),
                            DropdownMenuItem(
                                value: 'prescription',
                                child: Text('Prescription')),
                          ],
                          onChanged: (val) =>
                              setState(() => _selectedType = val ?? 'visit'),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedDoctorId,
                          decoration: _inputDecoration(
                              'Doctor', Icons.person_pin_rounded),
                          items: _doctorsList.map((d) {
                            return DropdownMenuItem<String>(
                              value: d['id'] as String,
                              child: Text(
                                d['full_name'] as String? ?? 'Unknown Doctor',
                              ),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedDoctorId = val),
                          validator: (value) =>
                              value == null ? 'Please select a doctor' : null,
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() => _selectedDate = picked);
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
                                const Icon(Icons.calendar_today_rounded,
                                    color: C.teal, size: 20),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Record Date',
                                        style: lblTextStyle(c: C.txt3, s: 10)),
                                    const SizedBox(height: 2),
                                    Text(_formatDate(_selectedDate),
                                        style:
                                            bTextStyle(14, w: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_selectedType == 'lab') ...[
                          DropdownButtonFormField<String>(
                            value: _selectedLabStatus,
                            decoration: _inputDecoration(
                                'Lab Status', Icons.analytics_rounded),
                            items: const [
                              DropdownMenuItem(
                                  value: 'normal', child: Text('Normal')),
                              DropdownMenuItem(
                                  value: 'borderline',
                                  child: Text('Borderline')),
                              DropdownMenuItem(
                                  value: 'low', child: Text('Low')),
                              DropdownMenuItem(
                                  value: 'high', child: Text('High')),
                            ],
                            onChanged: (val) => setState(() =>
                                _selectedLabStatus = val ?? 'normal'),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (_selectedType != 'lab') ...[
                          TextFormField(
                            controller: _symptomsController,
                            decoration:
                                _inputDecoration('Symptoms', Icons.sick_rounded),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextFormField(
                          controller: _diagnosisController,
                          decoration: _inputDecoration(
                            _selectedType == 'lab'
                                ? 'Test Name (e.g. Hemoglobin)'
                                : 'Diagnosis / Condition Name',
                            Icons.healing_rounded,
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'This field is required'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _treatmentController,
                          decoration: _inputDecoration(
                            _selectedType == 'lab'
                                ? 'Result Value (e.g. 14.2 g/dL)'
                                : 'Treatment / Dose / Value',
                            Icons.medication_rounded,
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'This field is required'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _notesController,
                          decoration: _inputDecoration(
                            _selectedType == 'lab'
                                ? 'Reference Range (e.g. 13.8 - 17.2 g/dL)'
                                : 'Additional Notes',
                            Icons.description_rounded,
                          ),
                          maxLines: 2,
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
                  if (!_loadingDoctors)
                    ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: C.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Save',
                          style: bTextStyle(14,
                              c: Colors.white, w: FontWeight.w700)),
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
      if (widget.record == null) {
        // Add new
        final newRecord = MedicalRecord(
          id: 'temp',
          patientProfileId: widget.patientProfileId,
          staffProfileId: _selectedDoctorId!,
          symptoms: _symptomsController.text.trim().isEmpty
              ? null
              : _symptomsController.text.trim(),
          diagnosis: _diagnosisController.text.trim().isEmpty
              ? null
              : _diagnosisController.text.trim(),
          treatment: _treatmentController.text.trim().isEmpty
              ? null
              : _treatmentController.text.trim(),
          recordDate: _selectedDate,
          recordType: _selectedType,
          doctorNotes: _selectedType == 'lab' ? _selectedLabStatus : null,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        context.read<PatientProfileCubit>().addRecord(newRecord);
      } else {
        // Edit existing
        final updatedRecord = widget.record!.copyWith(
          staffProfileId: _selectedDoctorId!,
          symptoms: _symptomsController.text.trim().isEmpty
              ? null
              : _symptomsController.text.trim(),
          diagnosis: _diagnosisController.text.trim().isEmpty
              ? null
              : _diagnosisController.text.trim(),
          treatment: _treatmentController.text.trim().isEmpty
              ? null
              : _treatmentController.text.trim(),
          recordDate: _selectedDate,
          recordType: _selectedType,
          doctorNotes: _selectedType == 'lab' ? _selectedLabStatus : null,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          updatedAt: DateTime.now(),
        );
        context.read<PatientProfileCubit>().updateRecord(updatedRecord);
      }
      Navigator.of(context).pop();
    }
  }
}
