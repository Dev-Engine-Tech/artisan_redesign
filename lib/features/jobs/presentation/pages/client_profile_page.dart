import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../../../core/api/endpoints.dart';
import '../../../../core/components/components.dart';
import '../../../../core/theme.dart';

class ClientProfilePage extends StatefulWidget {
  final String clientId; // may be numeric or UUID
  final String? initialName;
  final String? initialEmail;
  final String? initialPhone;
  final String? initialAvatarUrl;
  const ClientProfilePage({
    super.key,
    required this.clientId,
    this.initialName,
    this.initialEmail,
    this.initialPhone,
    this.initialAvatarUrl,
  });

  @override
  State<ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage> {
  Map<String, dynamic>? _profile;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // ignore: avoid_print
    if (widget.initialName != null && widget.initialName!.trim().isNotEmpty) {
      print('[ClientProfile] Initial displayName="${widget.initialName}" for id="${widget.clientId}"');
    }
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dio = GetIt.I<Dio>();
      final id = widget.clientId.trim();
      if (id.isEmpty) {
        // ignore: avoid_print
        print('[ClientProfile] Invalid empty clientId received');
        setState(() {
          _error = 'Invalid client id';
          _loading = false;
        });
        return;
      }
      // ignore: avoid_print
      print('[ClientProfile] Fetch start for id="$id" baseUrl=${dio.options.baseUrl}');

      Future<Map<String, dynamic>?> tryFetch() async {
        Response r;
        final any = Options(validateStatus: (s) => true);
        // 1) Primary endpoint
        final url1 = ApiEndpoints.getUserProfileById(id);
        // ignore: avoid_print
        print('[ClientProfile] GET $url1');
        r = await dio.get(url1, options: any);
        // ignore: avoid_print
        print('[ClientProfile] -> status ${r.statusCode}');
        if (r.statusCode == 200 && r.data is Map) {
          return _extractPayload(r.data);
        }
        // 2) Fallback: user-details/{id}/
        final url2 = '${ApiEndpoints.userDetails}$id/';
        // ignore: avoid_print
        print('[ClientProfile] GET $url2');
        r = await dio.get(url2, options: any);
        // ignore: avoid_print
        print('[ClientProfile] -> status ${r.statusCode}');
        if (r.statusCode == 200 && r.data is Map) {
          return _extractPayload(r.data);
        }
        // 3) Fallback: user-details?user_id=
        // ignore: avoid_print
        print('[ClientProfile] GET ${ApiEndpoints.userDetails}?user_id=$id');
        r = await dio.get(ApiEndpoints.userDetails, queryParameters: {'user_id': id}, options: any);
        // ignore: avoid_print
        print('[ClientProfile] -> status ${r.statusCode}');
        if (r.statusCode == 200 && r.data is Map) {
          return _extractPayload(r.data);
        }
        // 4) Fallback: user-details?id=
        // ignore: avoid_print
        print('[ClientProfile] GET ${ApiEndpoints.userDetails}?id=$id');
        r = await dio.get(ApiEndpoints.userDetails, queryParameters: {'id': id}, options: any);
        // ignore: avoid_print
        print('[ClientProfile] -> status ${r.statusCode}');
        if (r.statusCode == 200 && r.data is Map) {
          return _extractPayload(r.data);
        }
        return null;
      }

      final payload = await tryFetch();
      if (!mounted) return;
      if (payload != null) {
        // ignore: avoid_print
        print('[ClientProfile] Success keys=${payload.keys.toList()}');
        setState(() {
          _profile = payload;
          _loading = false;
        });
      } else {
        // ignore: avoid_print
        print('[ClientProfile] Failed to load profile for id="$id"');
        setState(() {
          _error = 'Unable to load profile for id: $id';
          _loading = false;
        });
      }
    } on DioException catch (e) {
      if (!mounted) return;
      // ignore: avoid_print
      print('[ClientProfile] DioException status=${e.response?.statusCode} data=${_safeString(e.response?.data)} message=${e.message}');
      setState(() {
        _error = e.response?.data?.toString() ?? e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      // ignore: avoid_print
      print('[ClientProfile] Exception ${e.toString()}');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Map<String, dynamic>? _extractPayload(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        if (data['data'] is Map<String, dynamic>) {
          return Map<String, dynamic>.from(data['data'] as Map);
        }
        if (data['result'] is Map<String, dynamic>) {
          return Map<String, dynamic>.from(data['result'] as Map);
        }
        if (data['user'] is Map<String, dynamic>) {
          return Map<String, dynamic>.from(data['user'] as Map);
        }
        return Map<String, dynamic>.from(data);
      }
    } catch (_) {}
    return null;
  }

  String _safeString(dynamic v, {int max = 2000}) {
    try {
      if (v == null) return 'null';
      if (v is String) return v.length > max ? v.substring(0, max) : v;
      if (v is Map || v is List) {
        final s = const JsonEncoder.withIndent('  ').convert(v);
        return s.length > max ? s.substring(0, max) : s;
      }
      final s = v.toString();
      return s.length > max ? s.substring(0, max) : s;
    } catch (_) {
      return '<non-stringifiable>';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.danger),
                        AppSpacing.spaceSM,
                        SizedBox(
                          height: 160,
                          child: SingleChildScrollView(
                            child: Text(_error!, style: const TextStyle(color: Colors.black87)),
                          ),
                        ),
                        AppSpacing.spaceLG,
                        PrimaryButton(text: 'Retry', onPressed: _load),
                      ],
                    ),
                  ),
                ))
              : _buildProfile(context),
    );
  }

  Widget _buildProfile(BuildContext context) {
    final p = _profile ?? {};
    final fullName = (() {
      if (widget.initialName != null && widget.initialName!.trim().isNotEmpty) {
        return widget.initialName!.trim();
      }
      final fn = p['full_name'] ?? p['name'];
      if (fn != null && fn.toString().trim().isNotEmpty) return fn.toString();
      final first = p['first_name']?.toString();
      final last = p['last_name']?.toString();
      final combined = [first, last].where((s) => (s ?? '').isNotEmpty).join(' ');
      if (combined.isNotEmpty) return combined;
      return 'Client';
    })();
    final email = (p['email']?.toString() ?? widget.initialEmail);
    final phone = (p['phone']?.toString() ?? widget.initialPhone);
    final location = (p['location'] ?? p['address'] ?? p['city'])?.toString();
    final avatarUrl = (p['profile_pic'] ?? p['avatar'] ?? p['photo'] ?? widget.initialAvatarUrl)?.toString();
    final avatarValid = avatarUrl != null && (avatarUrl.trim().startsWith('http://') || avatarUrl.trim().startsWith('https://'));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.orange.withValues(alpha: 0.1),
              backgroundImage: avatarValid ? NetworkImage(avatarUrl!.trim()) : null,
              child: !avatarValid
                  ? const Icon(Icons.person, color: AppColors.orange)
                  : null,
            ),
            AppSpacing.spaceMD,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fullName,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  if (location != null && location.isNotEmpty) ...[
                    AppSpacing.spaceXS,
                    Text(location, style: const TextStyle(color: Colors.black54)),
                  ]
                ],
              ),
            ),
          ],
        ),
        AppSpacing.spaceLG,
        if (email != null && email.isNotEmpty)
          _infoRow(context, Icons.email_outlined, email),
        if (phone != null && phone.isNotEmpty)
          _infoRow(context, Icons.phone_outlined, phone),
      ],
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.orange),
          AppSpacing.spaceSM,
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
