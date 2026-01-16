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
}
