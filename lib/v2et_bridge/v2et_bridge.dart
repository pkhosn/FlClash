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

abstract class V2etAuthGateway {
  Future<V2etSession> login({
    required Uri baseUrl,
    required String email,
    required String password,
  });

  Future<void> logout();
  Future<V2etSession?> restoreSession();
}

abstract class V2etSubscriptionGateway {
  Future<V2etSubscription> fetchSubscription();
}

abstract class V2etConnectivityGateway {
  Future<void> connect();
  Future<void> disconnect();
  Future<void> setProxyMode(V2etProxyMode mode);
  Future<V2etProxyMode> getProxyMode();
}

abstract class V2etBridge
    implements V2etAuthGateway, V2etSubscriptionGateway, V2etConnectivityGateway {}
