import 'package:flutter/material.dart';
import 'package:smart_care/features/patient/profile/data/model/medical_reminder_model.dart';
import 'package:smart_care/features/patient/profile/view/widgets/section_header.dart';
import 'package:smart_care/features/patient/profile/view/widgets/dose_time_pill.dart';
import 'package:smart_care/features/patient/profile/view/widgets/medicine_card.dart';
import 'package:smart_care/features/patient/profile/view/widgets/profile_styles.dart';
import 'package:smart_care/features/patient/profile/view/widgets/add_edit_reminder_dialog.dart';

class MedicineReminders extends StatefulWidget {
  final List<MedicalReminder> reminders;
  final String patientProfileId;

  const MedicineReminders({
    super.key,
    required this.reminders,
    required this.patientProfileId,
  });

  @override
  State<MedicineReminders> createState() => _MedicineRemindersState();
}

class _MedicineRemindersState extends State<MedicineReminders> {
  final Map<String, bool> _medicineActive = {};

  final _icons = [
    Icons.circle_rounded,
    Icons.favorite_rounded,
    Icons.water_drop_rounded,
    Icons.medication_liquid_rounded,
  ];
  final _colors = [C.blue, C.red, C.purple, C.teal];
  final _bgs = [C.blueLight, C.redLight, C.purpleLight, C.tealLight];

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return "$hour:$minute $period";
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  void _showAddEditReminderDialog(BuildContext context, MedicalReminder? reminder) {
    showDialog(
      context: context,
      builder: (context) => AddEditReminderDialog(
        patientProfileId: widget.patientProfileId,
        reminder: reminder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.reminders.length;
    final taken = widget.reminders.where((r) => _medicineActive[r.id] ?? true).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          'Medicine Reminders',
          icon: Icons.medication_rounded,
          color: C.amber,
          action: 'Add Reminder',
          onAction: () => _showAddEditReminderDialog(context, null),
        ),
        const SizedBox(height: 12),
        // Today's schedule strip
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF16302B), Color(0xFF1A4A40)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Today's Doses", style: hTextStyle(14, c: Colors.white)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: C.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 12,
                          color: C.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$taken/$total taken',
                          style: lblTextStyle(c: C.green, s: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (widget.reminders.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'No active reminders for today.',
                    style: bTextStyle(12, c: Colors.white70),
                  ),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.reminders.map((reminder) {
                      final timeStr = _formatTime(reminder.reminderTime);
                      final isActive = _medicineActive[reminder.id] ?? true;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: DoseTimePill(
                          timeStr,
                          isActive ? 'Taken' : 'Pending',
                          isActive,
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Medicine cards
        if (widget.reminders.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: C.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: C.border),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.medication_outlined,
                  size: 36,
                  color: C.txt3,
                ),
                const SizedBox(height: 8),
                Text(
                  'No medicine reminders set.',
                  style: bTextStyle(13, c: C.txt2, w: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  "Tap 'Add Reminder' to set daily schedules.",
                  style: lblTextStyle(c: C.txt3, s: 11),
                ),
              ],
            ),
          )
        else
          ...List.generate(widget.reminders.length, (index) {
            final reminder = widget.reminders[index];
            final data = (
              dose: reminder.dosage ?? 'As directed',
              freq: 'Daily schedule',
              icon: _icons[index % _icons.length],
              color: _colors[index % _colors.length],
              bg: _bgs[index % _bgs.length],
              desc: reminder.endDate != null
                  ? 'Active until ${_formatDate(reminder.endDate!)}'
                  : 'Continuous treatment',
              refill: 'Active',
              times: _formatTime(reminder.reminderTime),
            );

            return GestureDetector(
              onTap: () => _showAddEditReminderDialog(context, reminder),
              child: MedicineCard(
                name: reminder.medicineName,
                data: data,
                active: _medicineActive[reminder.id] ?? true,
                onToggle: (v) => setState(() => _medicineActive[reminder.id] = v),
              ),
            );
          }),
      ],
    );
  }
}
