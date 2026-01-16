import 'dart:convert';
import 'package:pulsenow_flutter/models/market_data_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _cacheKey = 'market_data_cache';

  /// Save market data to cache
  Future<void> saveMarketData(List<MarketData> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = data.map((item) => item.toJson()).toList();
      await prefs.setString(_cacheKey, json.encode(jsonList));
    } catch (e) {
      // Silently fail cache writes
    }
  }

  /// Load market data from cache
  Future<List<MarketData>> loadMarketData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      if (cachedJson != null) {
        final jsonList = json.decode(cachedJson) as List;
        return jsonList.map((json) => MarketData.fromJson(json)).toList();
      }
    } catch (e) {
      // Return empty list if cache read fails
    }
    return [];
  }

  /// Clear cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
    } catch (e) {
      // Silently fail cache clear
    }
  }
}
