import 'dart:async' as async;
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

import '../auth/auth_session.dart';
import '../env/env.dart';
import '../errors/exceptions.dart';

class ApiClient {
  final http.Client _client;
  final String baseUrl;
  final AuthSession? authSession;

  ApiClient({http.Client? client, this.authSession})
      : _client = client ?? http.Client(),
        baseUrl = Env.baseUrl;

  Map<String, String> get _defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  String? _resolveToken(String? explicit, {required bool useSession}) {
    if (!useSession) {
      if (explicit != null && explicit.isNotEmpty) return explicit;
      return null;
    }
    if (explicit != null && explicit.isNotEmpty) return explicit;
    final s = authSession?.token.value;
    if (s == null || s.isEmpty) return null;
    return s;
  }

  Map<String, String> _headers(String? token) {
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
      print('[API] ${response.request?.method} ${response.request?.url} → ${response.statusCode} ${response.body}');
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
        throw ServerException(message: body['message']?.toString() ?? 'Bad request', statusCode: 400);
      case 401:
        throw const UnauthorizedException();
      case 403:
        throw const UnauthorizedException(message: 'Access denied');
      case 404:
        throw const NotFoundException();
      case 422:
        final body = _tryDecodeBody(response.body);
        throw ValidationException(message: body['message']?.toString() ?? 'Validation failed');
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

  MediaType _contentTypeForUploadPath(String path) {
    final ext = p.extension(path).toLowerCase();
    switch (ext) {
      case '.pdf':
        return MediaType('application', 'pdf');
      case '.jpg':
      case '.jpeg':
        return MediaType('image', 'jpeg');
      case '.png':
        return MediaType('image', 'png');
      default:
        throw ValidationException(
          message: 'Only PDF, JPEG, JPG, and PNG files are allowed',
        );
    }
  }

  Future<T> _execute<T>(Future<T> Function() request) async {
    try {
      return await request().timeout(Duration(milliseconds: Env.timeout));
    } on SocketException {
      throw const NetworkException();
    } on async.TimeoutException {
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
    bool useSessionToken = true,
  }) =>
      _execute(() async {
        final resolved = _resolveToken(token, useSession: useSessionToken);
        final response = await _client.get(
          _buildUri(endpoint, queryParams),
          headers: _headers(resolved),
        );
        return _handleResponse(response);
      });

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
    bool useSessionToken = true,
  }) =>
      _execute(() async {
        final resolved = _resolveToken(token, useSession: useSessionToken);
        final response = await _client.post(
          _buildUri(endpoint),
          headers: _headers(resolved),
          body: jsonEncode(body ?? {}),
        );
        return _handleResponse(response);
      });

  /// Multipart POST (e.g. pharmacy registration with PDF/images). Do not set
  /// `Content-Type`; the boundary is added automatically.
  Future<dynamic> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    Map<String, String> filePaths = const {},
    String? token,
    bool useSessionToken = false,
  }) =>
      _execute(() async {
        final resolved = _resolveToken(token, useSession: useSessionToken);
        final uri = _buildUri(endpoint);
        final request = http.MultipartRequest('POST', uri);
        request.headers['Accept'] = 'application/json';
        if (resolved != null && resolved.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $resolved';
        }
        request.fields.addAll(fields);
        for (final e in filePaths.entries) {
          if (e.value.isEmpty) continue;
          final contentType = _contentTypeForUploadPath(e.value);
          request.files.add(
            await http.MultipartFile.fromPath(
              e.key,
              e.value,
              contentType: contentType,
              filename: p.basename(e.value),
            ),
          );
        }
        final streamed = await _client.send(request);
        final response = await http.Response.fromStream(streamed);
        return _handleResponse(response);
      });

  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
    bool useSessionToken = true,
  }) =>
      _execute(() async {
        final resolved = _resolveToken(token, useSession: useSessionToken);
        final response = await _client.put(
          _buildUri(endpoint),
          headers: _headers(resolved),
          body: jsonEncode(body ?? {}),
        );
        return _handleResponse(response);
      });

  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
    bool useSessionToken = true,
  }) =>
      _execute(() async {
        final resolved = _resolveToken(token, useSession: useSessionToken);
        final response = await _client.patch(
          _buildUri(endpoint),
          headers: _headers(resolved),
          body: jsonEncode(body ?? {}),
        );
        return _handleResponse(response);
      });

  Future<dynamic> delete(
    String endpoint, {
    String? token,
    bool useSessionToken = true,
  }) =>
      _execute(() async {
        final resolved = _resolveToken(token, useSession: useSessionToken);
        final response = await _client.delete(
          _buildUri(endpoint),
          headers: _headers(resolved),
        );
        return _handleResponse(response);
      });

  void dispose() => _client.close();
}
