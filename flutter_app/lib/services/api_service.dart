import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pulsenow_flutter/utils/constants.dart';
import '../utils/exceptions.dart';

class ApiService {
  static const String baseUrl = AppConstants.baseUrl;
  static const Duration _timeoutDuration = Duration(seconds: 30);

  Future<List<Map<String, dynamic>>> getMarketData() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/market-data'))
          .timeout(_timeoutDuration, onTimeout: () {
        throw NetworkException.timeout();
      });

      if (response.statusCode != 200) {
        throw NetworkException.fromResponse(response);
      }

      final jsonData = json.decode(response.body);
      if (jsonData is! Map || jsonData['data'] is! List) {
        throw ParseException('Invalid response format');
      }

      return List<Map<String, dynamic>>.from(jsonData['data']);
    } on SocketException {
      throw NetworkException.noConnection();
    } on FormatException {
      throw ParseException('Failed to parse response');
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to load data: ${e.toString()}');
    }
  }
}
