import 'package:smart_care/features/patient/profile/data/model/patient_profile_model.dart';
import 'package:smart_care/features/patient/profile/data/model/medical_record_model.dart';
import 'package:smart_care/features/patient/profile/data/model/medical_reminder_model.dart';

abstract class PatientProfileState {}

class PatientProfileInitial extends PatientProfileState {}

class PatientProfileLoading extends PatientProfileState {}

class PatientProfileLoaded extends PatientProfileState {
  final PatientProfile profile;
  final List<MedicalRecord> medicalRecords;
  final List<MedicalReminder> medicalReminders;
  PatientProfileLoaded(this.profile, this.medicalRecords, this.medicalReminders);
}

class PatientProfileError extends PatientProfileState {
  final String error;
  PatientProfileError(this.error);
}
