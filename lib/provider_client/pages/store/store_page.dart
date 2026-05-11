import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/v2et_bridge/v2et_bridge.dart';
import 'package:fl_clash/v2et_bridge/v2et_bridge_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/v2et_runtime_providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';

class V2ETStorePage extends ConsumerStatefulWidget {
  const V2ETStorePage({super.key});

  @override
  ConsumerState<V2ETStorePage> createState() => _V2ETStorePageState();
}

class _V2ETStorePageState extends ConsumerState<V2ETStorePage> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final offersAsync = ref.watch(v2etStoreOffersProvider);
    final offers = offersAsync.when(
      data: (data) => data,
      loading: () => const <V2etStoreOffer>[],
      error: (_, _) => const <V2etStoreOffer>[],
    );
    final visible = offers.where((p) {
      final hasOnetime = p.prices.keys.contains('onetime');
      if (tab == 1) return !hasOnetime;
      if (tab == 2) return hasOnetime;
      return true;
    }).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 730),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  V2ETSegmentButton(
                    label: '全部',
                    selected: tab == 0,
                    onTap: () => setState(() => tab = 0),
                  ),
                  const SizedBox(width: 10),
                  V2ETSegmentButton(
                    label: '常规套餐',
                    selected: tab == 1,
                    onTap: () => setState(() => tab = 1),
                  ),
                  const SizedBox(width: 10),
                  V2ETSegmentButton(
                    label: '一次性套餐',
                    selected: tab == 2,
                    onTap: () => setState(() => tab = 2),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (offersAsync.isLoading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                )
              else if (offersAsync.hasError)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('加载套餐失败: ${offersAsync.error}'),
                )
              else
                Wrap(
                  spacing: 18,
                  runSpacing: 18,
                  children: [
                    for (final offer in visible)
                      _OfferCard(
                        offer: offer,
                        onSubscribe: (period) => _startCheckout(offer, period),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startCheckout(V2etStoreOffer offer, String period) async {
    try {
      final bridge = ref.read(v2etBridgeProvider);
      final uri = await bridge.startCheckout(planId: offer.id, period: period);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已打开支付页面')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('打开支付窗口失败: $e')),
      );
    }
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer, required this.onSubscribe});
  final V2etStoreOffer offer;
  final ValueChanged<String> onSubscribe;

  @override
  Widget build(BuildContext context) {
    final prices = offer.prices.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final first = prices.isEmpty ? null : prices.first;
    final subscribePeriod = first?.key ?? 'month';
    return SizedBox(
      width: 352,
      child: V2ETCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              offer.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              first == null ? '--' : '¥${first.value.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            V2ETButton(
              label: '立即订阅',
              onPressed: () => onSubscribe(subscribePeriod),
              height: 40,
            ),
            const SizedBox(height: 12),
            for (final p in prices.take(4))
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(child: Text(p.key)),
                    Text('¥${p.value.toStringAsFixed(2)}'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
