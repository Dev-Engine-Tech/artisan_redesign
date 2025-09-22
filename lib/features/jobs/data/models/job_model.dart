import 'package:artisans_circle/features/jobs/domain/entities/job.dart';

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
    super.agreementSent = false,
    super.agreementAccepted = false,
    super.thumbnailUrl = '',
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      final s = v.toString();
      return int.tryParse(s.replaceAll(',', '').split('.').first) ?? 0;
    }

    // Resolve category possibly being a nested object
    String resolveCategory(dynamic cat) {
      if (cat is Map) {
        return (cat['name'] ?? cat['title'] ?? '').toString();
      }
      return (cat ?? '').toString();
    }

    // Resolve address from location -> display_name or job_address or address
    String resolveAddress(Map<String, dynamic> m) {
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
    }

    // Budget: use explicit fields or fallback to 'pay'
    final minBudget =
        toInt(json['min_budget'] ?? json['minBudget'] ?? json['pay']);
    final maxBudget =
        toInt(json['max_budget'] ?? json['maxBudget'] ?? json['pay']);

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

    return JobModel(
      id: (json['id'] ?? json['job_id'] ?? '').toString(),
      title: (json['title'] ?? json['job_title'] ?? '').toString(),
      category: resolveCategory(json['category'] ?? json['job_category']),
      description: (json['description'] ?? '').toString(),
      address: resolveAddress(json),
      minBudget: minBudget,
      maxBudget: maxBudget,
      duration: (json['duration'] ?? '').toString(),
      applied: (json['applied'] ?? json['is_applied'] ?? false) == true,
      agreementSent:
          (json['agreement_sent'] ?? json['agreementSent'] ?? false) == true,
      agreementAccepted:
          (json['agreement_accepted'] ?? json['agreementAccepted'] ?? false) ==
              true,
      thumbnailUrl: resolveThumb(json),
    );
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
      'agreement_sent': agreementSent,
      'agreement_accepted': agreementAccepted,
      'thumbnail_url': thumbnailUrl,
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
      agreementSent: agreementSent,
      agreementAccepted: agreementAccepted,
      thumbnailUrl: thumbnailUrl,
    );
  }
}
