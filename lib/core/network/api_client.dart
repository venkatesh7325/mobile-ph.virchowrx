import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../env/env.dart';
import '../errors/exceptions.dart';

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

  Map<String, String> _authHeaders(String? token) {
    if (token != null && token.isNotEmpty) {
      return {..._defaultHeaders, 'Authorization': 'Bearer $token'};
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
        final body = _tryDecodeBody(response.body);
        throw ServerException(message: body['message'] ?? 'Bad request', statusCode: 400);
      case 401:
        throw const UnauthorizedException();
      case 403:
        throw const UnauthorizedException(message: 'Access denied');
      case 404:
        throw const NotFoundException();
      case 422:
        final body = _tryDecodeBody(response.body);
        throw ValidationException(message: body['message'] ?? 'Validation failed');
      case 500:
      case 502:
      case 503:
        throw ServerException(message: 'Server error', statusCode: response.statusCode);
      default:
        throw ServerException(
          message: 'Request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
        );
    }
  }

  Map<String, dynamic> _tryDecodeBody(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
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
        final response = await _client.get(
          _buildUri(endpoint, queryParams),
          headers: _authHeaders(token),
        );
        return _handleResponse(response);
      });

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) =>
      _execute(() async {
        final response = await _client.post(
          _buildUri(endpoint),
          headers: _authHeaders(token),
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
        final response = await _client.put(
          _buildUri(endpoint),
          headers: _authHeaders(token),
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
        final response = await _client.patch(
          _buildUri(endpoint),
          headers: _authHeaders(token),
          body: jsonEncode(body ?? {}),
        );
        return _handleResponse(response);
      });

  Future<dynamic> delete(
    String endpoint, {
    String? token,
  }) =>
      _execute(() async {
        final response = await _client.delete(
          _buildUri(endpoint),
          headers: _authHeaders(token),
        );
        return _handleResponse(response);
      });

  void dispose() => _client.close();
}
