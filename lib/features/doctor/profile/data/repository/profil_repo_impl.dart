import 'dart:typed_data';
import 'package:smart_care/features/doctor/profile/data/model/documentation_model.dart';
import 'package:smart_care/features/doctor/profile/data/model/medical_staff_profile_model.dart';
import 'package:smart_care/features/doctor/profile/data/model/profile_model.dart';
import 'package:smart_care/features/doctor/profile/data/model/speciality_model.dart';
import 'package:smart_care/features/doctor/profile/data/repository/profile_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class MedicalStaffRepositoryImpl implements MedicalStaffRepository {
  @override
  Future<MedicalStaffProfile> getMedicalData(String id) async {
    try {
      final res = await supabase
          .from('medical_staff_profiles')
          .select()
          .eq('profile_id', id)
          .single();
      final user = res['profile_id'] as String?;
      if (user == null) {
        throw 'User not found';
      }

      return MedicalStaffProfile.fromJson(res);
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  @override
  Future<MedicalStaffProfile> updateMedicalData(MedicalStaffProfile data) async {
    try {
      final res = await supabase
          .from('medical_staff_profiles')
          .update({
            'staff_type': data.staffType,
            'specialty_id': data.specialtyId,
            'years_experience': data.yearsExperience,
            'gender': data.gender,
            'country': data.country,
            'city': data.city,
            'bio': data.bio,
            'consultation_fee': data.consultationFee,
            'appointment_duration_minutes': data.appointmentDurationMinutes,
            'supports_in_person': data.supportsInPerson,
            'supports_video': data.supportsVideo,
            'supports_home_visit': data.supportsHomeVisit,
            'languages': data.languages,
            'license_number': data.licenseNumber,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', data.id)
          .select()
          .single();
      return MedicalStaffProfile.fromJson(res);
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }
}

class ProfileRepositoryImpl implements ProfileRepository {
  @override
  Future<Profile> fetchById(String id) async {
    try {
      final res =
          await supabase.from('profiles').select().eq('id', id).single();
      final user = res['id'] as String?;
      if (user == null) {
        throw 'User not found';
      }

      return Profile.fromMap(res);
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    try {
      final res = await supabase
          .from('profiles')
          .update({
            'full_name': profile.fullName,
            'phone': profile.phone,
            'avatar_url': profile.avatarUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', profile.id)
          .select()
          .single();
      return Profile.fromMap(res);
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }
}

class SpecialityRepositoryImpl implements SpecialityRepository {
  @override
  Future<Specialty> getSpeciality(String id) async {
    try {
      final res =
          await supabase.from('specialties').select().eq('id', id).single();
      final user = res['id'] as String?;
      if (user == null) {
        throw 'User not found';
      }

      print("Fetched specialty raw map: $res");
      return Specialty.fromJson(res);
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }
}

class DocumentRepositoryImpl implements DocumentRepository {
  @override
  Future<List<MedicalStaffDocument>> getDocuments(String staffProfileId) async {
    try {
      final res = await supabase
          .from('medical_staff_documents')
          .select()
          .eq('staff_profile_id', staffProfileId);
      
      return (res as List).map((e) => MedicalStaffDocument.fromMap(e)).toList();
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  @override
  Future<MedicalStaffDocument> uploadDocument({
    required String staffProfileId,
    required String documentType,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    try {
      final storagePath = '$staffProfileId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      // Upload to Supabase Storage 'medical-documents' bucket
      await supabase.storage
          .from('medical-documents')
          .uploadBinary(storagePath, Uint8List.fromList(fileBytes));

      // Save metadata record in medical_staff_documents
      final res = await supabase
          .from('medical_staff_documents')
          .insert({
            'staff_profile_id': staffProfileId,
            'document_type': documentType,
            'file_url': storagePath,
            'verification_status': 'pending',
          })
          .select()
          .single();

      return MedicalStaffDocument.fromMap(res);
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    try {
      await supabase
          .from('medical_staff_documents')
          .delete()
          .eq('id', documentId);
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }
}
