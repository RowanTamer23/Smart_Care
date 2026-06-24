import 'dart:convert';
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

  late String _selectedFreqType;
  late Set<int> _selectedWeeklyDays;
  late int _intervalDays;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.reminder?.medicineName ?? '');
    _dosageController =
        TextEditingController(text: widget.reminder?.rawDosage ?? '');
    _selectedTime = widget.reminder?.reminderTime ?? TimeOfDay.now();
    _startDate = widget.reminder?.startDate ?? DateTime.now();
    _endDate = widget.reminder?.endDate;

    _selectedFreqType = widget.reminder?.frequencyType ?? 'daily';
    _selectedWeeklyDays = widget.reminder?.weeklyDays.toSet() ?? <int>{};
    _intervalDays = widget.reminder?.intervalDays ?? 2;
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.reminder == null
                        ? 'Add Medicine Reminder'
                        : 'Edit Medicine Reminder',
                    style: hTextStyle(18, c: C.primary),
                  ),
                  if (widget.reminder != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: C.red),
                      onPressed: () => _delete(context),
                    ),
                ],
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
                      _buildFrequencySelector(),
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

  Widget _buildFrequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How often do you take it?',
          style: hTextStyle(12, c: C.txt1),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildFreqTypeTab('daily', 'Daily'),
            const SizedBox(width: 8),
            _buildFreqTypeTab('weekly', 'Weekly'),
            const SizedBox(width: 8),
            _buildFreqTypeTab('interval', 'Interval'),
          ],
        ),
        if (_selectedFreqType == 'weekly') ...[
          const SizedBox(height: 12),
          Text(
            'Select Days of the Week',
            style: lblTextStyle(c: C.txt2, s: 11),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final weekday = index + 1; // 1 = Monday, 7 = Sunday
              final names = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
              final isSelected = _selectedWeeklyDays.contains(weekday);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedWeeklyDays.remove(weekday);
                    } else {
                      _selectedWeeklyDays.add(weekday);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isSelected ? C.teal : C.bg,
                    border: Border.all(
                      color: isSelected ? C.teal : C.border,
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    names[index],
                    style: bTextStyle(
                      12,
                      c: isSelected ? Colors.white : C.txt1,
                      w: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }),
          ),
        ] else if (_selectedFreqType == 'interval') ...[
          const SizedBox(height: 12),
          Text(
            'Repeat Interval',
            style: lblTextStyle(c: C.txt2, s: 11),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: C.bg,
              border: Border.all(color: C.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Every $_intervalDays days',
                  style: bTextStyle(14, w: FontWeight.w600),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded, color: C.teal, size: 22),
                      onPressed: _intervalDays > 1
                          ? () => setState(() => _intervalDays--)
                          : null,
                    ),
                    Text(
                      '$_intervalDays',
                      style: bTextStyle(14, w: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded, color: C.teal, size: 22),
                      onPressed: () => setState(() => _intervalDays++),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFreqTypeTab(String type, String label) {
    final isSelected = _selectedFreqType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFreqType = type;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? C.teal : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? C.teal : C.border,
            ),
          ),
          child: Text(
            label,
            style: bTextStyle(
              12,
              c: isSelected ? Colors.white : C.txt2,
              w: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      if (_selectedFreqType == 'weekly' && _selectedWeeklyDays.isEmpty) {
        _selectedWeeklyDays.add(DateTime.now().weekday);
      }

      final dosageJson = jsonEncode({
        'dose': _dosageController.text.trim().isEmpty ? 'As directed' : _dosageController.text.trim(),
        'freq': _selectedFreqType,
        'interval': _intervalDays,
        'days': _selectedWeeklyDays.toList(),
      });

      if (widget.reminder == null) {
        // Add new
        final newReminder = MedicalReminder(
          id: 'temp',
          patientProfileId: widget.patientProfileId,
          medicineName: _nameController.text.trim(),
          dosage: dosageJson,
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
          dosage: dosageJson,
          reminderTime: _selectedTime,
          startDate: _startDate,
          endDate: _endDate,
        );
        context.read<PatientProfileCubit>().updateReminder(updatedReminder);
      }
      Navigator.of(context).pop();
    }
  }

  void _delete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Reminder', style: hTextStyle(16, c: C.primary)),
        content: Text(
          'Are you sure you want to delete this medicine reminder?',
          style: bTextStyle(13, c: C.txt2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: bTextStyle(14, c: C.txt2, w: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context
                  .read<PatientProfileCubit>()
                  .deleteReminder(widget.reminder!.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: C.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Delete',
              style: bTextStyle(14, c: Colors.white, w: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
