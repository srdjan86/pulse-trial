import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pulsenow_flutter/utils/exceptions.dart';

abstract class BaseApiService {
  static const Duration _timeoutDuration = Duration(seconds: 30);

  /// Base GET request with error handling
  Future<Map<String, dynamic>> get(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeoutDuration,
          onTimeout: () {
        throw NetworkException.timeout();
      });

      if (response.statusCode != 200) {
        throw NetworkException.fromResponse(response);
      }

      final jsonData = json.decode(response.body);
      if (jsonData is! Map<String, dynamic>) {
        throw ParseException('Invalid response format');
      }

      return jsonData;
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
