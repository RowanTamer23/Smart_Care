import 'package:smart_care/features/auth/data/repository/auth_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class AuthRepoImpl implements AuthRepository {
  @override
  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      // 1. Sign up the user in Supabase Auth
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw 'Sign up failed';
      }

      // 2. Build the base profile map with common fields
      final Map<String, dynamic> profileData = {
        'id': user.id,
        'email': email,
        'full_name': name,
        'role': role.toLowerCase(), // Normalizing role string
        'phone': phone,
      };

      // 3. Perform a SINGLE insert into profiles table
      await supabase.from('profiles').upsert(profileData);

      return AuthResult(
        userId: user.id,
        email: email,
        role: role,
        name: name,
      );
    } on AuthException catch (e) {
      throw e.message;
    }
  }

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = res.user;
      if (user == null) {
        throw 'User not found';
      }

      // Fetch user profile from profiles table to get their name and role
      final profile = await supabase
          .from('profiles')
          .select('full_name, role')
          .eq('id', user.id)
          .single();

      return AuthResult(
        userId: user.id,
        email: email,
        role: profile['role'] as String? ?? 'patient',
        name: profile['full_name'] as String? ?? '',
      );
      
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  @override
  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  @override
  Future<void> saveMedicalStaffProfile({
    required String profileId,
    required String staffType,
    required String licenseNumber,
    String?
        specialtyId, // Changed parameter name to match specialty text search
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
  }) async {
    try {
      // FIXED: Use .limit(1) instead of .maybeSingle() to safely handle duplicate specialty names
      if (specialtyId != null) {
        final List<dynamic> specialtyQuery = await supabase
            .from('specialties')
            .select('id')
            .eq('name', specialtyId)
            .limit(1);

        if (specialtyQuery.isNotEmpty) {
          specialtyId = specialtyQuery.first['id'] as String?;
        }
      }

      final Map<String, dynamic> data = {
        'profile_id': profileId,
        'staff_type': staffType,
        'license_number': licenseNumber,
        'is_verified': false,
        'supports_in_person': supportsInPerson,
        'supports_video': supportsVideo,
        'supports_home_visit': supportsHomeVisit,
        'languages': languages,
      };

      if (specialtyId != null) data['specialty_id'] = specialtyId;
      if (yearsExperience != null) data['years_experience'] = yearsExperience;
      if (gender != null) data['gender'] = gender;
      if (country != null) data['country'] = country;
      if (city != null) data['city'] = city;
      if (bio != null) data['bio'] = bio;
      if (consultationFee != null) data['consultation_fee'] = consultationFee;
      if (appointmentDurationMinutes != null) {
        data['appointment_duration_minutes'] = appointmentDurationMinutes;
      }

      await supabase.from('medical_staff_profiles').insert(data);
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSpecialties() async {
    try {
      // Fetches all rows from the specialties table ordered by name alphabetically
      final List<dynamic> response = await supabase
          .from('specialties')
          .select('id, name')
          .order('name', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Failed to fetch specialties: $e';
    }
  }
}
