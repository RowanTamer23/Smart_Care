import 'package:smart_care/features/doctor/schedule/data/model/appointment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentRepository {
  final _supabase = Supabase.instance.client;

  /// Fetches appointments for the doctor (staffProfileId), joining patient details.
  Future<List<Appointment>> getAppointments(String staffProfileId) async {
    try {
      final res = await _supabase
          .from('appointments')
          .select('*, patient:patient_profiles(*, profiles(full_name))')
          .eq('staff_profile_id', staffProfileId)
          .order('appointment_date', ascending: true)
          .order('appointment_time', ascending: true);
      
      return (res as List).map((e) => Appointment.fromMap(e)).toList();
    } on PostgrestException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  /// Fetches appointments for the patient, joining doctor/medical staff profiles and auth profiles.
  Future<List<Appointment>> getPatientAppointments(String patientProfileId) async {
    try {
      final res = await _supabase
          .from('appointments')
          .select('*, doctor:medical_staff_profiles(*, profiles(id, full_name))')
          .eq('patient_profile_id', patientProfileId)
          .order('appointment_date', ascending: true)
          .order('appointment_time', ascending: true);
      
      return (res as List).map((e) => Appointment.fromMap(e)).toList();
    } on PostgrestException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  /// Inserts a new appointment booking.
  Future<Appointment> bookAppointment(Appointment appointment) async {
    try {
      final map = appointment.toMap();
      if (appointment.id.isEmpty || appointment.id == 'temp-id' || appointment.id.startsWith('temp')) {
        map.remove('id');
      }
      final res = await _supabase
          .from('appointments')
          .insert(map)
          .select()
          .single();
      return Appointment.fromMap(res);
    } on PostgrestException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  /// Updates appointment status (e.g. accepted/refused/completed)
  Future<Appointment> updateAppointmentStatus(String appointmentId, AppointmentStatus status) async {
    try {
      final res = await _supabase
          .from('appointments')
          .update({'status': status.toShortString()})
          .eq('id', appointmentId)
          .select()
          .single();
      return Appointment.fromMap(res);
    } on PostgrestException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }
}
