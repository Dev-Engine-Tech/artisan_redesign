import 'package:dio/dio.dart';

/// No-op for platforms where customizing TLS is unsupported (e.g., web).
void configureBadCertificate(Dio dio, {required String host}) {}
