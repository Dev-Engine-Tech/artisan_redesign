import '../../domain/entities/bank_account.dart';

class BankAccountModel extends BankAccount {
  const BankAccountModel({
    required String id,
    required String bankName,
    String? bankCode,
    required String accountName,
    required String accountNumber,
  }) : super(
          id: id,
          bankName: bankName,
          bankCode: bankCode,
          accountName: accountName,
          accountNumber: accountNumber,
        );

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: json['id']?.toString() ?? json['acc_id']?.toString() ?? '',
      bankName: json['bank_name']?.toString() ?? json['bankName']?.toString() ?? '',
      bankCode: json['bank_code']?.toString() ?? json['code']?.toString(),
      accountName: json['account_name']?.toString() ??
          json['accountName']?.toString() ??
          '',
      accountNumber: json['account_number']?.toString() ??
          json['accountNumber']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bank_name': bankName,
        'bank_code': bankCode,
        'account_name': accountName,
        'account_number': accountNumber,
      };
}

class BankInfoModel extends BankInfo {
  const BankInfoModel({required String name, required String code})
      : super(name: name, code: code);

  factory BankInfoModel.fromJson(Map<String, dynamic> json) {
    return BankInfoModel(
      name: json['name']?.toString() ?? json['bank_name']?.toString() ?? '',
      code: json['code']?.toString() ?? json['bank_code']?.toString() ?? '',
    );
  }
}
