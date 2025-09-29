import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// Configures Dio to accept bad/invalid TLS certificates for a specific host.
/// Use only for development. Never enable in production builds.
void configureBadCertificate(Dio dio, {required String host}) {
  // For staging environment, completely disable SSL verification
  if (host.contains('staging') || host.contains('apistaging')) {
    // Use a custom adapter that bypasses ALL SSL validation
    dio.httpClientAdapter = IOHttpClientAdapter()
      ..createHttpClient = () {
        final client = HttpClient();

        // Accept ALL certificates without any validation
        client.badCertificateCallback = (cert, host, port) => true;

        // Remove user agent to avoid server detection
        client.userAgent = null;

        // Set generous timeouts
        client.connectionTimeout = const Duration(seconds: 30);
        client.idleTimeout = const Duration(seconds: 30);

        return client;
      };
  } else {
    // Use default adapter with selective certificate override
    final adapter = dio.httpClientAdapter as IOHttpClientAdapter;
    adapter.createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (
        X509Certificate cert,
        String requestHost,
        int port,
      ) {
        // Only allow the configured host; keep checks for others intact.
        return requestHost == host;
      };
      return client;
    };
  }
}
