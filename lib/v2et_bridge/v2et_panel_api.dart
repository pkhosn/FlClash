import 'package:dio/dio.dart';

class V2etPanelApi {
  V2etPanelApi({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<String> login({
    required Uri baseUrl,
    required String email,
    required String password,
  }) async {
    final loginUri = _join(baseUrl, '/api/v1/passport/auth/login');
    final response = await _dio.postUri<Map<String, dynamic>>(
      loginUri,
      data: {
        'email': email,
        'password': password,
      },
      options: Options(
        headers: const {'Accept': 'application/json,text/plain,*/*'},
        responseType: ResponseType.json,
      ),
    );
    final body = response.data ?? const <String, dynamic>{};
    final token = _readToken(body);
    if (token == null || token.isEmpty) {
      throw StateError('login success but token is empty');
    }
    return token;
  }

  Future<Map<String, dynamic>> fetchSubscription({
    required Uri baseUrl,
    required String accessToken,
  }) async {
    final infoUri = _join(baseUrl, '/api/v1/user/getSubscribe');
    final response = await _dio.getUri<Map<String, dynamic>>(
      infoUri,
      options: Options(
        headers: {
          'Accept': 'application/json,text/plain,*/*',
          'Authorization': accessToken,
        },
        responseType: ResponseType.json,
      ),
    );
    return response.data ?? const <String, dynamic>{};
  }

  Future<List<Map<String, dynamic>>> fetchPlans({
    required Uri baseUrl,
    required String accessToken,
  }) async {
    final uri = _join(baseUrl, '/api/v1/user/plan/fetch');
    final response = await _dio.getUri<Map<String, dynamic>>(
      uri,
      options: Options(
        headers: {
          'Accept': 'application/json,text/plain,*/*',
          'Authorization': accessToken,
        },
        responseType: ResponseType.json,
      ),
    );
    final body = response.data ?? const <String, dynamic>{};
    final data = body['data'];
    if (data is List) {
      return data.whereType<Map>().map((e) => e.map((k, v) => MapEntry(k.toString(), v))).toList();
    }
    return const [];
  }

  Future<List<Map<String, dynamic>>> fetchPendingOrders({
    required Uri baseUrl,
    required String accessToken,
  }) async {
    final uri = _join(baseUrl, '/api/v1/user/order/fetch');
    final response = await _dio.getUri<Map<String, dynamic>>(
      uri,
      options: Options(
        headers: {
          'Accept': 'application/json,text/plain,*/*',
          'Authorization': accessToken,
        },
        responseType: ResponseType.json,
      ),
    );
    final body = response.data ?? const <String, dynamic>{};
    final data = body['data'];
    if (data is List) {
      return data.whereType<Map>().map((e) => e.map((k, v) => MapEntry(k.toString(), v))).toList();
    }
    return const [];
  }

  Future<void> cancelOrder({
    required Uri baseUrl,
    required String accessToken,
    required String tradeNo,
  }) async {
    final uri = _join(baseUrl, '/api/v1/user/order/cancel');
    await _dio.postUri<Map<String, dynamic>>(
      uri,
      data: {'trade_no': tradeNo},
      options: Options(
        headers: {
          'Accept': 'application/json,text/plain,*/*',
          'Authorization': accessToken,
        },
        responseType: ResponseType.json,
      ),
    );
  }

  Future<String> saveOrder({
    required Uri baseUrl,
    required String accessToken,
    required int planId,
    required String period,
    String? couponCode,
  }) async {
    final uri = _join(baseUrl, '/api/v1/user/order/save');
    final response = await _dio.postUri<Map<String, dynamic>>(
      uri,
      data: {
        'plan_id': planId,
        'period': period,
        if ((couponCode ?? '').trim().isNotEmpty) 'coupon_code': couponCode!.trim(),
      },
      options: Options(
        headers: {
          'Accept': 'application/json,text/plain,*/*',
          'Authorization': accessToken,
        },
        responseType: ResponseType.json,
      ),
    );
    final body = response.data ?? const <String, dynamic>{};
    final data = body['data'];
    if (data is String && data.trim().isNotEmpty) return data.trim();
    if (data is Map) {
      final tradeNo = '${data['trade_no'] ?? ''}'.trim();
      if (tradeNo.isNotEmpty) return tradeNo;
    }
    throw StateError('save order failed: trade_no missing');
  }

  Future<String> checkoutOrder({
    required Uri baseUrl,
    required String accessToken,
    required String tradeNo,
    int method = 1,
  }) async {
    final uri = _join(baseUrl, '/api/v1/user/order/checkout');
    final response = await _dio.postUri<Map<String, dynamic>>(
      uri,
      data: {
        'trade_no': tradeNo,
        'method': method,
      },
      options: Options(
        headers: {
          'Accept': 'application/json,text/plain,*/*',
          'Authorization': accessToken,
        },
        responseType: ResponseType.json,
      ),
    );
    final body = response.data ?? const <String, dynamic>{};
    final data = body['data'];
    if (data is String && data.trim().isNotEmpty) return data.trim();
    if (data is Map) {
      final url = '${data['url'] ?? data['checkout_url'] ?? ''}'.trim();
      if (url.isNotEmpty) return url;
    }
    throw StateError('checkout failed: pay url missing');
  }

  String? _readToken(Map<String, dynamic> body) {
    final direct = body['data'];
    if (direct is Map<String, dynamic>) {
      final auth = direct['auth_data']?.toString().trim();
      if (auth != null && auth.isNotEmpty) return auth;
      final token = direct['token']?.toString().trim();
      if (token != null && token.isNotEmpty) return token;
    }
    final auth = body['auth_data']?.toString().trim();
    if (auth != null && auth.isNotEmpty) return auth;
    final token = body['token']?.toString().trim();
    if (token != null && token.isNotEmpty) return token;
    return null;
  }

  Uri _join(Uri base, String path) {
    final normalized = base.toString().endsWith('/')
        ? base.toString().substring(0, base.toString().length - 1)
        : base.toString();
    return Uri.parse('$normalized$path');
  }
}
