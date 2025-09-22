import 'package:equatable/equatable.dart';

class JobApplication extends Equatable {
  final int job; // job id as int
  final String duration; // e.g., '1 week', '3 days'
  final String proposal;
  final String paymentType; // 'project' or 'milestone'
  final int desiredPay; // total pay when paymentType == 'project'
  final List<JobMilestone> milestones; // used when paymentType == 'milestone'
  final List<JobMaterial> materials;
  final List<dynamic> attachments; // placeholder for file references
  final JobInspectionFee? inspection;

  const JobApplication({
    required this.job,
    required this.duration,
    required this.proposal,
    required this.paymentType,
    required this.desiredPay,
    this.milestones = const [],
    this.materials = const [],
    this.attachments = const [],
    this.inspection,
  });

  Map<String, dynamic> toJson() {
    return {
      'job': job,
      'duration': duration,
      'proposal': proposal,
      'payment_type': paymentType,
      'desired_pay': desiredPay,
      'milestones': milestones.map((m) => m.toJson()).toList(),
      'materials': materials.map((m) => m.toJson()).toList(),
      'attachments': attachments,
      if (inspection != null) 'inspection': inspection!.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        job,
        duration,
        proposal,
        paymentType,
        desiredPay,
        milestones,
        materials,
        attachments,
        inspection,
      ];
}

class JobMaterial extends Equatable {
  final String description;
  final int quantity;
  final int price; // per-unit or total, per API contract

  const JobMaterial({
    required this.description,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
        'description': description,
        'material': description,
        'quantity': quantity,
        'price': price,
      };

  @override
  List<Object?> get props => [description, quantity, price];
}

class JobMilestone extends Equatable {
  final String description;
  final DateTime dueDate;
  final int amount;

  const JobMilestone({
    required this.description,
    required this.dueDate,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        'description': description,
        'material': description,
        'due_date':
            '${dueDate.year.toString().padLeft(4, '0')}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}',
        'amount': amount,
      };

  @override
  List<Object?> get props => [description, dueDate, amount];
}

class JobInspectionFee extends Equatable {
  final String amount; // expressed as string in old app
  final bool isPaid;

  const JobInspectionFee({required this.amount, this.isPaid = false});

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'is_paid': isPaid,
      };

  @override
  List<Object?> get props => [amount, isPaid];
}
