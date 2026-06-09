import 'package:flutter/material.dart';

class MedicalReminder {
  final String id;
  final String patientProfileId;
  final String medicineName;
  final String? dosage;
  final TimeOfDay reminderTime; // Maps to PostgreSQL 'time'
  final DateTime startDate; // Maps to PostgreSQL 'date'
  final DateTime? endDate; // Maps to PostgreSQL 'date' (Nullable)
  final bool isSent;
  final DateTime createdAt;

  MedicalReminder({
    required this.id,
    required this.patientProfileId,
    required this.medicineName,
    this.dosage,
    required this.reminderTime,
    required this.startDate,
    this.endDate,
    this.isSent = false,
    required this.createdAt,
  });

  /// Creates a copy of this object with the given fields replaced.
  MedicalReminder copyWith({
    String? id,
    String? patientProfileId,
    String? medicineName,
    String? dosage,
    TimeOfDay? reminderTime,
    DateTime? startDate,
    DateTime? endDate,
    bool? isSent,
    DateTime? createdAt,
  }) {
    return MedicalReminder(
      id: id ?? this.id,
      patientProfileId: patientProfileId ?? this.patientProfileId,
      medicineName: medicineName ?? this.medicineName,
      dosage: dosage ?? this.dosage,
      reminderTime: reminderTime ?? this.reminderTime,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isSent: isSent ?? this.isSent,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Converts a Map (JSON) payload from Supabase into this Dart object.
  factory MedicalReminder.fromMap(Map<String, dynamic> map) {
    return MedicalReminder(
      id: map['id'] as String,
      patientProfileId: map['patient_profile_id'] as String,
      medicineName: map['medicine_name'] as String,
      dosage: map['dosage'] as String?,
      reminderTime: _parseTimeString(map['reminder_time'] as String),
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: map['end_date'] != null
          ? DateTime.parse(map['end_date'] as String)
          : null,
      isSent: map['is_sent'] as bool? ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String).toLocal()
          : DateTime.now(),
    );
  }

  /// Converts this Dart object into a Map (JSON) payload to send to Supabase.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_profile_id': patientProfileId,
      'medicine_name': medicineName,
      'dosage': dosage,
      'reminder_time': _toTimeString(reminderTime),
      'start_date': _toDateString(startDate),
      'end_date': _toDateString(endDate),
      'is_sent': isSent,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Helper: Converts database "HH:mm:ss" string to TimeOfDay
  static TimeOfDay _parseTimeString(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  /// Helper: Converts TimeOfDay to a clean "HH:mm:ss" string format for PostgreSQL
  static String _toTimeString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  /// Helper: Converts DateTime to a clean "YYYY-MM-DD" format for PostgreSQL 'date' column
  static String? _toDateString(DateTime? date) {
    if (date == null) return null;
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
