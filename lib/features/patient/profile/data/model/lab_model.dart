class PatientLab {
  final String id;
  final String? patientProfileId; // Nullable Foreign Key
  final String? appointmentId; // Nullable Foreign Key
  final String? staffProfileId; // Nullable Foreign Key
  final String? note;
  final List<String> fileUrls; // Maps to text[]
  final DateTime createdAt;

  PatientLab({
    required this.id,
    this.patientProfileId,
    this.appointmentId,
    this.staffProfileId,
    this.note,
    this.fileUrls = const [],
    required this.createdAt,
  });

  /// Creates a copy of this object with the given fields replaced.
  PatientLab copyWith({
    String? id,
    String? patientProfileId,
    String? appointmentId,
    String? staffProfileId,
    String? note,
    List<String>? fileUrls,
    DateTime? createdAt,
  }) {
    return PatientLab(
      id: id ?? this.id,
      patientProfileId: patientProfileId ?? this.patientProfileId,
      appointmentId: appointmentId ?? this.appointmentId,
      staffProfileId: staffProfileId ?? this.staffProfileId,
      note: note ?? this.note,
      fileUrls: fileUrls ?? this.fileUrls,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Converts a Map (JSON) payload from Supabase into this Dart object.
  factory PatientLab.fromMap(Map<String, dynamic> map) {
    return PatientLab(
      id: map['id'] as String,
      patientProfileId: map['patient_profile_id'] as String?,
      appointmentId: map['appointment_id'] as String?,
      staffProfileId: map['staff_profile_id'] as String?,
      note: map['note'] as String?,
      // Maps the text array safely and avoids casting type mismatch crashes
      fileUrls: map['file_urls'] != null
          ? List<String>.from(map['file_urls'] as List)
          : const [],
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
      'appointment_id': appointmentId,
      'staff_profile_id': staffProfileId,
      'note': note,
      'file_urls': fileUrls,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
