import 'package:smart_care/features/doctor/schedule/data/model/appointment_model.dart';
import 'package:smart_care/features/patient/profile/data/model/medical_record_model.dart';
import 'package:smart_care/features/patient/profile/data/model/patient_profile_model.dart';

/// Represents a patient as seen from the doctor's perspective —
/// combining the full PatientProfile, all medical records from this doctor,
/// and a reference to the most recent appointment.
class DoctorPatient {
  final PatientProfile profile;
  final List<MedicalRecord> medicalRecords;
  final List<Appointment> appointments; // All appointments with this doctor

  const DoctorPatient({
    required this.profile,
    this.medicalRecords = const [],
    this.appointments = const [],
  });

  /// The most recent appointment with this doctor.
  Appointment? get lastAppointment {
    if (appointments.isEmpty) return null;
    return appointments.reduce(
      (a, b) => a.appointmentDate.isAfter(b.appointmentDate) ? a : b,
    );
  }

  /// Derives a display status from the most recent appointment status.
  String get status {
    final last = lastAppointment;
    if (last == null) return 'UNKNOWN';
    switch (last.status) {
      case AppointmentStatus.completed:
        return 'STABLE';
      case AppointmentStatus.pending:
        return 'FOLLOW-UP';
      case AppointmentStatus.confirmed:
        return 'FOLLOW-UP';
      case AppointmentStatus.cancelled:
      case AppointmentStatus.rejected:
        return 'CANCELLED';
    }
  }

  /// Human-readable name from the patient profile.
  String get displayName => profile.fullName ?? 'Unknown Patient';

  /// Patient age computed from date of birth.
  int? get age {
    final dob = profile.dateOfBirth;
    if (dob == null) return null;
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  /// Formatted last visit date string.
  String get lastVisitDisplay {
    final last = lastAppointment;
    if (last == null) return 'No visits yet';
    final d = last.appointmentDate;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}
