import 'package:equatable/equatable.dart';

class BankListItem extends Equatable {
  final String name;
  final String code;

  const BankListItem({
    required this.name,
    required this.code,
  });

  @override
  List<Object> get props => [name, code];
}
