import 'package:smart_care/features/doctor/schedule/data/model/appointment_model.dart';

abstract class AppointmentState {}

class AppointmentInitial extends AppointmentState {}

class AppointmentLoading extends AppointmentState {}

class AppointmentSuccess extends AppointmentState {
  final List<Appointment> appointments;
  AppointmentSuccess(this.appointments);
}

class AppointmentFailure extends AppointmentState {
  final String error;
  AppointmentFailure(this.error);
}
