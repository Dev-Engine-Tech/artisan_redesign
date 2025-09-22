import 'package:equatable/equatable.dart';

class Job extends Equatable {
  final String id;
  final String title;
  final String category;
  final String description;
  final String address;
  final int minBudget;
  final int maxBudget;
  final String duration;
  final bool applied;

  // New fields to model agreement flow on applications
  final bool agreementSent;
  final bool agreementAccepted;

  final String thumbnailUrl;

  const Job({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.address,
    required this.minBudget,
    required this.maxBudget,
    required this.duration,
    this.applied = false,
    this.agreementSent = false,
    this.agreementAccepted = false,
    this.thumbnailUrl = '',
  });

  @override
  List<Object?> get props => [
        id,
        title,
        category,
        description,
        address,
        minBudget,
        maxBudget,
        duration,
        applied,
        agreementSent,
        agreementAccepted,
        thumbnailUrl,
      ];

  Job copyWith({
    String? id,
    String? title,
    String? category,
    String? description,
    String? address,
    int? minBudget,
    int? maxBudget,
    String? duration,
    bool? applied,
    bool? agreementSent,
    bool? agreementAccepted,
    String? thumbnailUrl,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      address: address ?? this.address,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
      duration: duration ?? this.duration,
      applied: applied ?? this.applied,
      agreementSent: agreementSent ?? this.agreementSent,
      agreementAccepted: agreementAccepted ?? this.agreementAccepted,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }
}
