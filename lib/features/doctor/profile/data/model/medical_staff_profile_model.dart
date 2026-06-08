// medical_staff_profile_model.dart

class MedicalStaffProfile {
  final String id;
  final String profileId;
  final String staffType;
  final String? specialtyId;
  final int? yearsExperience;
  final String? gender;
  final String? country;
  final String? city;
  final String? bio;
  final double? consultationFee;
  final int? appointmentDurationMinutes;
  final bool? supportsInPerson;
  final bool? supportsVideo;
  final bool? supportsHomeVisit;
  final List<String>? languages;
  final String? licenseNumber; // ← was required String, now nullable
  final bool? isVerified;
  final DateTime? approvedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? suspensionReason;

  const MedicalStaffProfile({
    required this.id,
    required this.profileId,
    required this.staffType,
    this.specialtyId,
    this.yearsExperience,
    this.gender,
    this.country,
    this.city,
    this.bio,
    this.consultationFee,
    this.appointmentDurationMinutes,
    this.supportsInPerson,
    this.supportsVideo,
    this.supportsHomeVisit,
    this.languages,
    this.licenseNumber, // ← no longer required
    this.isVerified,
    this.approvedAt,
    this.createdAt,
    this.updatedAt,
    this.suspensionReason,
  });

  factory MedicalStaffProfile.fromJson(Map<String, dynamic> json) {
    return MedicalStaffProfile(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      staffType: json['staff_type'] as String,
      specialtyId: json['specialty_id'] as String?,
      yearsExperience: json['years_experience'] as int?,
      gender: json['gender'] as String?,
      country: json['country'] as String?,
      city: json['city'] as String?,
      bio: json['bio'] as String?,
      consultationFee: (json['consultation_fee'] as num?)?.toDouble(),
      appointmentDurationMinutes: json['appointment_duration_minutes'] as int?,
      supportsInPerson: json['supports_in_person'] as bool?,
      supportsVideo: json['supports_video'] as bool?,
      supportsHomeVisit: json['supports_home_visit'] as bool?,
      languages: (json['languages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      licenseNumber: json['license_number'] as String?, // ← safe cast
      isVerified: json['is_verified'] as bool?,
      approvedAt: _parseDate(json['approved_at']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      suspensionReason: json['suspension_reason'] as String?,
    );
  }

  MedicalStaffProfile copyWith({
    String? id,
    String? profileId,
    String? staffType,
    String? specialtyId,
    int? yearsExperience,
    String? gender,
    String? country,
    String? city,
    String? bio,
    double? consultationFee,
    int? appointmentDurationMinutes,
    bool? supportsInPerson,
    bool? supportsVideo,
    bool? supportsHomeVisit,
    List<String>? languages,
    String? licenseNumber,
    bool? isVerified,
    DateTime? approvedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? suspensionReason,
  }) {
    return MedicalStaffProfile(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      staffType: staffType ?? this.staffType,
      specialtyId: specialtyId ?? this.specialtyId,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      city: city ?? this.city,
      bio: bio ?? this.bio,
      consultationFee: consultationFee ?? this.consultationFee,
      appointmentDurationMinutes: appointmentDurationMinutes ?? this.appointmentDurationMinutes,
      supportsInPerson: supportsInPerson ?? this.supportsInPerson,
      supportsVideo: supportsVideo ?? this.supportsVideo,
      supportsHomeVisit: supportsHomeVisit ?? this.supportsHomeVisit,
      languages: languages ?? this.languages,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      isVerified: isVerified ?? this.isVerified,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      suspensionReason: suspensionReason ?? this.suspensionReason,
    );
  }

  static DateTime? _parseDate(dynamic value) =>
      value == null ? null : DateTime.parse(value as String);
}
