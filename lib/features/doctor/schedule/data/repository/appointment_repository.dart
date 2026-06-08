import 'package:smart_care/features/doctor/schedule/data/model/appointment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentRepository {
  final _supabase = Supabase.instance.client;

  /// Fetches appointments for the doctor (staffProfileId), joining patient details.
  Future<List<Appointment>> getAppointments(String staffProfileId) async {
    try {
      final res = await _supabase
          .from('appointments')
          .select('*, patient:patient_profiles(*)')
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
}
