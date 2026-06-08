import 'package:flutter/material.dart';

class StaffAvailability {
  final String id;
  final String staffProfileId;
  final int weekday; // 1 = Monday, 7 = Sunday (following ISO-8601 standard)
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isActive;
  final DateTime createdAt;

  StaffAvailability({
    required this.id,
    required this.staffProfileId,
    required this.weekday,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
    required this.createdAt,
  });

  /// Creates a copy of this object with the given fields replaced.
  StaffAvailability copyWith({
    String? id,
    String? staffProfileId,
    int? weekday,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return StaffAvailability(
      id: id ?? this.id,
      staffProfileId: staffProfileId ?? this.staffProfileId,
      weekday: weekday ?? this.weekday,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Converts a Map (JSON) payload from Supabase into this Dart object.
  factory StaffAvailability.fromMap(Map<String, dynamic> map) {
    return StaffAvailability(
      id: map['id'] as String,
      staffProfileId: map['staff_profile_id'] as String,
      weekday: map['weekday'] as int,
      startTime: _parseTimeString(map['start_time'] as String),
      endTime: _parseTimeString(map['end_time'] as String),
      isActive: map['is_active'] as bool? ?? true,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String).toLocal()
          : DateTime.now(),
    );
  }

  /// Converts this Dart object into a Map (JSON) payload to send to Supabase.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'staff_profile_id': staffProfileId,
      'weekday': weekday,
      'start_time': _toTimeString(startTime),
      'end_time': _toTimeString(endTime),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Helper: Converts a database time string "HH:mm:ss" or "HH:mm" to TimeOfDay
  static TimeOfDay _parseTimeString(String timeStr) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Helper: Converts TimeOfDay to a clean "HH:mm:ss" string format for PostgreSQL
  static String _toTimeString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }
}
