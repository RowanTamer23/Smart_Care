import '../api/end_points.dart';

class ErrorModel {
  final String status;
  final String errorMessage;

  ErrorModel({required this.status, required this.errorMessage});
  factory ErrorModel.formJson(Map<String, dynamic> jsonData) {
    String message = jsonData[ApiKeys.message]?.toString() ?? 'حدث خطأ غير متوقع';
    
    // Translate Laravel MySQL errors dynamically
    if (message.contains('Duplicate entry')) {
      if (message.contains('students_email_unique') || message.contains('email')) {
        message = 'البريد الإلكتروني مسجل مسبقاً.';
      } else if (message.contains('students_student_phone_unique') || message.contains('phone')) {
        message = 'رقم الهاتف مسجل مسبقاً.';
      } else {
        message = 'هذه البيانات مسجلة مسبقاً بالحساب.';
      }
    }

    return ErrorModel(
      status: jsonData[ApiKeys.status]?.toString() ?? 'Error',
      errorMessage: message,
    );
  }
}