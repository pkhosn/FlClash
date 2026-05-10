import 'package:fl_clash/v2et_bridge/v2et_bridge.dart';
import 'package:fl_clash/v2et_bridge/v2et_bridge_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final v2etSubscriptionProvider = FutureProvider<V2etSubscription>((ref) async {
  final bridge = ref.watch(v2etBridgeProvider);
  return bridge.fetchSubscription();
});

final v2etStoreOffersProvider = FutureProvider<List<V2etStoreOffer>>((
  ref,
) async {
  final bridge = ref.watch(v2etBridgeProvider);
  return bridge.fetchStoreOffers();
});

final v2etNoticesProvider = FutureProvider<List<V2etNotice>>((ref) async {
  final bridge = ref.watch(v2etBridgeProvider);
  return bridge.fetchNotices();
});

final v2etInviteProvider = FutureProvider<V2etInviteData>((ref) async {
  final bridge = ref.watch(v2etBridgeProvider);
  return bridge.fetchInviteData();
});

final v2etProxyModeProvider = FutureProvider<V2etProxyMode>((ref) async {
  final bridge = ref.watch(v2etBridgeProvider);
  return bridge.getProxyMode();
});

