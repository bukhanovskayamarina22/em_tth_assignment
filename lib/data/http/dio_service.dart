import 'package:dio/dio.dart';
import 'package:em_tth_assignment/main.dart';
import 'package:em_tth_assignment/utils/constants.dart';

class DioService {
  factory DioService() {
    return _instance;
  }
  DioService._privateConstructor();

  static final DioService _instance = DioService._privateConstructor();

  final Dio _dio = Dio();

  Future<Map<String, dynamic>> get(String endpoint, int page) async {
    try {
      final response = await _dio.get('${ApiConstants.api}$endpoint${ApiConstants.pageParameter}$page');
      return response.data;
    } catch (error, stack) {
      logger.e('''
         Error in DioService.get: 
         Error: $error,
         Stack: $stack,
         Parameters:
            endpoint: $endpoint,
            page: $page
         Response: $Response''');
      rethrow;
    }
  }
}
