class MarketData {
  final String? symbol;
  final double? price;
  final double? change24h;
  final double? changePercent24h;
  final int? volume;

  MarketData({
    required this.symbol,
    required this.price,
    required this.change24h,
    required this.changePercent24h,
    required this.volume,
  });

  factory MarketData.fromJson(Map<String, dynamic> json) {
    return MarketData(
      symbol: json['symbol'],
      price: json['price'],
      change24h: json['change24h'],
      changePercent24h: json['changePercent24h'],
      volume: json['volume'],
    );
  }

  factory MarketData.fromWebSocketJson(Map<String, dynamic> json) {
    return MarketData(
      symbol: json['symbol'],
      price: _parseDouble(json['price']),
      change24h: _parseDouble(json['change24h']),
      changePercent24h: _parseDouble(json['changePercent24h']),
      volume: _parseInt(json['volume']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
