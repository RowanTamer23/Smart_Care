import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_care/features/patient/profile/cubit/patient_profile_state.dart';
import 'package:smart_care/features/patient/profile/data/model/patient_profile_model.dart';
import 'package:smart_care/features/patient/profile/data/model/medical_record_model.dart';
import 'package:smart_care/features/patient/profile/data/model/medical_reminder_model.dart';
import 'package:smart_care/features/patient/profile/data/repository/patient_profile_repository.dart';

class PatientProfileCubit extends Cubit<PatientProfileState> {
  final PatientProfileRepository repository;

  PatientProfileCubit(this.repository) : super(PatientProfileInitial());

  /// Loads the patient profile by the user's auth ID.
  /// If no profile exists yet, it creates a blank one.
  Future<void> loadPatientProfile(String profileId) async {
    emit(PatientProfileLoading());
    try {
      PatientProfile? profile = await repository.getPatientProfile(profileId);
      
      if (profile == null) {
        // Create a blank/default profile record if not found
        final newProfile = PatientProfile(
          id: 'temp',
          profileId: profileId,
          createdAt: DateTime.now(),
          allergies: const [],
          chronicDiseases: const [],
        );
        profile = await repository.savePatientProfile(newProfile);
      }

      final records = await repository.getMedicalRecords(profile.id);
      final reminders = await repository.getMedicalReminders(profile.id);
      emit(PatientProfileLoaded(profile, records, reminders));
    } catch (e) {
      emit(PatientProfileError(e.toString()));
    }
  }

  /// Updates patient profile details.
  Future<void> updateProfile(PatientProfile profile) async {
    final currentState = state;
    if (currentState is PatientProfileLoaded) {
      emit(PatientProfileLoading());
      try {
        final updatedProfile = await repository.savePatientProfile(profile);
        final records = await repository.getMedicalRecords(updatedProfile.id);
        final reminders = await repository.getMedicalReminders(updatedProfile.id);
        emit(PatientProfileLoaded(updatedProfile, records, reminders));
      } catch (e) {
        emit(PatientProfileError(e.toString()));
      }
    }
  }

  /// Adds a medical record log.
  Future<void> addRecord(MedicalRecord record) async {
    final currentState = state;
    if (currentState is PatientProfileLoaded) {
      emit(PatientProfileLoading());
      try {
        await repository.addMedicalRecord(record);
        final records = await repository.getMedicalRecords(currentState.profile.id);
        final reminders = await repository.getMedicalReminders(currentState.profile.id);
        emit(PatientProfileLoaded(currentState.profile, records, reminders));
      } catch (e) {
        emit(PatientProfileError(e.toString()));
      }
    }
  }

  /// Updates an existing medical record.
  Future<void> updateRecord(MedicalRecord record) async {
    final currentState = state;
    if (currentState is PatientProfileLoaded) {
      emit(PatientProfileLoading());
      try {
        await repository.updateMedicalRecord(record);
        final records = await repository.getMedicalRecords(currentState.profile.id);
        final reminders = await repository.getMedicalReminders(currentState.profile.id);
        emit(PatientProfileLoaded(currentState.profile, records, reminders));
      } catch (e) {
        emit(PatientProfileError(e.toString()));
      }
    }
  }

  /// Adds a medical reminder.
  Future<void> addReminder(MedicalReminder reminder) async {
    final currentState = state;
    if (currentState is PatientProfileLoaded) {
      emit(PatientProfileLoading());
      try {
        await repository.addMedicalReminder(reminder);
        final records = await repository.getMedicalRecords(currentState.profile.id);
        final reminders = await repository.getMedicalReminders(currentState.profile.id);
        emit(PatientProfileLoaded(currentState.profile, records, reminders));
      } catch (e) {
        emit(PatientProfileError(e.toString()));
      }
    }
  }

  /// Updates an existing medical reminder.
  Future<void> updateReminder(MedicalReminder reminder) async {
    final currentState = state;
    if (currentState is PatientProfileLoaded) {
      emit(PatientProfileLoading());
      try {
        await repository.updateMedicalReminder(reminder);
        final records = await repository.getMedicalRecords(currentState.profile.id);
        final reminders = await repository.getMedicalReminders(currentState.profile.id);
        emit(PatientProfileLoaded(currentState.profile, records, reminders));
      } catch (e) {
        emit(PatientProfileError(e.toString()));
      }
    }
  }
}
