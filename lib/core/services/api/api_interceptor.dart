import 'package:dio/dio.dart';

class ApiInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // final token = CacheHelper.sharedPreferences.get(ApiKeys.token);
    options.headers['accept'] = 'application/json';
    super.onRequest(options, handler);
  }
}
