import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    String baseUrl = ApiConfig.baseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUri = Uri.parse(baseUrl.endsWith('/') ? baseUrl : '$baseUrl/');

  final http.Client _httpClient;
  final Uri _baseUri;

  Future<dynamic> get(String path) => _send('GET', path);

  Future<dynamic> post(String path, Map<String, dynamic> body) {
    return _send('POST', path, body: body);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) {
    return _send('PUT', path, body: body);
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = _baseUri.resolve(path.startsWith('/') ? path.substring(1) : path);
    Object? lastError;

    for (var attempt = 0; attempt <= ApiConfig.retryCount; attempt++) {
      try {
        final response = await _request(method, uri, body: body)
            .timeout(ApiConfig.requestTimeout);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          if (response.bodyBytes.isEmpty) return null;
          return jsonDecode(utf8.decode(response.bodyBytes));
        }

        final message = _extractError(response);
        if (response.statusCode >= 500 && attempt < ApiConfig.retryCount) {
          lastError = ApiException(message, statusCode: response.statusCode);
          await _backoff(attempt);
          continue;
        }

        throw ApiException(message, statusCode: response.statusCode);
      } on TimeoutException catch (err) {
        lastError = err;
        if (attempt == ApiConfig.retryCount) {
          throw const ApiException('Tempo limite ao comunicar com o backend');
        }
        await _backoff(attempt);
      } on ApiException {
        rethrow;
      } catch (err) {
        lastError = err;
        if (attempt == ApiConfig.retryCount) {
          throw ApiException('Backend indisponivel: $err');
        }
        await _backoff(attempt);
      }
    }

    throw ApiException('Falha na comunicacao com o backend: $lastError');
  }

  Future<http.Response> _request(
    String method,
    Uri uri, {
    Map<String, dynamic>? body,
  }) {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=utf-8',
    };

    final encodedBody = body == null ? null : jsonEncode(body);
    return switch (method) {
      'GET' => _httpClient.get(uri, headers: headers),
      'POST' => _httpClient.post(uri, headers: headers, body: encodedBody),
      'PUT' => _httpClient.put(uri, headers: headers, body: encodedBody),
      _ => throw ApiException('Metodo HTTP nao suportado: $method'),
    };
  }

  String _extractError(http.Response response) {
    try {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is Map<String, dynamic> && json['error'] is String) {
        return json['error'] as String;
      }
    } catch (_) {
      // Falls back to a generic message below.
    }
    return 'Resposta inesperada do backend';
  }

  Future<void> _backoff(int attempt) {
    return Future<void>.delayed(Duration(milliseconds: 350 * (attempt + 1)));
  }
}
