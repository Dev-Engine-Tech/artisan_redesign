import 'package:equatable/equatable.dart';

class BankAccount extends Equatable {
  final String id;
  final String bankName;
  final String? bankCode;
  final String accountName;
  final String accountNumber;

  const BankAccount({
    required this.id,
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    this.bankCode,
  });

  @override
  List<Object?> get props =>
      [id, bankName, bankCode, accountName, accountNumber];
}

class BankInfo extends Equatable {
  final String name;
  final String code;
  const BankInfo({required this.name, required this.code});
  @override
  List<Object?> get props => [name, code];
}
