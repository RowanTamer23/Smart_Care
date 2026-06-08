import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_care/features/doctor/schedule/cubit/availability_state.dart';
import 'package:smart_care/features/doctor/schedule/data/model/Availability_model.dart';
import 'package:smart_care/features/doctor/schedule/data/repository/availability_repository.dart';

class AvailabilityCubit extends Cubit<AvailabilityState> {
  final AvailabilityRepository _repository;
  
  AvailabilityCubit(this._repository) : super(AvailabilityInitial());

  List<StaffAvailability> availabilities = [];

  /// Fetches weekly availability from the database for the given staff profile ID.
  /// Automatically generates default/disabled entries for days of the week that are not configured yet.
  Future<void> getAvailability(String staffProfileId) async {
    emit(AvailabilityLoading());
    try {
      final fetched = await _repository.getAvailability(staffProfileId);

      // Create a map by weekday for fast lookup
      final Map<int, StaffAvailability> map = {
        for (var a in fetched) a.weekday: a
      };

      // Generate all 7 days (0 = Sunday, 1 = Monday, ..., 6 = Saturday)
      availabilities = List.generate(7, (index) {
        if (map.containsKey(index)) {
          return map[index]!;
        } else {
          return StaffAvailability(
            id: '', // Empty ID signifies a new record to be inserted
            staffProfileId: staffProfileId,
            weekday: index,
            startTime: const TimeOfDay(hour: 9, minute: 0),
            endTime: const TimeOfDay(hour: 17, minute: 0),
            isActive: false,
            createdAt: DateTime.now(),
          );
        }
      });

      emit(AvailabilitySuccess(List.from(availabilities)));
    } catch (e) {
      emit(AvailabilityFailure(e.toString()));
    }
  }

  /// Optimistically updates a day's availability in local state before the user saves everything.
  void updateAvailability(StaffAvailability updated) {
    final index = availabilities.indexWhere((a) => a.weekday == updated.weekday);
    if (index != -1) {
      availabilities[index] = updated;
      emit(AvailabilitySuccess(List.from(availabilities)));
    }
  }

  /// Iterates and saves all availability records in the week to the database.
  Future<void> saveWeeklyAvailability() async {
    emit(AvailabilityLoading());
    try {
      final List<StaffAvailability> savedList = [];
      for (final a in availabilities) {
        final saved = await _repository.saveAvailability(a);
        savedList.add(saved);
      }
      
      // Update local state list with saved results (e.g. including generated database UUIDs)
      final Map<int, StaffAvailability> map = {
        for (var a in savedList) a.weekday: a
      };
      
      availabilities = List.generate(7, (index) {
        return map[index]!;
      });
      
      emit(AvailabilitySuccess(List.from(availabilities)));
    } catch (e) {
      emit(AvailabilityFailure(e.toString()));
    }
  }
}
