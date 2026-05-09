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

