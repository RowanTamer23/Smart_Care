import 'package:smart_care/features/doctor/patients/data/model/doctor_patient_model.dart';

abstract class DoctorPatientsState {}

class DoctorPatientsInitial extends DoctorPatientsState {}

class DoctorPatientsLoading extends DoctorPatientsState {}

class DoctorPatientsSuccess extends DoctorPatientsState {
  final List<DoctorPatient> patients;
  DoctorPatientsSuccess(this.patients);
}

class DoctorPatientsFailure extends DoctorPatientsState {
  final String error;
  DoctorPatientsFailure(this.error);
}
