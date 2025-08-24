import 'package:dio/dio.dart';
import 'package:em_tth_assignment/data/models.dart';
import 'package:em_tth_assignment/main.dart';
import 'package:em_tth_assignment/utils/constants.dart';

class ApiService {
  Future<CharacterInfoAndData> getCharacters({int page = 1}) async {
    final map = await DioService().get(ApiConstants.character, page);
    return CharacterInfoAndData.fromMap(map);
  }
}

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
