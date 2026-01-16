import 'dart:convert';
import 'package:http/http.dart' as http;

/// Base exception class
abstract class AppException implements Exception {
  final String message;
  final String code;

  AppException(this.message, {this.code = 'UNKNOWN'});

  @override
  String toString() => message;
}

/// Network-related exceptions
class NetworkException extends AppException {
  NetworkException(String message, {super.code}) : super(message);

  factory NetworkException.fromResponse(http.Response response) {
    try {
      final jsonData = json.decode(response.body);
      if (jsonData is Map && jsonData['message'] != null) {
        return NetworkException(
          jsonData['message'].toString(),
          code: response.statusCode.toString(),
        );
      }
    } catch (_) {
      // Ignore parsing errors, use default message
    }
    return NetworkException(
      'Request failed with status ${response.statusCode}',
      code: response.statusCode.toString(),
    );
  }

  factory NetworkException.noConnection() {
    return NetworkException('No internet connection', code: 'NO_CONNECTION');
  }

  factory NetworkException.timeout() {
    return NetworkException('Request timed out', code: 'TIMEOUT');
  }
}

/// Data parsing exceptions
class ParseException extends AppException {
  ParseException(String message, {super.code = 'PARSE_ERROR'}) : super(message);
}

/// WebSocket-related exceptions
class WebSocketException extends AppException {
  WebSocketException(String message, {super.code = 'WEBSOCKET_ERROR'})
      : super(message);
}
