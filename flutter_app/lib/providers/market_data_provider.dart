import 'package:flutter/foundation.dart';
import 'package:pulsenow_flutter/services/websocket_service.dart';
import '../services/api_service.dart';
import '../models/market_data_model.dart';

class MarketDataProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final WebSocketService _webSocketService = WebSocketService();

  List<MarketData> _marketData = [];
  bool _isLoading = false;
  String? _error;

  List<MarketData> get marketData => _marketData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void init() {
    // Load initial market data and connect to WebSocket
    _connectWebSocket();
    loadMarketData();
  }

  Future<void> loadMarketData({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
    }

    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getMarketData();
      _marketData = data.map((json) => MarketData.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _connectWebSocket() {
    _webSocketService.connect();

    _webSocketService.stream?.listen((message) {
      try {
        if (message['type'] == 'market_update') {
          final data = MarketData.fromWebSocketJson(message['data']);
          final index =
              _marketData.indexWhere((item) => item.symbol == data.symbol);
          if (index != -1) {
            _marketData[index] = data;
          } else {
            _marketData.add(data);
          }
          notifyListeners();
        }
      } catch (e) {
        // Ignore
        debugPrint('Error parsing WebSocket message: $e');
      }
    });
  }

  @override
  void dispose() {
    _webSocketService.disconnect();
    super.dispose();
  }
}
