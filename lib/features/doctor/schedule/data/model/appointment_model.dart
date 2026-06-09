import 'package:flutter/material.dart';

enum AppointmentStatus {
  pending,
  confirmed,
  cancelled,
  completed,
  rejected;

  String toShortString() => name;

  static AppointmentStatus fromString(String val) {
    return AppointmentStatus.values.firstWhere(
      (e) => e.name == val.toLowerCase(),
      orElse: () => AppointmentStatus.pending,
    );
  }
}

enum AppointmentCareType {
  inPerson('in-person'),
  video('video'),
  homeVisit('home-visit');

  final String value;
  const AppointmentCareType(this.value);

  static AppointmentCareType fromString(String val) {
    return AppointmentCareType.values.firstWhere(
      (e) => e.value == val.toLowerCase(),
      orElse: () => AppointmentCareType.inPerson,
    );
  }
}

class Appointment {
  final String id;
  final String patientProfileId;
  final String staffProfileId;
  final DateTime appointmentDate; // Maps to PostgreSQL 'date'
  final TimeOfDay appointmentTime; // Maps to PostgreSQL 'time'
  final AppointmentStatus status;
  final String? notes;
  final DateTime createdAt;
  final AppointmentCareType? careType;
  final String? videoRoomUrl;
  final String? patientName; // Joined from patient_profiles table
  final String? doctorName; // Joined from medical_staff_profiles -> profiles

  Appointment({
    required this.id,
    required this.patientProfileId,
    required this.staffProfileId,
    required this.appointmentDate,
    required this.appointmentTime,
    this.status = AppointmentStatus.pending,
    this.notes,
    required this.createdAt,
    this.careType,
    this.videoRoomUrl,
    this.patientName,
    this.doctorName,
  });

  /// Creates a copy of this object with the given fields replaced.
  Appointment copyWith({
    String? id,
    String? patientProfileId,
    String? staffProfileId,
    DateTime? appointmentDate,
    TimeOfDay? appointmentTime,
    AppointmentStatus? status,
    String? notes,
    DateTime? createdAt,
    AppointmentCareType? careType,
    String? videoRoomUrl,
    String? patientName,
    String? doctorName,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientProfileId: patientProfileId ?? this.patientProfileId,
      staffProfileId: staffProfileId ?? this.staffProfileId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      careType: careType ?? this.careType,
      videoRoomUrl: videoRoomUrl ?? this.videoRoomUrl,
      patientName: patientName ?? this.patientName,
      doctorName: doctorName ?? this.doctorName,
    );
  }

  /// Converts a Map (JSON) payload from Supabase into this Dart object.
  factory Appointment.fromMap(Map<String, dynamic> map) {
    // Attempt to parse doctor's name if joined via medical_staff_profiles (doctor) -> profiles
    String? docName;
    if (map['doctor'] != null) {
      final doctorMap = map['doctor'] as Map<String, dynamic>;
      if (doctorMap['profiles'] != null) {
        docName = (doctorMap['profiles'] as Map<String, dynamic>)['full_name'] as String?;
      }
    }

    return Appointment(
      id: map['id'] as String,
      patientProfileId: map['patient_profile_id'] as String,
      staffProfileId: map['staff_profile_id'] as String,
      appointmentDate: DateTime.parse(map['appointment_date'] as String),
      appointmentTime: _parseTimeString(map['appointment_time'] as String),
      status:
          AppointmentStatus.fromString(map['status'] as String? ?? 'pending'),
      notes: map['notes'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String).toLocal()
          : DateTime.now(),
      careType: map['care_type'] != null
          ? AppointmentCareType.fromString(map['care_type'] as String)
          : null,
      videoRoomUrl: map['video_room_url'] as String?,
      patientName: map['patient'] != null
          ? (map['patient'] as Map<String, dynamic>)['full_name'] as String?
          : null,
      doctorName: docName,
    );
  }

  /// Converts this Dart object into a Map (JSON) payload to send to Supabase.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_profile_id': patientProfileId,
      'staff_profile_id': staffProfileId,
      'appointment_date': _toDateString(appointmentDate),
      'appointment_time': _toTimeString(appointmentTime),
      'status': status.toShortString(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'care_type': careType?.value,
      'video_room_url': videoRoomUrl,
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
  static String _toDateString(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
