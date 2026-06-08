import 'dart:core';
import 'dart:typed_data';

import 'package:smart_care/features/doctor/profile/data/model/documentation_model.dart';
import 'package:smart_care/features/doctor/profile/data/model/medical_staff_profile_model.dart';
import 'package:smart_care/features/doctor/profile/data/model/profile_model.dart';
import 'package:smart_care/features/doctor/profile/data/model/speciality_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  Future<Profile> fetchById(String id) async {
    final res = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', id)
        .single();
    return Profile.fromMap(res);
  }

  Future<Profile> updateProfile(Profile profile) async {
    final res = await Supabase.instance.client
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
  }
}

class MedicalStaffRepository {
  Future<MedicalStaffProfile> getMedicalData(String id) async {
    final res = await Supabase.instance.client
        .from('medical_staff_profiles')
        .select()
        .eq('profile_id', id)
        .single();
    return MedicalStaffProfile.fromJson(res);
  }

  Future<MedicalStaffProfile> updateMedicalData(MedicalStaffProfile data) async {
    final res = await Supabase.instance.client
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
  }
}

class SpecialityRepository {
  Future<Specialty> getSpeciality(String id) async {
    final res = await Supabase.instance.client
        .from('specialties')
        .select()
        .eq('id', id)
        .single();
    return Specialty.fromJson(res);
  }
}

class DocumentRepository {
  Future<List<MedicalStaffDocument>> getDocuments(String staffProfileId) async {
    final res = await Supabase.instance.client
        .from('medical_staff_documents')
        .select()
        .eq('staff_profile_id', staffProfileId);
    return (res as List).map((e) => MedicalStaffDocument.fromMap(e)).toList();
  }

  Future<MedicalStaffDocument> uploadDocument({
    required String staffProfileId,
    required String documentType,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    final storagePath = '$staffProfileId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    
    // Upload bytes to Supabase Storage 'medical-documents' bucket
    await Supabase.instance.client.storage
        .from('medical-documents')
        .uploadBinary(storagePath, Uint8List.fromList(fileBytes));

    // Save metadata record in medical_staff_documents
    final res = await Supabase.instance.client
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
  }

  Future<void> deleteDocument(String documentId) async {
    await Supabase.instance.client
        .from('medical_staff_documents')
        .delete()
        .eq('id', documentId);
  }
}

