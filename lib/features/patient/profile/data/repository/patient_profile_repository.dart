import 'package:smart_care/features/patient/profile/data/model/lab_model.dart';
import 'package:smart_care/features/patient/profile/data/model/patient_profile_model.dart';
import 'package:smart_care/features/patient/profile/data/model/medical_record_model.dart';
import 'package:smart_care/features/patient/profile/data/model/medical_reminder_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PatientProfileRepository {
  final _supabase = Supabase.instance.client;

  /// Fetches a patient profile associated with the user's main profile/auth ID.
  /// Joins the main `profiles` table to get the user's full name and avatar.
  Future<PatientProfile?> getPatientProfile(String profileId) async {
    try {
      final res = await _supabase
          .from('patient_profiles')
          .select('*, profiles!profile_id(full_name, avatar_url)')
          .eq('profile_id', profileId)
          .maybeSingle();
      if (res == null) return null;
      return PatientProfile.fromMap(res);
    } on PostgrestException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred while fetching patient profile: $e';
    }
  }

  /// Inserts or updates the patient profile record.
  /// Re-fetches with profiles join after upsert to get the full_name populated.
  Future<PatientProfile> savePatientProfile(PatientProfile profile) async {
    try {
      final map = profile.toMap();
      if (profile.id.isEmpty || profile.id == 'temp-id' || profile.id.startsWith('temp')) {
        map.remove('id');
      }
      // Upsert the row
      await _supabase
          .from('patient_profiles')
          .upsert(map, onConflict: 'profile_id');
      // Re-fetch with the profiles join to get full_name
      final res = await _supabase
          .from('patient_profiles')
          .select('*, profiles!profile_id(full_name, avatar_url)')
          .eq('profile_id', profile.profileId)
          .single();
      return PatientProfile.fromMap(res);
    } on PostgrestException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred while saving patient profile: $e';
    }
  }

  /// Fetches all medical records associated with a given patient profile ID.
  Future<List<MedicalRecord>> getMedicalRecords(String patientProfileId) async {
    try {
      final res = await _supabase
          .from('medical_records')
          .select()
          .eq('patient_profile_id', patientProfileId)
          .order('record_date', ascending: false);
      return (res as List).map((e) => MedicalRecord.fromMap(e)).toList();
    } catch (_) {
      // Return empty list if the query fails (e.g. if the table is empty/missing RLS access)
      return [];
    }
  }

  /// Adds a new medical record log.
  Future<MedicalRecord> addMedicalRecord(MedicalRecord record) async {
    try {
      final map = record.toMap();
      if (record.id.isEmpty || record.id == 'temp-id' || record.id.startsWith('temp')) {
        map.remove('id');
      }
      final res = await _supabase
          .from('medical_records')
          .insert(map)
          .select()
          .single();
      return MedicalRecord.fromMap(res);
    } on PostgrestException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred while adding medical record: $e';
    }
  }

  /// Updates an existing medical record.
  Future<MedicalRecord> updateMedicalRecord(MedicalRecord record) async {
    try {
      final map = record.toMap();
      final res = await _supabase
          .from('medical_records')
          .update(map)
          .eq('id', record.id)
          .select()
          .single();
      return MedicalRecord.fromMap(res);
    } on PostgrestException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred while updating medical record: $e';
    }
  }

  Future<List<PatientLab>> getLabs(String patientProfileId) async {
    try {
      final res = await _supabase
          .from('patient_labs')
          .select()
          .eq('patient_profile_id', patientProfileId)
          .order('created_at', ascending: false);
      return (res as List).map((e) => PatientLab.fromMap(e)).toList();
    } on PostgrestException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred while fetching labs: $e';
    }
  }

Future<PatientLab> addLab(PatientLab lab) async {
    try {
      final map = lab.toMap();
      if (lab.id.isEmpty || lab.id == 'temp-id' || lab.id.startsWith('temp')) {
        map.remove('id');
      }
      final res = await _supabase
          .from('patient_labs')
          .insert(map)
          .select()
          .single();
      return PatientLab.fromMap(res);
    } on PostgrestException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred while adding lab: $e';
    }
  }
  

  /// Fetches medical reminders for a patient.
  Future<List<MedicalReminder>> getMedicalReminders(String patientProfileId) async {
    try {
      final res = await _supabase
          .from('medical_reminders')
          .select()
          .eq('patient_profile_id', patientProfileId)
          .order('reminder_time', ascending: true);
      return (res as List).map((e) => MedicalReminder.fromMap(e)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Adds a new medical reminder.
  Future<MedicalReminder> addMedicalReminder(MedicalReminder reminder) async {
    try {
      final map = reminder.toMap();
      if (reminder.id.isEmpty || reminder.id == 'temp-id' || reminder.id.startsWith('temp')) {
        map.remove('id');
      }
      final res = await _supabase
          .from('medical_reminders')
          .insert(map)
          .select()
          .single();
      return MedicalReminder.fromMap(res);
    } on PostgrestException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred while adding reminder: $e';
    }
  }

  /// Updates an existing medical reminder.
  Future<MedicalReminder> updateMedicalReminder(MedicalReminder reminder) async {
    try {
      final map = reminder.toMap();
      final res = await _supabase
          .from('medical_reminders')
          .update(map)
          .eq('id', reminder.id)
          .select()
          .single();
      return MedicalReminder.fromMap(res);
    } on PostgrestException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred while updating reminder: $e';
    }
  }

  /// Deletes a medical reminder.
  Future<void> deleteMedicalReminder(String id) async {
    try {
      await _supabase
          .from('medical_reminders')
          .delete()
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred while deleting reminder: $e';
    }
  }
}

