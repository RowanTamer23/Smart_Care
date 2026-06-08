import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_care/features/doctor/patients/cubit/doctor_patients_state.dart';
import 'package:smart_care/features/doctor/patients/data/model/doctor_patient_model.dart';
import 'package:smart_care/features/doctor/patients/data/repository/doctor_patients_repository.dart';
import 'package:smart_care/features/doctor/schedule/data/model/appointment_model.dart';

class DoctorPatientsCubit extends Cubit<DoctorPatientsState> {
  final DoctorPatientsRepository _repository;

  DoctorPatientsCubit(this._repository) : super(DoctorPatientsInitial());

  List<DoctorPatient> patients = [];

  /// Loads all patients for [staffProfileId] using the already-fetched
  /// [appointments] list from AppointmentCubit (avoids a duplicate DB call).
  Future<void> loadPatients({
    required String staffProfileId,
    required List<Appointment> appointments,
  }) async {
    // Don't reload if already loaded with the same set of patients
    if (state is DoctorPatientsLoading) return;

    emit(DoctorPatientsLoading());
    try {
      patients = await _repository.getPatients(
        staffProfileId: staffProfileId,
        appointments: appointments,
      );
      emit(DoctorPatientsSuccess(List.from(patients)));
    } catch (e) {
      emit(DoctorPatientsFailure(e.toString()));
    }
  }
}
