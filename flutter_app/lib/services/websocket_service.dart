import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../utils/constants.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _controller;
  StreamSubscription? _subscription;

  Stream<Map<String, dynamic>>? get stream => _controller?.stream;

  void connect() {
    try {
      _controller = StreamController<Map<String, dynamic>>.broadcast();
      _channel = WebSocketChannel.connect(Uri.parse(AppConstants.wsUrl));

      _subscription = _channel!.stream.listen(
        (message) {
          try {
            final decoded = json.decode(message);
            if (decoded is Map<String, dynamic>) {
              _controller?.add(decoded);
            }
          } catch (e) {
            debugPrint('WebSocket parse error: $e');
          }
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
        },
      );
    } catch (e) {
      debugPrint('WebSocket connection failed: $e');
    }
  }

  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    _controller?.close();
    _controller = null;
    _channel = null;
    _subscription = null;
  }
}
