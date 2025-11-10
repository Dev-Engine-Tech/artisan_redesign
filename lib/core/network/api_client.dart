import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:artisans_circle/core/storage/secure_storage.dart';

/// HTTP client for making authenticated API requests
class ApiClient {
  final http.Client _httpClient;
  final SecureStorage _secureStorage;
  final String baseUrl;

  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
    SecureStorage? secureStorage,
  })  : _httpClient = httpClient ?? http.Client(),
        _secureStorage = secureStorage ?? SecureStorage();

  /// Get authenticated headers with Bearer token
  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await _secureStorage.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Make GET request
  Future<http.Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool requireAuth = true,
  }) async {
    final uri = _buildUri(endpoint, queryParams);
    final headers = await _getHeaders(includeAuth: requireAuth);

    return _httpClient.get(uri, headers: headers);
  }

  /// Make POST request
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    final uri = _buildUri(endpoint);
    final headers = await _getHeaders(includeAuth: requireAuth);

    return _httpClient.post(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  /// Make PUT request
  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    final uri = _buildUri(endpoint);
    final headers = await _getHeaders(includeAuth: requireAuth);

    return _httpClient.put(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  /// Make PATCH request
  Future<http.Response> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    final uri = _buildUri(endpoint);
    final headers = await _getHeaders(includeAuth: requireAuth);

    return _httpClient.patch(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  /// Make DELETE request
  Future<http.Response> delete(
    String endpoint, {
    bool requireAuth = true,
  }) async {
    final uri = _buildUri(endpoint);
    final headers = await _getHeaders(includeAuth: requireAuth);

    return _httpClient.delete(uri, headers: headers);
  }

  /// Build URI with query parameters
  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    // Ensure proper URL construction with slash separation
    final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    final cleanEndpoint =
        endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final uri = Uri.parse('$cleanBaseUrl$cleanEndpoint');

    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(
          queryParameters: queryParams.map(
        (key, value) => MapEntry(key, value.toString()),
      ));
    }

    return uri;
  }

  /// Dispose of the HTTP client
  void dispose() {
    _httpClient.close();
  }
}
