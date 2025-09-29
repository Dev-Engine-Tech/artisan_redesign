import 'package:equatable/equatable.dart';

/// Entity representing a client in catalog requests
class Client extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? homeAddress;
  final String? profilePic;
  final ClientState? state;

  const Client({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.homeAddress,
    this.profilePic,
    this.state,
  });

  /// Full name getter
  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        phone,
        homeAddress,
        profilePic,
        state,
      ];

  Client copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? homeAddress,
    String? profilePic,
    ClientState? state,
  }) {
    return Client(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      homeAddress: homeAddress ?? this.homeAddress,
      profilePic: profilePic ?? this.profilePic,
      state: state ?? this.state,
    );
  }
}

/// Entity representing a state/location for clients
class ClientState extends Equatable {
  final int id;
  final String name;

  const ClientState({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];

  ClientState copyWith({
    int? id,
    String? name,
  }) {
    return ClientState(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
