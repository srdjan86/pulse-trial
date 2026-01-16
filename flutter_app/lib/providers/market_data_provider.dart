import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pulsenow_flutter/models/market_data_model.dart';
import 'package:pulsenow_flutter/services/api_service.dart';
import 'package:pulsenow_flutter/services/cache_service.dart';
import 'package:pulsenow_flutter/services/websocket_service.dart';
import 'package:pulsenow_flutter/utils/exceptions.dart';

class MarketDataProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final WebSocketService _webSocketService = WebSocketService();
  final CacheService _cacheService = CacheService();

  List<MarketData> _marketData = [];
  bool _isLoading = false;
  String? _error;
  String? _errorCode;
  // Used to show a snackbar message to the user when an error occurs
  // but we still have the data in the cache.
  String? _snackbarMessage;
  StreamSubscription<Map<String, dynamic>>? _webSocketSubscription;

  List<MarketData> get marketData => _marketData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get errorCode => _errorCode;
  String? get snackbarMessage => _snackbarMessage;

  void init() {
    _loadCachedData();
    _connectWebSocket();
    loadMarketData();
  }

  Future<void> _loadCachedData() async {
    final cachedData = await _cacheService.loadMarketData();
    if (cachedData.isNotEmpty) {
      _marketData = cachedData;
      notifyListeners();
    }
  }

  Future<void> loadMarketData({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
    }

    _error = null;
    _errorCode = null;
    _snackbarMessage = null;
    notifyListeners();

    try {
      final data = await _apiService.getMarketData();
      _marketData = data.map((json) => MarketData.fromJson(json)).toList();
      // In real-world application, this would happen in repository layer
      _cacheService.saveMarketData(_marketData);
    } on AppException catch (e) {
      if (_marketData.isEmpty) {
        _error = e.message;
        _errorCode = e.code;
      } else {
        _snackbarMessage = e.message;
      }
    } catch (e) {
      if (_marketData.isEmpty) {
        _error = 'Failed to load data: ${e.toString()}';
        _errorCode = 'UNKNOWN';
      } else {
        _snackbarMessage = 'Failed to load data: ${e.toString()}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSnackbarMessage() {
    _snackbarMessage = null;
    notifyListeners();
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
            _cacheService.saveMarketData(_marketData);
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
