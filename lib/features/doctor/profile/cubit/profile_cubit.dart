import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_care/features/doctor/profile/cubit/profile_state.dart';
import 'package:smart_care/features/doctor/profile/data/model/documentation_model.dart';
import 'package:smart_care/features/doctor/profile/data/model/medical_staff_profile_model.dart';
import 'package:smart_care/features/doctor/profile/data/model/profile_model.dart';
import 'package:smart_care/features/doctor/profile/data/model/speciality_model.dart';
import 'package:smart_care/features/doctor/profile/data/repository/profil_repo_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepositoryImpl _repository;
  ProfileCubit(this._repository) : super(ProfileInitial());

  Profile? doctor;

  Future<void> fetchById(String id) async {
    emit(ProfileLoading());
    try {
      doctor = await _repository.fetchById(id);
      emit(ProfileSuccess(doctor!));
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String phone,
    String? avatarUrl,
  }) async {
    if (doctor == null) return;
    emit(ProfileLoading());
    try {
      final updated = doctor!.copyWith(
        fullName: fullName,
        phone: phone,
        avatarUrl: avatarUrl,
        updatedAt: DateTime.now(),
      );
      final result = await _repository.updateProfile(updated);
      doctor = result;
      emit(ProfileSuccess(doctor!));
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<String?> uploadAvatar(
    String userId,
    String fileName,
    List<int> fileBytes,
  ) async {
    try {
      final path = '$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      // Upload binary to Supabase avatars bucket
      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(path, Uint8List.fromList(fileBytes));
          
      // Return public url
      return 'https://hbnvbekhyyaclymabwwi.supabase.co/storage/v1/object/public/avatars/$path';
    } catch (e) {
      throw 'Failed to upload avatar: $e';
    }
  }
}

class MedicalStaffCubit extends Cubit<MedicalStaffState> {
  final MedicalStaffRepositoryImpl _repository;
  MedicalStaffCubit(this._repository) : super(MedicalStaffInitial());

  MedicalStaffProfile? medicalStaffProfile;
  Future<void> getMedicalData(String id) async {
    emit(MedicalStaffLoading());
    try {
      medicalStaffProfile = await _repository.getMedicalData(id);
      emit(MedicalStaffSuccess(medicalStaffProfile!));
    } catch (e) {
      emit(MedicalStaffFailure(e.toString()));
    }
  }

  Future<void> updateMedicalData(MedicalStaffProfile updatedProfile) async {
    emit(MedicalStaffLoading());
    try {
      final res = await _repository.updateMedicalData(updatedProfile);
      medicalStaffProfile = res;
      emit(MedicalStaffSuccess(medicalStaffProfile!));
    } catch (e) {
      emit(MedicalStaffFailure(e.toString()));
    }
  }
}

class SpecialityCubit extends Cubit<SpecialityState> {
  final SpecialityRepositoryImpl _repo;
  SpecialityCubit(this._repo) : super(SpecialityInitial());

  Specialty? specialty;

  Future<void> getSpeciality(String id) async {
    if (id.isEmpty) return;
    emit(SpecialityLoading());
    try {
      final speciality = await _repo.getSpeciality(id);
      specialty = speciality;
      emit(SpecialitySuccess(speciality));
    } catch (e) {
      emit(SpecialityFailure(e.toString()));
    }
  }
}

class DocumentCubit extends Cubit<DocumentState> {
  final DocumentRepositoryImpl _repository;
  DocumentCubit(this._repository) : super(DocumentInitial());

  List<MedicalStaffDocument> documents = [];

  Future<void> getDocuments(String staffProfileId) async {
    emit(DocumentLoading());
    try {
      documents = await _repository.getDocuments(staffProfileId);
      emit(DocumentsLoaded(documents));
    } catch (e) {
      emit(DocumentFailure(e.toString()));
    }
  }

  Future<void> uploadDocument({
    required String staffProfileId,
    required String documentType,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    emit(DocumentLoading());
    try {
      final doc = await _repository.uploadDocument(
        staffProfileId: staffProfileId,
        documentType: documentType,
        fileName: fileName,
        fileBytes: fileBytes,
      );
      documents.add(doc);
      emit(DocumentUploadSuccess(doc));
      emit(DocumentsLoaded(documents));
    } catch (e) {
      emit(DocumentFailure(e.toString()));
    }
  }

  Future<void> deleteDocument(String documentId) async {
    emit(DocumentLoading());
    try {
      await _repository.deleteDocument(documentId);
      documents.removeWhere((element) => element.id == documentId);
      emit(DocumentDeleteSuccess(documentId));
      emit(DocumentsLoaded(documents));
    } catch (e) {
      emit(DocumentFailure(e.toString()));
    }
  }
}
