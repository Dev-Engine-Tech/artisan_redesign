import '../../domain/entities/change_request.dart';

class ChangeRequestModel extends ChangeRequest {
  const ChangeRequestModel({
    required super.id,
    required super.proposedChange,
    required super.reason,
  });

  factory ChangeRequestModel.fromJson(Map<String, dynamic> json) {
    return ChangeRequestModel(
      id: json['id'] ?? 0,
      proposedChange: json['proposed_change'] ?? '',
      reason: json['reason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'proposed_change': proposedChange,
      'reason': reason,
    };
  }

  ChangeRequest toEntity() {
    return ChangeRequest(
      id: id,
      proposedChange: proposedChange,
      reason: reason,
    );
  }
}