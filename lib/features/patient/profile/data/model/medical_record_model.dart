
class MedicalRecord {
  final String id;
  final String patientProfileId;
  final String staffProfileId;
  final String? appointmentId;
  final String? symptoms;
  final String? diagnosis;
  final String? treatment;
  final DateTime recordDate;
  final List<String> attachments; // Maps to text[]
  final String recordType;
  final String? doctorNotes;
  final List<String> fileUrls; // Maps to text[]
  final dynamic
      prescription; // Maps to jsonb (e.g., List or Map structured data)
  final dynamic labResults; // Maps to jsonb (e.g., List or Map structured data)
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicalRecord({
    required this.id,
    required this.patientProfileId,
    required this.staffProfileId,
    this.appointmentId,
    this.symptoms,
    this.diagnosis,
    this.treatment,
    required this.recordDate,
    this.attachments = const [],
    this.recordType = 'visit',
    this.doctorNotes,
    this.fileUrls = const [],
    this.prescription = const [],
    this.labResults = const [],
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy of this object with the given fields replaced.
  MedicalRecord copyWith({
    String? id,
    String? patientProfileId,
    String? staffProfileId,
    String? appointmentId,
    String? symptoms,
    String? diagnosis,
    String? treatment,
    DateTime? recordDate,
    List<String>? attachments,
    String? recordType,
    String? doctorNotes,
    List<String>? fileUrls,
    dynamic prescription,
    dynamic labResults,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicalRecord(
      id: id ?? this.id,
      patientProfileId: patientProfileId ?? this.patientProfileId,
      staffProfileId: staffProfileId ?? this.staffProfileId,
      appointmentId: appointmentId ?? this.appointmentId,
      symptoms: symptoms ?? this.symptoms,
      diagnosis: diagnosis ?? this.diagnosis,
      treatment: treatment ?? this.treatment,
      recordDate: recordDate ?? this.recordDate,
      attachments: attachments ?? this.attachments,
      recordType: recordType ?? this.recordType,
      doctorNotes: doctorNotes ?? this.doctorNotes,
      fileUrls: fileUrls ?? this.fileUrls,
      prescription: prescription ?? this.prescription,
      labResults: labResults ?? this.labResults,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts a Map (JSON) payload from Supabase into this Dart object.
  factory MedicalRecord.fromMap(Map<String, dynamic> map) {
    return MedicalRecord(
      id: map['id'] as String,
      patientProfileId: map['patient_profile_id'] as String,
      staffProfileId: map['staff_profile_id'] as String,
      appointmentId: map['appointment_id'] as String?,
      symptoms: map['symptoms'] as String?,
      diagnosis: map['diagnosis'] as String?,
      treatment: map['treatment'] as String?,
      recordDate: map['record_date'] != null
          ? DateTime.parse(map['record_date'] as String).toLocal()
          : DateTime.now(),
      attachments: map['attachments'] != null
          ? List<String>.from(map['attachments'] as List)
          : const [],
      recordType: map['record_type'] as String? ?? 'visit',
      doctorNotes: map['doctor_notes'] as String?,
      fileUrls: map['file_urls'] != null
          ? List<String>.from(map['file_urls'] as List)
          : const [],
      // jsonb fields can be parsed maps/lists or raw JSON strings depending on serializer setup
      prescription: map['prescription'],
      labResults: map['lab_results'],
      notes: map['notes'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String).toLocal()
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String).toLocal()
          : DateTime.now(),
    );
  }

  /// Converts this Dart object into a Map (JSON) payload to send to Supabase.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_profile_id': patientProfileId,
      'staff_profile_id': staffProfileId,
      'appointment_id': appointmentId,
      'symptoms': symptoms,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'record_date': recordDate.toIso8601String(),
      'attachments': attachments,
      'record_type': recordType,
      'doctor_notes': doctorNotes,
      'file_urls': fileUrls,
      'prescription': prescription,
      'lab_results': labResults,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
