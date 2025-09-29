import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

@immutable
class VerificationState {
  final bool submitting;
  final bool identitySubmitted;
  final bool selfieCaptured;
  final String? idDocumentPath;
  final String? selfiePath;
  final String? error;

  const VerificationState({
    this.submitting = false,
    this.identitySubmitted = false,
    this.selfieCaptured = false,
    this.idDocumentPath,
    this.selfiePath,
    this.error,
  });

  VerificationState copyWith({
    bool? submitting,
    bool? identitySubmitted,
    bool? selfieCaptured,
    String? idDocumentPath,
    String? selfiePath,
    String? error,
  }) {
    return VerificationState(
      submitting: submitting ?? this.submitting,
      identitySubmitted: identitySubmitted ?? this.identitySubmitted,
      selfieCaptured: selfieCaptured ?? this.selfieCaptured,
      idDocumentPath: idDocumentPath ?? this.idDocumentPath,
      selfiePath: selfiePath ?? this.selfiePath,
      error: error,
    );
  }
}

class VerificationCubit extends Cubit<VerificationState> {
  final Duration idDelay;
  final Duration selfieDelay;
  final Duration finalizeDelay;

  /// Delays are configurable to make the cubit test-friendly.
  /// Defaults match the previous simulated timings used in the app.
  VerificationCubit({
    Duration? idDelay,
    Duration? selfieDelay,
    Duration? finalizeDelay,
  })  : idDelay = idDelay ?? const Duration(milliseconds: 400),
        selfieDelay = selfieDelay ?? const Duration(milliseconds: 400),
        finalizeDelay = finalizeDelay ?? const Duration(milliseconds: 600),
        super(const VerificationState());

  /// Simulate uploading an ID document (accepts a local path or null)
  Future<void> submitIdentity({required String idDocumentPath}) async {
    emit(state.copyWith(submitting: true, error: null));
    await Future.delayed(idDelay);
    emit(
        state.copyWith(submitting: false, identitySubmitted: true, idDocumentPath: idDocumentPath));
  }

  /// Capture selfie path and mark captured
  Future<void> submitSelfie({required String selfiePath}) async {
    emit(state.copyWith(submitting: true, error: null));
    await Future.delayed(selfieDelay);
    emit(state.copyWith(submitting: false, selfieCaptured: true, selfiePath: selfiePath));
  }

  /// Finalize verification - in a real app this should call a repository to upload images
  Future<void> finalizeVerification() async {
    if (!state.identitySubmitted || !state.selfieCaptured) {
      emit(state.copyWith(error: 'Please provide ID and a selfie before submitting.'));
      return;
    }
    emit(state.copyWith(submitting: true, error: null));
    await Future.delayed(finalizeDelay);
    // In a real implementation we'd return server response and update AuthBloc / repository.
    emit(state.copyWith(submitting: false));
  }

  void clearError() {
    if (state.error != null) emit(state.copyWith(error: null));
  }
}
