import 'v2et_bridge.dart';

/// Stage-1 placeholder implementation.
///
/// In Stage-2 this will be bound to FlClash managers/providers
/// and V2ET panel APIs.
class FlClashV2etBridge implements V2etBridge {
  V2etProxyMode _mode = V2etProxyMode.smart;

  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {}

  @override
  Future<V2etSubscription> fetchSubscription() {
    throw UnimplementedError('Stage-2: bind V2ET subscription to FlClash backend');
  }

  @override
  Future<V2etProxyMode> getProxyMode() async => _mode;

  @override
  Future<V2etSession> login({required Uri baseUrl, required String email, required String password}) {
    throw UnimplementedError('Stage-2: bind V2ET login to FlClash backend');
  }

  @override
  Future<void> logout() async {}

  @override
  Future<V2etSession?> restoreSession() async => null;

  @override
  Future<void> setProxyMode(V2etProxyMode mode) async {
    _mode = mode;
  }
}
