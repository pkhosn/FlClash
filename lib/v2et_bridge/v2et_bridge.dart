import 'package:flutter/foundation.dart';

enum V2etProxyMode { smart, global, tun }

@immutable
class V2etSession {
  const V2etSession({
    required this.baseUrl,
    required this.email,
    required this.accessToken,
  });

  final Uri baseUrl;
  final String email;
  final String accessToken;

  bool get hasToken => accessToken.trim().isNotEmpty;
}

@immutable
class V2etSubscription {
  const V2etSubscription({
    required this.subscriptionUrl,
    this.planName,
    this.expiredAt,
    this.transferEnableBytes,
    this.usedBytes,
  });

  final Uri subscriptionUrl;
  final String? planName;
  final DateTime? expiredAt;
  final int? transferEnableBytes;
  final int? usedBytes;
}

@immutable
class V2etStoreOffer {
  const V2etStoreOffer({
    required this.id,
    required this.name,
    required this.prices,
  });

  final int id;
  final String name;
  final Map<String, double> prices;
}

@immutable
class V2etOrder {
  const V2etOrder({
    required this.tradeNo,
    required this.status,
    required this.totalAmount,
    this.planName,
    this.createdAt,
  });

  final String tradeNo;
  final int status;
  final double totalAmount;
  final String? planName;
  final DateTime? createdAt;
}

@immutable
class V2etInviteData {
  const V2etInviteData({
    required this.codes,
    required this.commissionRate,
    required this.inviteCount,
    required this.totalCommission,
  });

  final List<String> codes;
  final double commissionRate;
  final int inviteCount;
  final double totalCommission;
}

@immutable
class V2etNotice {
  const V2etNotice({
    required this.id,
    required this.title,
    required this.content,
    this.createdAt,
  });

  final int id;
  final String title;
  final String content;
  final DateTime? createdAt;
}

abstract class V2etAuthGateway {
  Future<V2etSession> login({
    required Uri baseUrl,
    required String email,
    required String password,
  });

  Future<void> logout();
  Future<V2etSession?> restoreSession();
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}

abstract class V2etSubscriptionGateway {
  Future<V2etSubscription> fetchSubscription();
}

abstract class V2etStoreGateway {
  Future<List<V2etStoreOffer>> fetchStoreOffers();
  Future<List<V2etOrder>> fetchOrders();
  Future<Uri> startCheckout({
    required int planId,
    required String period,
    String? couponCode,
  });
}

abstract class V2etInviteGateway {
  Future<V2etInviteData> fetchInviteData();
}

abstract class V2etNoticeGateway {
  Future<List<V2etNotice>> fetchNotices();
}

abstract class V2etConnectivityGateway {
  Future<void> connect();
  Future<void> disconnect();
  Future<void> setProxyMode(V2etProxyMode mode);
  Future<V2etProxyMode> getProxyMode();
}

abstract class V2etBridge
    implements
        V2etAuthGateway,
        V2etSubscriptionGateway,
        V2etStoreGateway,
        V2etInviteGateway,
        V2etNoticeGateway,
        V2etConnectivityGateway {}
