import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job_status.dart';
import 'agreement_model.dart';
import 'change_request_model.dart';
import 'material_model.dart';

class JobModel extends Job {
  const JobModel({
    required super.id,
    required super.title,
    required super.category,
    required super.description,
    required super.address,
    required super.minBudget,
    required super.maxBudget,
    required super.duration,
    super.applied = false,
    super.saved = false,
    super.thumbnailUrl = '',
    super.proposal,
    super.paymentType,
    super.desiredPay,
    super.dateCreated,
    super.status = JobStatus.pending,
    super.projectStatus = AppliedProjectStatus.ongoing,
    super.agreement,
    super.changeRequest,
    super.materials = const [],
    super.expertise,
    super.workMode,
    super.clientName,
    super.clientId,
  });

  factory JobModel.fromJson(Map<String, dynamic> json,
      {bool isFromApplications = false}) {
    try {
      int toInt(dynamic v) {
        if (v == null) return 0;
        if (v is int) return v;
        final s = v.toString();
        return int.tryParse(s.replaceAll(',', '').split('.').first) ?? 0;
      }

      // Resolve category possibly being a nested object
      String resolveCategory(dynamic cat) {
        try {
          if (cat is Map) {
            return (cat['name'] ?? cat['title'] ?? '').toString();
          }
          return (cat ?? '').toString();
        } catch (e) {
          return '';
        }
      }

      // Resolve address from location -> display_name or job_address or address
      String resolveAddress(Map<String, dynamic> m) {
        try {
          final loc = m['location'];
          if (loc is Map && loc['display_name'] != null) {
            return loc['display_name'].toString();
          }
          if (m['job_address'] != null) {
            return m['job_address'].toString();
          }
          if (m['address'] != null) {
            return m['address'].toString();
          }
          return '';
        } catch (e) {
          return '';
        }
      }

      // Enhanced budget parsing for applications and jobs
      // Applications use 'pay' field, jobs use 'min_budget'/'max_budget'
      final payValue = toInt(json['pay']);
      final minBudget = toInt(json['min_budget'] ?? json['minBudget']) == 0
          ? payValue
          : toInt(json['min_budget'] ?? json['minBudget']);
      final maxBudget = toInt(json['max_budget'] ?? json['maxBudget']) == 0
          ? payValue
          : toInt(json['max_budget'] ?? json['maxBudget']);

      // Thumbnail: prefer job thumbnail, else client's profile picture
      String resolveThumb(Map<String, dynamic> m) {
        final t = m['thumbnail_url'] ?? m['thumbnail'];
        if (t != null && t.toString().isNotEmpty) {
          return t.toString();
        }
        final client = m['client'];
        if (client is Map && client['profile_pic'] != null) {
          return client['profile_pic'].toString();
        }
        return '';
      }

      // Parse materials list
      List<MaterialModel> parseMaterials(dynamic materialsJson) {
        if (materialsJson is List) {
          return materialsJson
              .map((m) => MaterialModel.fromJson(m as Map<String, dynamic>))
              .toList();
        }
        return [];
      }

      String? extractIdFromMap(Map m) {
        final candidates = [
          m['id'],
          m['uuid'],
          m['user_id'],
          (m['user'] is Map ? (m['user']['id'] ?? m['user']['uuid']) : null),
          m['pk'],
        ];
        for (final c in candidates) {
          if (c != null && c.toString().trim().isNotEmpty) return c.toString();
        }
        return null;
      }

      String? resolveClientId(Map<String, dynamic> m) {
        // Prefer explicit client-like owners; avoid 'user' which can be current artisan
        final keys = [
          'client',
          'buyer',
          'owner',
          'posted_by',
          'poster',
          'customer',
          'client_info',
          'job_owner',
          'created_by',
          'employer',
        ];
        for (final k in keys) {
          final v = m[k];
          if (v is Map) {
            final id = extractIdFromMap(v);
            if (id != null) return id;
          }
        }
        final flatKeys = [
          'client_id',
          'customer_id',
          'buyer_id',
          'owner_id',
          'poster_id',
          'posted_by_id',
          'created_by_id',
        ];
        for (final k in flatKeys) {
          final v = m[k];
          if (v != null && v.toString().trim().isNotEmpty) return v.toString();
        }
        return null;
      }

      String? resolveClientName(Map<String, dynamic> m) {
        final keys = [
          'client',
          'buyer',
          'owner',
          'posted_by',
          'poster',
          'customer',
          'client_info',
          'job_owner',
          'created_by',
          'employer',
        ];
        for (final k in keys) {
          final v = m[k];
          if (v is Map) {
            final nameCandidates = [
              v['full_name'],
              v['name'],
              v['username'],
              [v['first_name'], v['last_name']]
                  .where((e) => (e ?? '').toString().isNotEmpty)
                  .join(' ')
                  .trim(),
            ];
            for (final n in nameCandidates) {
              if (n != null && n.toString().trim().isNotEmpty)
                return n.toString();
            }
          }
        }
        return m['client_name']?.toString();
      }

      return JobModel(
        id: (json['id'] ?? json['job_id'] ?? '').toString(),
        title: (json['title'] ?? json['job_title'] ?? '').toString(),
        category: resolveCategory(json['category'] ?? json['job_category']),
        description: (json['description'] ?? '').toString(),
        address: resolveAddress(json),
        minBudget: minBudget,
        maxBudget: maxBudget,
        duration: (json['duration'] ?? '').toString(),
        applied: isFromApplications ||
            (json['applied'] ?? json['is_applied'] ?? false) == true,
        saved: (json['saved'] ?? json['is_saved'] ?? false) == true,
        thumbnailUrl: resolveThumb(json),
        proposal: json['proposal']?.toString(),
        paymentType: json['payment_type']?.toString(),
        desiredPay: json['desired_pay']?.toString(),
        dateCreated: json['date_created'] != null
            ? DateTime.tryParse(json['date_created'])
            : null,
        status: JobStatusExtension.fromString(json['status'] ?? 'pending'),
        projectStatus: AppliedProjectStatusExtension.fromString(
            json['project_status'] ?? 'ongoing'),
        agreement: json['agreement'] != null
            ? AgreementModel.fromJson(json['agreement'])
            : null,
        changeRequest: json['change_request'] != null
            ? ChangeRequestModel.fromJson(json['change_request'])
            : null,
        materials: parseMaterials(json['materials']),
        expertise: json['expertise']?.toString(),
        workMode: json['work_mode']?.toString(),
        clientName: resolveClientName(json),
        clientId: resolveClientId(json),
      );
    } catch (e) {
      // Fallback to basic job model if parsing fails
      return JobModel(
        id: (json['id'] ?? '').toString(),
        title: (json['title'] ?? 'Unknown Job').toString(),
        category: 'General',
        description: (json['description'] ?? '').toString(),
        address: 'Location not specified',
        minBudget: 0,
        maxBudget: 0,
        duration: 'Not specified',
        applied: false,
        saved: false,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'address': address,
      'min_budget': minBudget,
      'max_budget': maxBudget,
      'duration': duration,
      'applied': applied,
      'thumbnail_url': thumbnailUrl,
      'proposal': proposal,
      'payment_type': paymentType,
      'desired_pay': desiredPay,
      'date_created': dateCreated?.toIso8601String(),
      'status': status.name,
      'project_status': projectStatus.name,
      'agreement':
          agreement != null ? (agreement! as AgreementModel).toJson() : null,
      'change_request': changeRequest != null
          ? (changeRequest! as ChangeRequestModel).toJson()
          : null,
      'materials': materials.map((m) => (m as MaterialModel).toJson()).toList(),
      'expertise': expertise,
      'work_mode': workMode,
    };
  }

  Job toEntity() {
    return Job(
      id: id,
      title: title,
      category: category,
      description: description,
      address: address,
      minBudget: minBudget,
      maxBudget: maxBudget,
      duration: duration,
      applied: applied,
      thumbnailUrl: thumbnailUrl,
      proposal: proposal,
      paymentType: paymentType,
      desiredPay: desiredPay,
      dateCreated: dateCreated,
      status: status,
      projectStatus: projectStatus,
      agreement: agreement,
      changeRequest: changeRequest,
      materials: materials.map((m) => (m as MaterialModel).toEntity()).toList(),
      expertise: expertise,
      workMode: workMode,
      clientName: clientName,
      clientId: clientId,
    );
  }
}
