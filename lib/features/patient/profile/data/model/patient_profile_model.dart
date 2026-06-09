enum PatientGender {
  male,
  female;

  String toShortString() => name;

  static PatientGender? fromString(String? val) {
    if (val == null) return null;
    try {
      return PatientGender.values.firstWhere(
        (e) => e.name == val.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}

enum BloodType {
  aPositive('A+'),
  aNegative('A-'),
  bPositive('B+'),
  bNegative('B-'),
  abPositive('AB+'),
  abNegative('AB-'),
  oPositive('O+'),
  oNegative('O-');

  final String value;
  const BloodType(this.value);

  static BloodType? fromString(String? val) {
    if (val == null) return null;
    try {
      return BloodType.values.firstWhere(
        (e) => e.value.toUpperCase() == val.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }
}

class PatientProfile {
  final String id;
  final String profileId; // FK linking back to your main auth profiles table
  final DateTime? dateOfBirth; // Maps to PostgreSQL 'date'
  final PatientGender? gender;
  final BloodType? bloodType;
  final String? emergencyContact;
  final DateTime createdAt;
  final List<String> allergies; // Maps to PostgreSQL text[]
  final List<String> chronicDiseases; // Maps to PostgreSQL text[]
  final String? address;
  final String? fullName;
  final String? insuranceNumber;
  final String? insuranceCompany;
  final String? emergencyContactName;

  PatientProfile({
    required this.id,
    required this.profileId,
    this.dateOfBirth,
    this.gender,
    this.bloodType,
    this.emergencyContact,
    required this.createdAt,
    this.allergies = const [],
    this.chronicDiseases = const [],
    this.address,
    this.fullName,
    this.insuranceNumber,
    this.insuranceCompany,
    this.emergencyContactName,
  });

  /// Creates a copy of this object with the given fields replaced.
  PatientProfile copyWith({
    String? id,
    String? profileId,
    DateTime? dateOfBirth,
    PatientGender? gender,
    BloodType? bloodType,
    String? emergencyContact,
    DateTime? createdAt,
    List<String>? allergies,
    List<String>? chronicDiseases,
    String? address,
    String? fullName,
    String? insuranceNumber,
    String? insuranceCompany,
    String? emergencyContactName,
  }) {
    return PatientProfile(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      createdAt: createdAt ?? this.createdAt,
      allergies: allergies ?? this.allergies,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
      address: address ?? this.address,
      fullName: fullName ?? this.fullName,
      insuranceNumber: insuranceNumber ?? this.insuranceNumber,
      insuranceCompany: insuranceCompany ?? this.insuranceCompany,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
    );
  }

  /// Converts a Map (JSON) payload from Supabase into this Dart object.
  factory PatientProfile.fromMap(Map<String, dynamic> map) {
    return PatientProfile(
      id: map['id'] as String,
      profileId: map['profile_id'] as String,
      dateOfBirth: map['date_of_birth'] != null
          ? DateTime.parse(map['date_of_birth'] as String)
          : null,
      gender: PatientGender.fromString(map['gender'] as String?),
      bloodType: BloodType.fromString(map['blood_type'] as String?),
      emergencyContact: map['emergency_contact'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String).toLocal()
          : DateTime.now(),
      // Ensure strict dynamic lists cast cleanly into standard List<String> structures
      allergies: map['allergies'] != null
          ? List<String>.from(map['allergies'] as List)
          : const [],
      chronicDiseases: map['chronic_diseases'] != null
          ? List<String>.from(map['chronic_diseases'] as List)
          : const [],
      address: map['address'] as String?,
      fullName: map['full_name'] as String?,
      insuranceNumber: map['insurance_number'] as String?,
      insuranceCompany: map['insurance_company'] as String?,
      emergencyContactName: map['emergency_contact_name'] as String?,
    );
  }

  /// Converts this Dart object into a Map (JSON) payload to send to Supabase.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'date_of_birth': _toDateString(dateOfBirth),
      'gender': gender?.toShortString(),
      'blood_type': bloodType?.value,
      'emergency_contact': emergencyContact,
      'created_at': createdAt.toIso8601String(),
      'allergies': allergies,
      'chronic_diseases': chronicDiseases,
      'address': address,
      'full_name': fullName,
      'insurance_number': insuranceNumber,
      'insurance_company': insuranceCompany,
      'emergency_contact_name': emergencyContactName,
    };
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
