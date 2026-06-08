import 'package:smart_care/features/doctor/patients/data/model/doctor_patient_model.dart';
import 'package:smart_care/features/doctor/schedule/data/model/appointment_model.dart';
import 'package:smart_care/features/patient/profile/data/model/medical_record_model.dart';
import 'package:smart_care/features/patient/profile/data/model/patient_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DoctorPatientsRepository {
  final _supabase = Supabase.instance.client;

  /// Fetches full [DoctorPatient] records for all patients who have had
  /// at least one appointment with [staffProfileId].
  ///
  /// [appointments] — the already-loaded list from AppointmentCubit so we
  /// don't need to re-fetch them.
  Future<List<DoctorPatient>> getPatients({
    required String staffProfileId,
    required List<Appointment> appointments,
  }) async {
    if (appointments.isEmpty) return [];

    // 1. Collect unique patient profile IDs from the loaded appointments
    final patientIds = appointments
        .map((a) => a.patientProfileId)
        .toSet()
        .toList();

    // 2. Fetch patient profiles for those IDs
    final profilesRes = await _supabase
        .from('patient_profiles')
        .select('*')
        .inFilter('id', patientIds);

    final profiles = (profilesRes as List)
        .map((e) => PatientProfile.fromMap(e as Map<String, dynamic>))
        .toList();

    // 3. Try to fetch medical records (table may not exist yet — handle gracefully)
    List<MedicalRecord> allRecords = [];
    try {
      final recordsRes = await _supabase
          .from('medical_records')
          .select('*')
          .eq('staff_profile_id', staffProfileId)
          .inFilter('patient_profile_id', patientIds)
          .order('record_date', ascending: false);

      allRecords = (recordsRes as List)
          .map((e) => MedicalRecord.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // medical_records table may not exist yet — silently continue
    }

    // 4. Build DoctorPatient objects grouping records and appointments by patient
    return profiles.map((profile) {
      final patientRecords = allRecords
          .where((r) => r.patientProfileId == profile.id)
          .toList();
      final patientAppointments = appointments
          .where((a) => a.patientProfileId == profile.id)
          .toList();

      return DoctorPatient(
        profile: profile,
        medicalRecords: patientRecords,
        appointments: patientAppointments,
      );
    }).toList()
      ..sort((a, b) {
        final aDate = a.lastAppointment?.appointmentDate;
        final bDate = b.lastAppointment?.appointmentDate;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate); // most recent first
      });
  }
}
