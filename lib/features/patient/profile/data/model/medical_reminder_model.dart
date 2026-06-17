import 'dart:convert';
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

  // Frequency and schedule helper getters/methods
  String get rawDosage {
    if (dosage == null) return '';
    if (dosage!.startsWith('{')) {
      try {
        final decoded = jsonDecode(dosage!);
        return decoded['dose'] as String? ?? '';
      } catch (_) {}
    }
    return dosage!;
  }

  String get frequencyType {
    if (dosage != null && dosage!.startsWith('{')) {
      try {
        final decoded = jsonDecode(dosage!);
        return decoded['freq'] as String? ?? 'daily';
      } catch (_) {}
    }
    return 'daily';
  }

  int get intervalDays {
    if (dosage != null && dosage!.startsWith('{')) {
      try {
        final decoded = jsonDecode(dosage!);
        return decoded['interval'] as int? ?? 1;
      } catch (_) {}
    }
    return 1;
  }

  List<int> get weeklyDays {
    if (dosage != null && dosage!.startsWith('{')) {
      try {
        final decoded = jsonDecode(dosage!);
        final list = decoded['days'] as List<dynamic>?;
        if (list != null) {
          return list.map((e) => e as int).toList();
        }
      } catch (_) {}
    }
    return [];
  }

  String get frequencyDescription {
    final type = frequencyType;
    if (type == 'daily') {
      return 'Daily';
    } else if (type == 'weekly') {
      final days = weeklyDays;
      if (days.isEmpty) return 'Weekly';
      final names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final selectedNames = days.map((d) => names[d - 1]).join(', ');
      return 'Weekly on $selectedNames';
    } else if (type == 'interval') {
      final days = intervalDays;
      return 'Every $days days';
    }
    return 'Daily';
  }

  bool isScheduledForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(startDate.year, startDate.month, startDate.day);
    
    if (dateOnly.isBefore(startOnly)) return false;
    
    if (endDate != null) {
      final endOnly = DateTime(endDate!.year, endDate!.month, endDate!.day);
      if (dateOnly.isAfter(endOnly)) return false;
    }
    
    final type = frequencyType;
    if (type == 'daily') {
      return true;
    } else if (type == 'weekly') {
      final days = weeklyDays;
      return days.contains(dateOnly.weekday);
    } else if (type == 'interval') {
      final interval = intervalDays;
      if (interval <= 0) return true;
      final diffDays = dateOnly.difference(startOnly).inDays;
      return diffDays % interval == 0;
    }
    
    return true;
  }

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
