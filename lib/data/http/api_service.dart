import 'package:em_tth_assignment/data/http/dio_service.dart';
import 'package:em_tth_assignment/data/models.dart';
import 'package:em_tth_assignment/utils/constants.dart';

class ApiService {
  Future<CharacterInfoAndData> getCharacters({int page = 1}) async {
    final map = await DioService().get(ApiConstants.character, page);
    return CharacterInfoAndData.fromMap(map);
  }
}
