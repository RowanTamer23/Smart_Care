import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_care/features/doctor/schedule/cubit/appointment_state.dart';
import 'package:smart_care/features/doctor/schedule/data/model/appointment_model.dart';
import 'package:smart_care/features/doctor/schedule/data/repository/appointment_repository.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  final AppointmentRepository _repository;

  AppointmentCubit(this._repository) : super(AppointmentInitial());

  List<Appointment> appointments = [];

  /// Fetches doctor's appointments from Supabase database.
  Future<void> getAppointments(String staffProfileId) async {
    emit(AppointmentLoading());
    try {
      appointments = await _repository.getAppointments(staffProfileId);
      emit(AppointmentSuccess(List.from(appointments)));
    } catch (e) {
      emit(AppointmentFailure(e.toString()));
    }
  }
}
