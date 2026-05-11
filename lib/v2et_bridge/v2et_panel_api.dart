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
      data: {'email': email, 'password': password},
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

  Future<void> sendEmailVerify({
    required Uri baseUrl,
    required String email,
    required bool isForgetPassword,
  }) async {
    final uri = _join(baseUrl, '/api/v1/passport/comm/sendEmailVerify');
    await _dio.postUri<Map<String, dynamic>>(
      uri,
      data: {
        'email': email,
        // v2board backend expects isforget
        'isforget': isForgetPassword ? 1 : 0,
        // keep compatibility for forks
        'isForgetPassword': isForgetPassword ? 1 : 0,
      },
      options: Options(
        headers: const {'Accept': 'application/json,text/plain,*/*'},
        responseType: ResponseType.json,
      ),
    );
  }

  Future<void> resetPassword({
    required Uri baseUrl,
    required String email,
    required String password,
    required String emailCode,
  }) async {
    final uri = _join(baseUrl, '/api/v1/passport/auth/forget');
    await _dio.postUri<Map<String, dynamic>>(
      uri,
      data: {'email': email, 'password': password, 'email_code': emailCode},
      options: Options(
        headers: const {'Accept': 'application/json,text/plain,*/*'},
        responseType: ResponseType.json,
      ),
    );
  }

  Future<String> register({
    required Uri baseUrl,
    required String email,
    required String password,
    required String emailCode,
    String? inviteCode,
  }) async {
    final uri = _join(baseUrl, '/api/v1/passport/auth/register');
    final response = await _dio.postUri<Map<String, dynamic>>(
      uri,
      data: {
        'email': email,
        'password': password,
        'email_code': emailCode,
        if ((inviteCode ?? '').trim().isNotEmpty)
          'invite_code': inviteCode!.trim(),
      },
      options: Options(
        headers: const {'Accept': 'application/json,text/plain,*/*'},
        responseType: ResponseType.json,
      ),
    );
    final body = response.data ?? const <String, dynamic>{};
    final token = _readToken(body);
    if (token == null || token.isEmpty) {
      throw StateError('register success but token is empty');
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
      return data
          .whereType<Map>()
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
          .toList();
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
      return data
          .whereType<Map>()
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
          .toList();
    }
    return const [];
  }

  Future<List<Map<String, dynamic>>> fetchNotices({
    required Uri baseUrl,
    required String accessToken,
  }) async {
    final uri = _join(baseUrl, '/api/v1/user/notice/fetch');
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
      return data
          .whereType<Map>()
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
          .toList();
    }
    return const [];
  }

  Future<List<Map<String, dynamic>>> fetchInviteData({
    required Uri baseUrl,
    required String accessToken,
  }) async {
    final uri = _join(baseUrl, '/api/v1/user/invite/fetch');
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
      return data
          .whereType<Map>()
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
          .toList();
    }
    return const [];
  }

  Future<Map<String, dynamic>> fetchCommConfig({
    required Uri baseUrl,
    required String accessToken,
  }) async {
    final uri = _join(baseUrl, '/api/v1/user/comm/config');
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
    return response.data ?? const <String, dynamic>{};
  }

  Future<String> generateInviteCode({
    required Uri baseUrl,
    required String accessToken,
  }) async {
    final uri = _join(baseUrl, '/api/v1/user/invite/save');
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
    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }
    if (data is Map) {
      final code = '${data['code'] ?? data['invite_code'] ?? ''}'.trim();
      if (code.isNotEmpty) return code;
    }
    throw StateError('invite code missing');
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
        if ((couponCode ?? '').trim().isNotEmpty)
          'coupon_code': couponCode!.trim(),
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
      data: {'trade_no': tradeNo, 'method': method},
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

  Future<List<Map<String, dynamic>>> fetchPaymentMethods({
    required Uri baseUrl,
    required String accessToken,
  }) async {
    final uri = _join(baseUrl, '/api/v1/user/order/getPaymentMethod');
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
      return data
          .whereType<Map>()
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
          .toList();
    }
    return const [];
  }

  Future<int> checkOrderPaid({
    required Uri baseUrl,
    required String accessToken,
    required String tradeNo,
  }) async {
    final uri = _join(baseUrl, '/api/v1/user/order/check');
    final response = await _dio.postUri<Map<String, dynamic>>(
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
    final body = response.data ?? const <String, dynamic>{};
    final data = body['data'];
    if (data is bool) return data ? 1 : 0;
    if (data is num) return data.toInt();
    final text = '${data ?? ''}'.trim().toLowerCase();
    if (text == 'true' || text == 'paid') return 1;
    return int.tryParse(text) ?? 0;
  }

  Future<void> changePassword({
    required Uri baseUrl,
    required String accessToken,
    required String oldPassword,
    required String newPassword,
  }) async {
    final uri = _join(baseUrl, '/api/v1/user/changePassword');
    await _dio.postUri<Map<String, dynamic>>(
      uri,
      data: {'old_password': oldPassword, 'new_password': newPassword},
      options: Options(
        headers: {
          'Accept': 'application/json,text/plain,*/*',
          'Authorization': accessToken,
        },
        responseType: ResponseType.json,
      ),
    );
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
