import 'dart:convert';

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
  bool _submitting = false;
  @override
  Widget build(BuildContext context) {
    final offersAsync = ref.watch(v2etStoreOffersProvider);
    final offers = offersAsync.when(
      data: (data) => data,
      loading: () => const <V2etStoreOffer>[],
      error: (_, _) => const <V2etStoreOffer>[],
    );
    final visible = offers.where((p) => p.show || p.renew).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 730),
          child: Column(
            children: [
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
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final bridge = ref.read(v2etBridgeProvider);
      final method = await _pickPaymentMethod(bridge);
      if (method == null) return;
      final uri = await bridge.startCheckout(
        planId: offer.id,
        period: period,
        method: method.id,
      );
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      final result = await _waitOrderPaid(bridge);
      if (!mounted) return;
      if (result == _PayResult.paid) {
        ref.invalidate(v2etSubscriptionProvider);
        ref.invalidate(v2etStoreOffersProvider);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('支付成功，套餐已刷新')));
      } else if (result == _PayResult.timeout) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('支付确认超时，请稍后在订单中确认')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已打开支付页面，请完成支付后重试')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('打开支付窗口失败: $e')));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<V2etPaymentMethod?> _pickPaymentMethod(V2etBridge bridge) async {
    final methods = await bridge.fetchPaymentMethods();
    if (!mounted) return null;
    if (methods.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('未获取到可用支付方式')));
      return null;
    }
    if (methods.length == 1) return methods.first;
    return showDialog<V2etPaymentMethod>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('选择支付方式'),
          content: SizedBox(
            width: 340,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final m in methods)
                  ListTile(
                    title: Text(m.name),
                    onTap: () => Navigator.of(context).pop(m),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<_PayResult> _waitOrderPaid(V2etBridge bridge) async {
    if (!mounted) return _PayResult.pending;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _PaymentCheckingDialog(),
    );
    var hadPending = false;
    for (var i = 0; i < 60; i++) {
      await Future<void>.delayed(const Duration(seconds: 3));
      try {
        final orders = await bridge.fetchOrders();
        final pending = orders.where((e) => e.status == 0).toList();
        if (pending.isEmpty) {
          if (!mounted) return _PayResult.pending;
          Navigator.of(context, rootNavigator: true).pop();
          return hadPending ? _PayResult.paid : _PayResult.pending;
        }
        hadPending = true;
        var anyPaid = false;
        for (final order in pending) {
          final paid = await bridge.checkOrderPaid(order.tradeNo);
          if (paid) {
            anyPaid = true;
            break;
          }
        }
        if (anyPaid) {
          if (!mounted) return _PayResult.pending;
          Navigator.of(context, rootNavigator: true).pop();
          return _PayResult.paid;
        }
      } catch (_) {
        // ignore one-shot polling errors
      }
    }
    if (!mounted) return _PayResult.timeout;
    Navigator.of(context, rootNavigator: true).pop();
    return _PayResult.timeout;
  }
}

enum _PayResult { paid, pending, timeout }

class _PaymentCheckingDialog extends StatelessWidget {
  const _PaymentCheckingDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
            SizedBox(height: 14),
            Text('正在确认支付状态...'),
          ],
        ),
      ),
    );
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
    final detailLines = _parsePlanDetails(offer.content);
    return SizedBox(
      width: 352,
      child: V2ETCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              offer.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 31 / 2,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  first == null ? '--' : '¥${first.value.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 47 / 2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    first == null ? '' : '/${_periodLabelUnit(first.key)}',
                    style: const TextStyle(
                      fontSize: 15 / 2,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            V2ETButton(
              label: '立即订阅',
              onPressed: () => onSubscribe(subscribePeriod),
              height: 38,
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _Metric(
                      label: '流量',
                      value: _fmtBytes(offer.transferEnableBytes),
                    ),
                  ),
                  Expanded(
                    child: _Metric(
                      label: '速率',
                      value: offer.speedLimitMbps > 0
                          ? '${offer.speedLimitMbps} Mbps'
                          : '不限速',
                    ),
                  ),
                  Expanded(
                    child: _Metric(
                      label: '设备',
                      value: offer.deviceLimit > 0
                          ? '${offer.deviceLimit}'
                          : '不限',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            for (final p in prices.skip(1))
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(child: Text(_periodLabel(p.key))),
                    Text('¥${p.value.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            if (detailLines.isNotEmpty) ...[
              const SizedBox(height: 6),
              const Divider(height: 1),
              const SizedBox(height: 10),
              for (final line in detailLines)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    line,
                    style: const TextStyle(
                      fontSize: 14 / 2,
                      height: 1.35,
                      color: Color(0xFF4B5563),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  String _periodLabelUnit(String key) {
    switch (key) {
      case 'month':
        return '月';
      case 'quarter':
        return '季';
      case 'half_year':
        return '半年';
      case 'year':
        return '年';
      case 'two_year':
        return '两年';
      case 'three_year':
        return '三年';
      case 'onetime':
        return '一次性';
      case 'reset':
        return '重置包';
      default:
        return key;
    }
  }

  String _periodLabel(String key) {
    switch (key) {
      case 'month':
        return '月付';
      case 'quarter':
        return '季付';
      case 'half_year':
        return '半年付';
      case 'year':
        return '年付';
      case 'two_year':
        return '两年付';
      case 'three_year':
        return '三年付';
      case 'onetime':
        return '一次性';
      case 'reset':
        return '重置流量包';
      default:
        return key;
    }
  }

  String _fmtBytes(int bytes) {
    if (bytes <= 0) return '--';
    const unit = ['B', 'KB', 'MB', 'GB', 'TB'];
    double value = bytes.toDouble();
    int idx = 0;
    while (value >= 1024 && idx < unit.length - 1) {
      value /= 1024;
      idx++;
    }
    return '${value.toStringAsFixed(idx == 0 ? 0 : 1)} ${unit[idx]}';
  }

  List<String> _parsePlanDetails(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return const [];
    final fromJson = _fromJson(text);
    if (fromJson.isNotEmpty) return fromJson;
    final fromHtml = _fromHtml(text);
    if (fromHtml.isNotEmpty) return fromHtml;
    return _fromMarkdown(text);
  }

  List<String> _fromJson(String text) {
    try {
      final decoded = json.decode(text);
      final out = <String>[];
      if (decoded is List) {
        for (final item in decoded) {
          final v = '$item'.trim();
          if (v.isNotEmpty) out.add(v);
        }
      } else if (decoded is Map) {
        for (final entry in decoded.entries) {
          final v = '${entry.value}'.trim();
          if (v.isNotEmpty) out.add(v);
        }
      }
      return out;
    } catch (_) {
      return const [];
    }
  }

  List<String> _fromHtml(String text) {
    if (!RegExp(r'<[a-zA-Z/][^>]*>').hasMatch(text)) return const [];
    var s = text
        .replaceAll(RegExp(r'<\s*br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(
          RegExp(r'</\s*(p|div|li|h[1-6])\s*>', caseSensitive: false),
          '\n',
        )
        .replaceAll(RegExp(r'<[^>]*>'), '');
    s = s
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    return s
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  List<String> _fromMarkdown(String text) {
    return text
        .split('\n')
        .map(
          (e) => e
              .replaceFirst(RegExp(r'^\s*[-*+]\s*'), '')
              .replaceAll(RegExp(r'[`#>*_]+'), '')
              .trim(),
        )
        .where((e) => e.isNotEmpty)
        .toList();
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F4),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
