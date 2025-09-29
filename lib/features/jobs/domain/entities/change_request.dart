import 'package:equatable/equatable.dart';

/// Entity representing a change request for a job agreement
class ChangeRequest extends Equatable {
  final int id;
  final String proposedChange;
  final String reason;

  const ChangeRequest({
    required this.id,
    required this.proposedChange,
    required this.reason,
  });

  @override
  List<Object?> get props => [
    id,
    proposedChange,
    reason,
  ];

  ChangeRequest copyWith({
    int? id,
    String? proposedChange,
    String? reason,
  }) {
    return ChangeRequest(
      id: id ?? this.id,
      proposedChange: proposedChange ?? this.proposedChange,
      reason: reason ?? this.reason,
    );
  }
}