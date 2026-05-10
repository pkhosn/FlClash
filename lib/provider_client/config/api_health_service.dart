import 'package:dio/dio.dart';

class ApiHealthItem {
  const ApiHealthItem({
    required this.url,
    required this.ok,
    required this.latencyMs,
    required this.message,
  });

  final String url;
  final bool ok;
  final int? latencyMs;
  final String message;
}

class ApiHealthService {
  ApiHealthService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<List<ApiHealthItem>> probeAll(List<String> urls) async {
    final list = <ApiHealthItem>[];
    for (final raw in urls) {
      list.add(await probe(raw));
    }
    return list;
  }

  Future<ApiHealthItem> probe(String rawUrl) async {
    final url = rawUrl.trim();
    if (url.isEmpty) {
      return const ApiHealthItem(
        url: '',
        ok: false,
        latencyMs: null,
        message: '空地址',
      );
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      return ApiHealthItem(
        url: url,
        ok: false,
        latencyMs: null,
        message: 'URL 无效',
      );
    }
    final checkUri = _join(uri, '/api/v1/guest/comm/config');
    final started = DateTime.now();
    try {
      final response = await _dio.getUri<Object?>(
        checkUri,
        options: Options(
          sendTimeout: const Duration(seconds: 6),
          receiveTimeout: const Duration(seconds: 6),
          headers: const {'Accept': 'application/json,text/plain,*/*'},
          responseType: ResponseType.plain,
        ),
      );
      final latency = DateTime.now().difference(started).inMilliseconds;
      final ok = response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 500;
      return ApiHealthItem(
        url: url,
        ok: ok,
        latencyMs: latency,
        message: ok ? '可用' : '状态码 ${response.statusCode}',
      );
    } catch (e) {
      final latency = DateTime.now().difference(started).inMilliseconds;
      return ApiHealthItem(
        url: url,
        ok: false,
        latencyMs: latency,
        message: '失败: $e',
      );
    }
  }

  Uri _join(Uri base, String path) {
    final normalized = base.toString().endsWith('/')
        ? base.toString().substring(0, base.toString().length - 1)
        : base.toString();
    return Uri.parse('$normalized$path');
  }
}

