// Sign Up States
abstract class SignUpState {}

class SignUpInitial extends SignUpState {}

class SignUpLoading extends SignUpState {}

class SignUpSuccess extends SignUpState {
  final String message;
  SignUpSuccess({required this.message});
}

class SignUpError extends SignUpState {
  final String error;
  SignUpError({required this.error});
}

class MedicalProfileSaving extends SignUpState {}

class MedicalProfileSuccess extends SignUpState {
  final String userId;
  MedicalProfileSuccess({required this.userId});
}

class MedicalProfileError extends SignUpState {
  final String error;
  MedicalProfileError({required this.error});
}

// Login States
abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String userId;
  final String role;
  final String message;
  LoginSuccess({
    required this.userId,
    required this.role,
    required this.message,
  });
}

class LoginError extends LoginState {
  final String error;
  LoginError({required this.error});
}

// logout states
abstract class LogoutState {}

class LogoutInitial extends LogoutState {}

class LogoutLoading extends LogoutState {}

class LogoutSuccess extends LogoutState {
  final String message;
  LogoutSuccess({required this.message});
}

class LogoutError extends LogoutState {
  final String error;
  LogoutError({required this.error});
}