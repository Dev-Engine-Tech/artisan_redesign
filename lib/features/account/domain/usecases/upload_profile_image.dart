import '../repositories/account_repository.dart';

class UploadProfileImage {
  final AccountRepository repository;
  UploadProfileImage(this.repository);

  Future<String> call(String path) => repository.uploadProfileImage(path);
}
