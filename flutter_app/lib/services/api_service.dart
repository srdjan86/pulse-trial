import 'package:pulsenow_flutter/utils/constants.dart';
import '../utils/exceptions.dart';
import 'base_api_service.dart';

class ApiService extends BaseApiService {
  static const String baseUrl = AppConstants.baseUrl;

  Future<List<Map<String, dynamic>>> getMarketData() async {
    final response = await get('$baseUrl/market-data');

    if (response['data'] is! List) {
      throw ParseException('Invalid data format');
    }

    return List<Map<String, dynamic>>.from(response['data']);
  }
}
