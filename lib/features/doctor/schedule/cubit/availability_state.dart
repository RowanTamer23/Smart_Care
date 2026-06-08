import 'package:smart_care/features/doctor/schedule/data/model/Availability_model.dart';

abstract class AvailabilityState {}

class AvailabilityInitial extends AvailabilityState {}

class AvailabilityLoading extends AvailabilityState {}

class AvailabilitySuccess extends AvailabilityState {
  final List<StaffAvailability> availabilities;
  AvailabilitySuccess(this.availabilities);
}

class AvailabilityFailure extends AvailabilityState {
  final String error;
  AvailabilityFailure(this.error);
}
