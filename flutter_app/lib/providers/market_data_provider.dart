import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pulsenow_flutter/services/websocket_service.dart';
import '../services/api_service.dart';
import '../models/market_data_model.dart';
import '../utils/exceptions.dart';

class MarketDataProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final WebSocketService _webSocketService = WebSocketService();

  List<MarketData> _marketData = [];
  bool _isLoading = false;
  String? _error;
  String? _errorCode;
  StreamSubscription<Map<String, dynamic>>? _webSocketSubscription;

  List<MarketData> get marketData => _marketData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get errorCode => _errorCode;

  void init() {
    _connectWebSocket();
    loadMarketData();
  }

  Future<void> loadMarketData({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
    }

    _error = null;
    _errorCode = null;
    notifyListeners();

    try {
      final data = await _apiService.getMarketData();
      _marketData = data.map((json) => MarketData.fromJson(json)).toList();
    } on AppException catch (e) {
      _error = e.message;
      _errorCode = e.code;
    } catch (e) {
      _error = 'Failed to load data: ${e.toString()}';
      _errorCode = 'UNKNOWN';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _connectWebSocket() {
    _webSocketService.connect();
    _webSocketSubscription = _webSocketService.stream?.listen((message) {
      try {
        if (message['type'] == 'market_update' && message['data'] != null) {
          final data = MarketData.fromWebSocketJson(message['data']);
          if (data.symbol != null) {
            final index =
                _marketData.indexWhere((item) => item.symbol == data.symbol);
            if (index != -1) {
              _marketData[index] = data;
            } else {
              _marketData.add(data);
            }
            notifyListeners();
          }
        }
      } catch (e) {
        debugPrint('Error processing WebSocket message: $e');
      }
    });
  }

  @override
  void dispose() {
    _webSocketSubscription?.cancel();
    _webSocketService.disconnect();
    super.dispose();
  }
}
