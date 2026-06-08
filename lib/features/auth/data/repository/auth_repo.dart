class AuthResult {
  final String userId;
  final String email;
  final String role;
  final String name;

  AuthResult({
    required this.userId,
    required this.email,
    required this.role,
    required this.name,
  });
}

abstract class AuthRepository {
  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  });

  Future<AuthResult> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<void> saveMedicalStaffProfile({
    required String profileId,
    required String staffType,
    required String licenseNumber,
    String? specialtyId,
    int? yearsExperience,
    String? gender,
    String? country,
    String? city,
    String? bio,
    double? consultationFee,
    int? appointmentDurationMinutes,
    bool supportsInPerson = false,
    bool supportsVideo = false,
    bool supportsHomeVisit = false,
    List<String> languages = const [],
  });

  Future<List<Map<String, dynamic>>> getSpecialties();
}
