import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pulsenow_flutter/models/market_data_model.dart';
import 'package:pulsenow_flutter/utils/layout.dart';
import '../providers/market_data_provider.dart';

class MarketDataScreen extends StatefulWidget {
  const MarketDataScreen({super.key});

  @override
  State<MarketDataScreen> createState() => _MarketDataScreenState();
}

class _MarketDataScreenState extends State<MarketDataScreen> {
  final provider = MarketDataProvider();
  @override
  void initState() {
    super.initState();
    provider.init();
  }

  @override
  void dispose() {
    provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: provider,
      child: Consumer<MarketDataProvider>(
        builder: (context, provider, child) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Builder(
              key: ValueKey('${provider.isLoading}-${provider.error}'),
              builder: (context) {
                if (provider.isLoading) {
                  return const Center(
                    key: ValueKey('loading'),
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.error != null) {
                  return Center(
                    key: const ValueKey('error'),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            provider.errorCode == 'NO_CONNECTION'
                                ? Icons.wifi_off
                                : Icons.error_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            provider.error!,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => provider.loadMarketData(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => provider.loadMarketData(silent: true),
                  child: ListView.separated(
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                    ),
                    itemCount: provider.marketData.length,
                    itemBuilder: (context, index) {
                      return _MarketDataItem(item: provider.marketData[index]);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _MarketDataItem extends StatelessWidget {
  final MarketData item;

  const _MarketDataItem({required this.item});

  @override
  Widget build(BuildContext context) {
    Color textColor = Colors.black;
    if (item.change24h != null) {
      final isPositive = item.change24h! >= 0.0;
      textColor = isPositive ? Colors.green : Colors.red;
    }

    return ListTile(
      key: ValueKey(item.symbol),
      title: Text(item.symbol ?? '-'),
      subtitle: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        layoutBuilder: centerLeftLayoutBuilder,
        child: Text(
          key: ValueKey(item.price),
          item.price != null
              ? NumberFormat.currency(symbol: '\$', decimalDigits: 2)
                  .format(item.price!)
              : '-',
          style: TextStyle(color: textColor),
        ),
      ),
      trailing: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        layoutBuilder: centerRightLayoutBuilder,
        child: Text(
          key: ValueKey(item.change24h),
          item.change24h != null
              ? '${item.change24h!.toStringAsFixed(2)}%'
              : '-',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
