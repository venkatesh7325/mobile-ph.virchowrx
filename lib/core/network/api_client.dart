import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../env/env.dart';
import '../errors/exceptions.dart';
import '../storage/auth_storage.dart';

class ApiClient {
  final http.Client _client;
  final String baseUrl;

  ApiClient({http.Client? client})
      : _client = client ?? http.Client(),
        baseUrl = Env.baseUrl;

  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// If [token] is passed explicitly, use it. Otherwise read the saved JWT
  /// from secure storage so authenticated calls "just work" after sign-in.
  Future<Map<String, String>> _buildHeaders(String? token) async {
    final effective = token ?? await AuthStorage.instance.readToken();
    if (effective != null && effective.isNotEmpty) {
      return {..._defaultHeaders, 'Authorization': 'Bearer $effective'};
    }
    return _defaultHeaders;
  }

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(
        queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())),
      );
    }
    return uri;
  }

  dynamic _handleResponse(http.Response response) {
    if (Env.isDevelopment) {
      // ignore: avoid_print
      print('[API] ${response.request?.method} ${response.request?.url} → ${response.statusCode}');
    }

    final body = _tryDecodeBody(response.body);

    switch (response.statusCode) {
      case 200:
      case 201:
      case 204:
        if (response.body.isEmpty) return {};
        try {
          return jsonDecode(response.body);
        } catch (_) {
          throw const ParseException();
        }
      case 400:
        throw ServerException(
          message: _extractMessage(body, fallback: 'Bad request'),
          statusCode: 400,
        );
      case 401:
        throw UnauthorizedException(
          message: _extractMessage(body, fallback: 'Unauthorized'),
        );
      case 403:
        throw UnauthorizedException(
          message: _extractMessage(body, fallback: 'Access denied'),
        );
      case 404:
        throw NotFoundException(
          message: _extractMessage(body, fallback: 'Not found'),
        );
      case 422:
        throw ValidationException(
          message: _extractMessage(body, fallback: 'Validation failed'),
        );
      case 500:
      case 502:
      case 503:
        throw ServerException(
          message: _extractMessage(body, fallback: 'Server error'),
          statusCode: response.statusCode,
        );
      default:
        throw ServerException(
          message: _extractMessage(
            body,
            fallback: 'Request failed with status ${response.statusCode}',
          ),
          statusCode: response.statusCode,
        );
    }
  }

  String _extractMessage(Map<String, dynamic> body, {required String fallback}) {
    final msg = body['message'] ?? body['error'] ?? body['detail'];
    return (msg is String && msg.isNotEmpty) ? msg : fallback;
  }

  Map<String, dynamic> _tryDecodeBody(String body) {
    if (body.isEmpty) return {};
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (_) {
      return {};
    }
  }

  Future<T> _execute<T>(Future<T> Function() request) async {
    try {
      return await request().timeout(Duration(milliseconds: Env.timeout));
    } on SocketException {
      throw const NetworkException();
    } on TimeoutException {
      throw const TimeoutException();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<dynamic> get(
      String endpoint, {
        Map<String, dynamic>? queryParams,
        String? token,
      }) =>
      _execute(() async {
        final headers = await _buildHeaders(token);
        final response = await _client.get(
          _buildUri(endpoint, queryParams),
          headers: headers,
        );
        return _handleResponse(response);
      });

  Future<dynamic> post(
      String endpoint, {
        Map<String, dynamic>? body,
        String? token,
      }) =>
      _execute(() async {
        final headers = await _buildHeaders(token);
        final response = await _client.post(
          _buildUri(endpoint),
          headers: headers,
          body: jsonEncode(body ?? {}),
        );
        return _handleResponse(response);
      });

  Future<dynamic> put(
      String endpoint, {
        Map<String, dynamic>? body,
        String? token,
      }) =>
      _execute(() async {
        final headers = await _buildHeaders(token);
        final response = await _client.put(
          _buildUri(endpoint),
          headers: headers,
          body: jsonEncode(body ?? {}),
        );
        return _handleResponse(response);
      });

  Future<dynamic> patch(
      String endpoint, {
        Map<String, dynamic>? body,
        String? token,
      }) =>
      _execute(() async {
        final headers = await _buildHeaders(token);
        final response = await _client.patch(
          _buildUri(endpoint),
          headers: headers,
          body: jsonEncode(body ?? {}),
        );
        return _handleResponse(response);
      });

  Future<dynamic> delete(
      String endpoint, {
        String? token,
      }) =>
      _execute(() async {
        final headers = await _buildHeaders(token);
        final response = await _client.delete(
          _buildUri(endpoint),
          headers: headers,
        );
        return _handleResponse(response);
      });

  void dispose() => _client.close();
}