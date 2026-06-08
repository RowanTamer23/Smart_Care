import 'package:smart_care/features/doctor/profile/data/model/documentation_model.dart';
import 'package:smart_care/features/doctor/profile/data/model/medical_staff_profile_model.dart';
import 'package:smart_care/features/doctor/profile/data/model/profile_model.dart';
import 'package:smart_care/features/doctor/profile/data/model/speciality_model.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileSuccess extends ProfileState {
  final Profile profile;
  ProfileSuccess(this.profile);
}

class ProfileFailure extends ProfileState {
  final String message;
  ProfileFailure(this.message);
}

abstract class MedicalStaffState {}

class MedicalStaffInitial extends MedicalStaffState {}

class MedicalStaffLoading extends MedicalStaffState {}

class MedicalStaffSuccess extends MedicalStaffState {
  final MedicalStaffProfile medicalStaffProfile;
  MedicalStaffSuccess(this.medicalStaffProfile);
}

class MedicalStaffFailure extends MedicalStaffState {
  final String message;
  MedicalStaffFailure(this.message);
}


// speciality states

abstract class SpecialityState {}

class SpecialityInitial extends SpecialityState {}

class SpecialityLoading extends SpecialityState {}

class SpecialitySuccess extends SpecialityState {
  final Specialty speciality;
  SpecialitySuccess(this.speciality);
}

class SpecialityFailure extends SpecialityState {
  final String message;
  SpecialityFailure(this.message);
}


//  Documents State

abstract class DocumentState {}

class DocumentInitial extends DocumentState {}

class DocumentLoading extends DocumentState {}

class DocumentsLoaded extends DocumentState {
  final List<MedicalStaffDocument> documents;
  DocumentsLoaded(this.documents);
}

class DocumentUploadSuccess extends DocumentState {
  final MedicalStaffDocument document;
  DocumentUploadSuccess(this.document);
}

class DocumentDeleteSuccess extends DocumentState {
  final String id;
  DocumentDeleteSuccess(this.id);
}

class DocumentFailure extends DocumentState {
  final String message;
  DocumentFailure(this.message);
}