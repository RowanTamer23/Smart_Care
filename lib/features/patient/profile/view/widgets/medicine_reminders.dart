import 'package:flutter/material.dart';
import 'package:smart_care/features/patient/profile/data/model/medical_reminder_model.dart';
import 'package:smart_care/features/patient/profile/view/widgets/section_header.dart';
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
    final today = DateTime.now();
    final todayReminders = widget.reminders.where((r) => r.isScheduledForDate(today)).toList();
    final todayTotal = todayReminders.length;
    final todayTaken = todayReminders.where((r) => _medicineActive[r.id] ?? false).length;

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
        
        // Today's schedule checklist section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF16302B), Color(0xFF1A4A40)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF16302B).withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Today's Dosage Checklist", style: hTextStyle(14, c: Colors.white)),
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
                          '$todayTaken/$todayTotal taken',
                          style: lblTextStyle(c: C.green, s: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (todayReminders.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  child: Text(
                    'No active medicines scheduled for today! 🎉',
                    style: bTextStyle(13, c: Colors.white70, w: FontWeight.w600),
                  ),
                )
              else
                Column(
                  children: todayReminders.map((reminder) {
                    final isTaken = _medicineActive[reminder.id] ?? false;
                    final timeStr = _formatTime(reminder.reminderTime);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.12)),
                      ),
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        leading: GestureDetector(
                          onTap: () {
                            setState(() {
                              _medicineActive[reminder.id] = !isTaken;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isTaken ? C.green : Colors.transparent,
                              border: Border.all(
                                color: isTaken ? C.green : Colors.white60,
                                width: 1.5,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: isTaken
                                ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                                : null,
                          ),
                        ),
                        title: Text(
                          reminder.medicineName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isTaken ? Colors.white54 : Colors.white,
                            decoration: isTaken ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Text(
                          '${reminder.rawDosage.isEmpty ? 'As directed' : reminder.rawDosage} • $timeStr',
                          style: TextStyle(
                            fontSize: 11,
                            color: isTaken ? Colors.white38 : Colors.white70,
                            decoration: isTaken ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isTaken ? C.green.withOpacity(0.2) : C.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isTaken ? 'Taken' : 'Pending',
                            style: lblTextStyle(c: isTaken ? C.green : C.amber, s: 9),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        SectionHeader(
          'All Medications',
          icon: Icons.list_alt_rounded,
          color: C.teal,
        ),
        const SizedBox(height: 10),
        
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
              dose: reminder.rawDosage.isEmpty ? 'As directed' : reminder.rawDosage,
              freq: reminder.frequencyDescription,
              icon: _icons[index % _icons.length],
              color: _colors[index % _colors.length],
              bg: _bgs[index % _bgs.length],
              desc: reminder.endDate != null
                  ? 'Active until ${_formatDate(reminder.endDate!)}'
                  : 'Continuous treatment',
              refill: 'Active',
              times: _formatTime(reminder.reminderTime),
            );

            final isTaken = _medicineActive[reminder.id] ?? false;

            return GestureDetector(
              onTap: () => _showAddEditReminderDialog(context, reminder),
              child: MedicineCard(
                name: reminder.medicineName,
                data: data,
                active: isTaken,
                onToggle: (v) => setState(() => _medicineActive[reminder.id] = v),
              ),
            );
          }),
      ],
    );
  }
}
