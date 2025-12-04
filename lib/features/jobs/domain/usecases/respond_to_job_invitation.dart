import '../repositories/job_repository.dart';

class RespondToJobInvitation {
  final JobRepository repository;

  RespondToJobInvitation(this.repository);

  Future<bool> call(String invitationId, {required bool accept}) async {
    return await repository.respondToJobInvitation(invitationId, accept: accept);
  }
}
