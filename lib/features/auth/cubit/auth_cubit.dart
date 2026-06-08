import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_care/core/services/api/end_points.dart';
import 'package:smart_care/features/auth/cubit/auth_state.dart';
import 'package:smart_care/features/auth/data/repository/auth_repo.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit(this.authRepository) : super(SignUpInitial());

  final AuthRepository authRepository;

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final licenseCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  List<Map<String, dynamic>> specialtiesList = [];
  String? selectedSpecialtyName; // Stores the name chosen by the user

  String? signedUpUserId;

  // CALL THIS when your widget initializes (e.g., in initState)
  Future<void> loadSpecialties() async {
    try {
      final list = await authRepository.getSpecialties();
      specialtiesList = list;
      emit(
          SignUpInitial()); // Re-emit initial or a specific SpecialtiesLoaded state if preferred
    } catch (e) {
      emit(SignUpError(error: e.toString()));
    }
  }

  // CALL THIS when the user selects an item from the dropdown
  void selectSpecialty(String? value) {
    selectedSpecialtyName = value;
  }
  // Stored after signUp so the profile step can use it

  Future<void> signUp({
    required String role,
  }) async {
    emit(SignUpLoading());
    try {
      final result = await authRepository.signUp(
        name: nameCtrl.text,
        email: emailCtrl.text,
        phone: phoneCtrl.text,
        password: passCtrl.text,
        role: role,
      );
      signedUpUserId = result.userId;
      emit(SignUpSuccess(message: 'User created successfully'));
    } catch (e) {
      emit(SignUpError(error: e.toString()));
    }
  }

  Future<void> saveMedicalStaffProfile({
    required String staffType,
    String? specialtyId,
    int? yearsExperience,
    String? gender,
    String? country,
    String? city,
    String? bio,
    double? consultationFee,
    int? appointmentDurationMinutes,
    bool supportsInPerson = false,
    bool supportsVideo = false,
    bool supportsHomeVisit = false,
    List<String> languages = const [],
    String? licenseNumber,
  }) async {
    final userId = signedUpUserId;
    if (userId == null) {
      emit(MedicalProfileError(
          error: 'No signed-up user found. Please register first.'));
      return;
    }
    emit(MedicalProfileSaving());
    try {
      await authRepository.saveMedicalStaffProfile(
        profileId: userId,
        staffType: staffType,
        specialtyId: specialtyId,
        yearsExperience: yearsExperience,
        gender: gender,
        country: country,
        city: city,
        bio: bio,
        consultationFee: consultationFee,
        appointmentDurationMinutes: appointmentDurationMinutes,
        supportsInPerson: supportsInPerson,
        supportsVideo: supportsVideo,
        supportsHomeVisit: supportsHomeVisit,
        languages: languages,
        licenseNumber: licenseCtrl.text,
      );
      emit(MedicalProfileSuccess(userId: userId));
    } catch (e) {
      emit(MedicalProfileError(error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    licenseCtrl.dispose();
    passCtrl.dispose();
    return super.close();
  }
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this.authRepository) : super(LoginInitial());
  final AuthRepository authRepository;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(LoginLoading());
    try {
      final response = await authRepository.login(
        email: email,
        password: password,
      );
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(ApiKeys.userIdKey, response.userId);
      prefs.setString(ApiKeys.roleKey, response.role);
      emit(LoginSuccess(
        userId: response.userId,
        role: response.role,
        message: 'User logged in successfully',
      ));
    } catch (e) {
      emit(LoginError(error: e.toString()));
    }
  }
}

class LogoutCubit extends Cubit<LogoutState> {
  LogoutCubit(this.authRepository) : super(LogoutInitial());
  final AuthRepository authRepository;

  Future<void> logout() async {
    emit(LogoutLoading());
    try {
      await authRepository.logout();
      emit(LogoutSuccess(
        message: 'User logged out successfully',
      ));
    } catch (e) {
      emit(LogoutError(error: e.toString()));
    }
  }
}
