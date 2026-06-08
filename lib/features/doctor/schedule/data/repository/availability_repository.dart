import 'package:smart_care/features/doctor/schedule/data/model/Availability_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AvailabilityRepository {
  final _supabase = Supabase.instance.client;

  /// Fetches the current availability list for a given doctor (staff profile ID).
  Future<List<StaffAvailability>> getAvailability(String staffProfileId) async {
    try {
      final res = await _supabase
          .from('staff_availability')
          .select()
          .eq('staff_profile_id', staffProfileId)
          .order('weekday', ascending: true);
      
      return (res as List).map((e) => StaffAvailability.fromMap(e)).toList();
    } on PostgrestException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred while fetching availability: $e';
    }
  }

  /// Saves (inserts or updates) a specific staff availability record.
  /// If the record ID is empty, it removes it from the payload to let Supabase auto-generate a UUID.
  Future<StaffAvailability> saveAvailability(StaffAvailability availability) async {
    try {
      final data = availability.toMap();
      if (availability.id.isEmpty) {
        data.remove('id');
      }
      
      final res = await _supabase
          .from('staff_availability')
          .upsert(data)
          .select()
          .single();
      
      return StaffAvailability.fromMap(res);
    } on PostgrestException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred while saving availability: $e';
    }
  }
}
