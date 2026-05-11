import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/v2et_bridge/v2et_bridge.dart';
import 'package:fl_clash/v2et_bridge/v2et_bridge_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/v2et_runtime_providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_notice.dart';

class V2ETStorePage extends ConsumerStatefulWidget {
  const V2ETStorePage({super.key});

  @override
  ConsumerState<V2ETStorePage> createState() => _V2ETStorePageState();
}

class _V2ETStorePageState extends ConsumerState<V2ETStorePage> {
  bool _submitting = false;
  bool _cancelPayPolling = false;
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
    final selected = await _showCheckoutDialog(offer, period);
    if (selected == null) return;
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final bridge = ref.read(v2etBridgeProvider);
      final method = await _pickPaymentMethod(bridge);
      if (method == null) return;
      final uri = await bridge.startCheckout(
        planId: offer.id,
        period: selected.period,
        method: method.id,
        couponCode: selected.couponCode,
      );
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      final result = await _waitOrderPaid(bridge);
      if (!mounted) return;
      if (result == _PayResult.paid) {
        ref.invalidate(v2etSubscriptionProvider);
        ref.invalidate(v2etStoreOffersProvider);
        V2ETNotice.success(context, '支付成功，套餐已刷新');
      } else if (result == _PayResult.timeout) {
        V2ETNotice.info(context, '支付确认超时，请稍后在订单中确认');
      } else {
        V2ETNotice.info(context, '已打开支付页面，请完成支付后重试');
      }
    } catch (e) {
      if (!mounted) return;
      V2ETNotice.error(context, '打开支付窗口失败: $e');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<_CheckoutSelection?> _showCheckoutDialog(
    V2etStoreOffer offer,
    String period,
  ) {
    return showDialog<_CheckoutSelection>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _CheckoutDialog(offer: offer, initialPeriod: period),
    );
  }

  Future<V2etPaymentMethod?> _pickPaymentMethod(V2etBridge bridge) async {
    final methods = await bridge.fetchPaymentMethods();
    if (!mounted) return null;
    if (methods.isEmpty) {
      V2ETNotice.error(context, '未获取到可用支付方式');
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
    _cancelPayPolling = false;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PaymentCheckingDialog(
        onCancel: () {
          _cancelPayPolling = true;
          Navigator.of(context, rootNavigator: true).pop();
        },
      ),
    );
    var hadPending = false;
    for (var i = 0; i < 60; i++) {
      if (_cancelPayPolling) return _PayResult.pending;
      await Future<void>.delayed(const Duration(seconds: 3));
      if (_cancelPayPolling) return _PayResult.pending;
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
  const _PaymentCheckingDialog({required this.onCancel});
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
            const SizedBox(height: 14),
            const Text('正在确认支付状态...'),
            const SizedBox(height: 14),
            TextButton(onPressed: onCancel, child: const Text('取消')),
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
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1D2433),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  first == null ? '--' : '¥${first.value.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1D2433),
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    first == null ? '' : '/${_periodLabelUnit(first.key)}',
                    style: const TextStyle(
                      fontSize: 12,
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
                    Expanded(
                      child: Text(
                        _periodLabel(p.key),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF303643),
                        ),
                      ),
                    ),
                    Text(
                      '¥${p.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF303643),
                      ),
                    ),
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
                      fontSize: 13,
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
          if (item is Map) {
            final line = _lineFromFeatureMap(item);
            if (line.isNotEmpty) {
              out.add(line);
              continue;
            }
            final v = _lineFromGenericMap(item, strict: true);
            if (v.isNotEmpty) out.add(v);
            continue;
          }
          final v = '$item'.trim();
          if (v.isNotEmpty) out.add(v);
        }
      } else if (decoded is Map) {
        final line = _lineFromFeatureMap(decoded);
        if (line.isNotEmpty) out.add(line);
        final v = _lineFromGenericMap(decoded, strict: true);
        if (v.isNotEmpty && !out.contains(v)) out.add(v);
      }
      return out;
    } catch (_) {
      return const [];
    }
  }

  String _lineFromFeatureMap(Map map) {
    final feature = '${map['feature'] ?? ''}'.trim();
    if (feature.isEmpty) return '';
    final support = map['support'];
    if (support is bool) {
      return support ? feature : '不支持：$feature';
    }
    final supportText = '${support ?? ''}'.trim().toLowerCase();
    if (supportText == 'false' || supportText == '0') {
      return '不支持：$feature';
    }
    return feature;
  }

  String _lineFromGenericMap(Map map, {bool strict = false}) {
    if (strict) {
      const allowed = {'title', 'name', 'desc', 'description', 'value', 'text'};
      final hasAllowed = map.keys.any((k) => allowed.contains('$k'.toLowerCase()));
      if (!hasAllowed) return '';
    }
    final pairs = <String>[];
    map.forEach((key, value) {
      final keyText = '$key'.toLowerCase();
      if (keyText == 'support') return;
      if (strict &&
          keyText != 'title' &&
          keyText != 'name' &&
          keyText != 'desc' &&
          keyText != 'description' &&
          keyText != 'value' &&
          keyText != 'text') {
        return;
      }
      final v = '${value ?? ''}'.trim();
      if (v.isNotEmpty) pairs.add(v);
    });
    return pairs.join(' ');
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

class _CheckoutDialog extends StatefulWidget {
  const _CheckoutDialog({required this.offer, required this.initialPeriod});
  final V2etStoreOffer offer;
  final String initialPeriod;

  @override
  State<_CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<_CheckoutDialog> {
  late String _period;
  final TextEditingController _couponController = TextEditingController();
  String? _couponError;
  bool _couponApplying = false;
  double? _couponDiscount;
  double? _couponFinal;

  @override
  void initState() {
    super.initState();
    _period = widget.offer.prices.containsKey(widget.initialPeriod)
        ? widget.initialPeriod
        : widget.offer.prices.keys.first;
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prices = widget.offer.prices.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final payAmount = widget.offer.prices[_period] ?? 0.0;
    final finalAmount = _couponFinal ?? payAmount;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      backgroundColor: const Color(0xFFF2F5FA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 820,
        height: 700,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        '购买套餐',
                        style: TextStyle(fontSize: 30 / 2, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              Text(
                widget.offer.name,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4B5563),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 52,
                      child: ListView.separated(
                        itemCount: prices.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final item = prices[i];
                          final selected = item.key == _period;
                          return _CheckoutPeriodTile(
                            selected: selected,
                            title: _periodLabel(item.key),
                            price: item.value,
                            onTap: () => setState(() => _period = item.key),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 48,
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE3E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '套餐特性',
                              style: TextStyle(fontSize: 29 / 2, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: _CheckoutFeatureTile(
                                    icon: Icons.wifi_tethering_rounded,
                                    label: '流量',
                                    value: _fmtBytes(widget.offer.transferEnableBytes),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _CheckoutFeatureTile(
                                    icon: Icons.devices_rounded,
                                    label: '设备',
                                    value: widget.offer.deviceLimit > 0
                                        ? '${widget.offer.deviceLimit}台'
                                        : '不限',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _CheckoutFeatureTile(
                                    icon: Icons.speed_rounded,
                                    label: '速率',
                                    value: widget.offer.speedLimitMbps > 0
                                        ? '${widget.offer.speedLimitMbps}Mbps'
                                        : '不限速',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(height: 1),
                            const SizedBox(height: 16),
                            const Text(
                              '优惠券：',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _couponController,
                                    decoration: InputDecoration(
                                      hintText: '请输入优惠券代码',
                                      filled: true,
                                      fillColor: const Color(0xFFF3F4F6),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFF5B8DEF)),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 84,
                                  height: 46,
                                  child: ElevatedButton(
                                    onPressed: _couponApplying ? null : _applyCoupon,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF5B8DEF),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('应用'),
                                  ),
                                ),
                              ],
                            ),
                            if ((_couponError ?? '').isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                _couponError!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFDC2626),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                            if (_couponDiscount != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                '优惠已应用 -¥${_couponDiscount!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF059669),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                            const Spacer(),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    '原价',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF4B5563),
                                    ),
                                  ),
                                ),
                                Text(
                                  '¥${payAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF4B5563),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    '实付金额',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                                  ),
                                ),
                                Text(
                                  '¥${finalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 34 / 2,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF27B489),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 130,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  SizedBox(
                    width: 260,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(
                        _CheckoutSelection(
                          period: _period,
                          couponCode: _couponController.text.trim().isEmpty
                              ? null
                              : _couponController.text.trim(),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B8DEF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: const Text('确认购买'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
      case 'reset':
        return '重置流量';
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

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _couponError = '请输入优惠券代码';
        _couponDiscount = null;
        _couponFinal = null;
      });
      return;
    }
    setState(() {
      _couponApplying = true;
      _couponError = null;
      _couponDiscount = null;
      _couponFinal = null;
    });
    try {
      if (!mounted) return;
      setState(() {
        _couponError = '优惠券代码已保存，确认购买时生效';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _couponError = '优惠券不可用: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _couponApplying = false;
        });
      }
    }
  }
}

class _CheckoutSelection {
  const _CheckoutSelection({required this.period, this.couponCode});
  final String period;
  final String? couponCode;
}

class _CheckoutPeriodTile extends StatelessWidget {
  const _CheckoutPeriodTile({
    required this.selected,
    required this.title,
    required this.price,
    required this.onTap,
  });
  final bool selected;
  final String title;
  final double price;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 74,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF5B8DEF) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? const Color(0xFF5B8DEF) : const Color(0xFFE3E8F0),
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? const Color(0xFF7CE08F) : const Color(0xFFD1D5DB),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: selected ? Colors.white : const Color(0xFF111827),
                  ),
                ),
              ),
              Text(
                '¥${price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 30 / 2,
                  fontWeight: FontWeight.w900,
                  color: selected ? Colors.white : const Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckoutFeatureTile extends StatelessWidget {
  const _CheckoutFeatureTile({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF3BAA62), size: 20),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1D2433),
            ),
          ),
        ],
      ),
    );
  }
}
