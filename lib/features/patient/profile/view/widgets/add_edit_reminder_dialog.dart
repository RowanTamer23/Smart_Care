import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_care/features/patient/profile/cubit/patient_profile_cubit.dart';
import 'package:smart_care/features/patient/profile/data/model/medical_reminder_model.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_styles.dart';

class AddEditReminderDialog extends StatefulWidget {
  final String patientProfileId;
  final MedicalReminder? reminder;

  const AddEditReminderDialog({
    super.key,
    required this.patientProfileId,
    this.reminder,
  });

  @override
  State<AddEditReminderDialog> createState() => _AddEditReminderDialogState();
}

class _AddEditReminderDialogState extends State<AddEditReminderDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late TimeOfDay _selectedTime;
  late DateTime _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.reminder?.medicineName ?? '');
    _dosageController =
        TextEditingController(text: widget.reminder?.dosage ?? '');
    _selectedTime = widget.reminder?.reminderTime ?? TimeOfDay.now();
    _startDate = widget.reminder?.startDate ?? DateTime.now();
    _endDate = widget.reminder?.endDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return "$hour:$minute $period";
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
                widget.reminder == null
                    ? 'Add Medicine Reminder'
                    : 'Edit Medicine Reminder',
                style: hTextStyle(18, c: C.primary),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration(
                          'Medicine Name',
                          Icons.medication_rounded,
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Please enter medicine name'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _dosageController,
                        decoration: _inputDecoration(
                          'Dosage (e.g. 1 tablet, 5ml)',
                          Icons.scale_rounded,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime,
                          );
                          if (picked != null) {
                            setState(() => _selectedTime = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: C.bg,
                            border: Border.all(color: C.border),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                color: C.teal,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Reminder Time',
                                    style: lblTextStyle(c: C.txt3, s: 10),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatTime(_selectedTime),
                                    style: bTextStyle(14, w: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _startDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: C.bg,
                            border: Border.all(color: C.border),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                color: C.teal,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Start Date',
                                    style: lblTextStyle(c: C.txt3, s: 10),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatDate(_startDate),
                                    style: bTextStyle(14, w: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? _startDate,
                            firstDate: _startDate,
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _endDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: C.bg,
                            border: Border.all(color: C.border),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_month_rounded,
                                color: C.teal,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'End Date (Optional)',
                                      style: lblTextStyle(c: C.txt3, s: 10),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _endDate != null
                                          ? _formatDate(_endDate!)
                                          : 'No End Date',
                                      style: bTextStyle(14, w: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              if (_endDate != null)
                                IconButton(
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    size: 18,
                                    color: C.txt3,
                                  ),
                                  onPressed: () =>
                                      setState(() => _endDate = null),
                                ),
                            ],
                          ),
                        ),
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
                    child: Text(
                      'Cancel',
                      style: bTextStyle(14, c: C.txt2, w: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: C.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Save',
                      style: bTextStyle(14, c: Colors.white, w: FontWeight.w700),
                    ),
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
      if (widget.reminder == null) {
        // Add new
        final newReminder = MedicalReminder(
          id: 'temp',
          patientProfileId: widget.patientProfileId,
          medicineName: _nameController.text.trim(),
          dosage: _dosageController.text.trim().isEmpty
              ? null
              : _dosageController.text.trim(),
          reminderTime: _selectedTime,
          startDate: _startDate,
          endDate: _endDate,
          createdAt: DateTime.now(),
        );
        context.read<PatientProfileCubit>().addReminder(newReminder);
      } else {
        // Edit existing
        final updatedReminder = widget.reminder!.copyWith(
          medicineName: _nameController.text.trim(),
          dosage: _dosageController.text.trim().isEmpty
              ? null
              : _dosageController.text.trim(),
          reminderTime: _selectedTime,
          startDate: _startDate,
          endDate: _endDate,
        );
        context.read<PatientProfileCubit>().updateReminder(updatedReminder);
      }
      Navigator.of(context).pop();
    }
  }
}
