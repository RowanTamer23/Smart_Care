import 'package:smart_care/features/patient/profile/data/model/patient_profile_model.dart';
import 'package:smart_care/features/patient/profile/data/model/medical_record_model.dart';
import 'package:smart_care/features/patient/profile/data/model/medical_reminder_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PatientProfileRepository {
  final _supabase = Supabase.instance.client;

  /// Fetches a patient profile associated with the user's main profile/auth ID.
  Future<PatientProfile?> getPatientProfile(String profileId) async {
    try {
      final res = await _supabase
          .from('patient_profiles')
          .select()
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
  Future<PatientProfile> savePatientProfile(PatientProfile profile) async {
    try {
      final map = profile.toMap();
      if (profile.id.isEmpty || profile.id == 'temp-id' || profile.id.startsWith('temp')) {
        map.remove('id');
      }
      final res = await _supabase
          .from('patient_profiles')
          .upsert(map, onConflict: 'profile_id')
          .select()
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
}
