class MedicalStaffDocument {
  final String id;
  final String staffProfileId;
  final String documentType;
  final String fileUrl;
  final String? verificationStatus;
  final String? rejectionReason;
  final DateTime createdAt;

  MedicalStaffDocument({
    required this.id,
    required this.staffProfileId,
    required this.documentType,
    required this.fileUrl,
    this.verificationStatus,
    this.rejectionReason,
    required this.createdAt,
  });

  /// Creates a copy of this object with the given fields replaced.
  MedicalStaffDocument copyWith({
    String? id,
    String? staffProfileId,
    String? documentType,
    String? fileUrl,
    String? verificationStatus,
    String? rejectionReason,
    DateTime? createdAt,
  }) {
    return MedicalStaffDocument(
      id: id ?? this.id,
      staffProfileId: staffProfileId ?? this.staffProfileId,
      documentType: documentType ?? this.documentType,
      fileUrl: fileUrl ?? this.fileUrl,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Converts a Map (JSON) payload from Supabase into this Dart object.
  factory MedicalStaffDocument.fromMap(Map<String, dynamic> map) {
    return MedicalStaffDocument(
      id: map['id'] as String,
      staffProfileId: map['staff_profile_id'] as String,
      documentType: map['document_type'] as String,
      fileUrl: map['file_url'] as String,
      verificationStatus: map['verification_status'] as String? ?? 'pending',
      rejectionReason: map['rejection_reason'] as String?,
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
      'document_type': documentType,
      'file_url': fileUrl,
      'verification_status': verificationStatus,
      'rejection_reason': rejectionReason,
      // Supabase accepts ISO 8601 strings for timestamps
      'created_at': createdAt.toIso8601String(),
    };
  }
}
