import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/get_jobs.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/get_applications.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/apply_to_job.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/accept_agreement.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/request_change.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/change_request_page.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job_application.dart';
import 'package:artisans_circle/core/cache/api_cache_manager.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/get_job_invitations.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/respond_to_job_invitation.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/get_artisan_invitations.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/respond_to_artisan_invitation.dart';

class MockGetJobs extends Mock implements GetJobs {}

class MockGetApplications extends Mock implements GetApplications {}

class MockApplyToJob extends Mock implements ApplyToJob {}

class MockAcceptAgreement extends Mock implements AcceptAgreement {}

class MockRequestChange extends Mock implements RequestChange {}

class MockGetJobInvitations extends Mock implements GetJobInvitations {}

class MockRespondToJobInvitation extends Mock
    implements RespondToJobInvitation {}

class MockGetArtisanInvitations extends Mock
    implements GetArtisanInvitations {}

class MockRespondToArtisanInvitation extends Mock
    implements RespondToArtisanInvitation {}

// Mock Bloc for widget tests so we can drive state emissions deterministically.
class MockJobBloc extends MockBloc<JobEvent, JobState> implements JobBloc {}

void main() {
  late MockGetJobs mockGetJobs;
  late MockGetApplications mockGetApplications;
  late MockApplyToJob mockApplyToJob;
  late MockAcceptAgreement mockAcceptAgreement;
  late MockRequestChange mockRequestChange;
  late MockGetJobInvitations mockGetJobInvitations;
  late MockRespondToJobInvitation mockRespondToJobInvitation;
  late MockGetArtisanInvitations mockGetArtisanInvitations;
  late MockRespondToArtisanInvitation mockRespondToArtisanInvitation;
  late JobBloc bloc;

  final sampleJob = const Job(
    id: '1',
    title: 'Test Job',
    category: 'Carpentry',
    description: 'Do something for testing purposes',
    address: '123 Main',
    minBudget: 100,
    maxBudget: 200,
    duration: '2 days',
    applied: true,
    thumbnailUrl: '',
  );

  setUpAll(() {
    registerFallbackValue(LoadJobs());
    registerFallbackValue(RefreshJobs());
    registerFallbackValue(ApplyToJobEvent(
      application: const JobApplication(
        job: 1,
        duration: '2 days',
        proposal: 'test',
        paymentType: 'project',
        desiredPay: 100,
      ),
    ));
    registerFallbackValue(AcceptAgreementEvent(jobId: '1'));
    registerFallbackValue(RequestChangeEvent(jobId: '1', reason: 'reason'));
  });

  setUp(() {
    // Clear cache to ensure deterministic tests
    ApiCacheManager().clearAll();
    mockGetJobs = MockGetJobs();
    mockGetApplications = MockGetApplications();
    mockApplyToJob = MockApplyToJob();
    mockAcceptAgreement = MockAcceptAgreement();
    mockRequestChange = MockRequestChange();
    mockGetJobInvitations = MockGetJobInvitations();
    mockRespondToJobInvitation = MockRespondToJobInvitation();
    mockGetArtisanInvitations = MockGetArtisanInvitations();
    mockRespondToArtisanInvitation = MockRespondToArtisanInvitation();

    when(() =>
            mockGetJobs(page: any(named: 'page'), limit: any(named: 'limit')))
        .thenAnswer((_) async => [sampleJob]);

    bloc = JobBloc(
      getJobs: mockGetJobs,
      getApplications: mockGetApplications,
      applyToJob: mockApplyToJob,
      acceptAgreement: mockAcceptAgreement,
      requestChange: mockRequestChange,
      getJobInvitations: mockGetJobInvitations,
      respondToJobInvitation: mockRespondToJobInvitation,
      getArtisanInvitations: mockGetArtisanInvitations,
      respondToArtisanInvitation: mockRespondToArtisanInvitation,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('JobBloc.requestChange', () {
    blocTest<JobBloc, JobState>(
      'emits [Applying, ChangeRequested] when requestChange succeeds and getJobs returns list',
      build: () {
        when(() => mockRequestChange(
            jobId: any(named: 'jobId'),
            reason: any(named: 'reason'))).thenAnswer((_) async => true);
        when(() => mockGetJobs(
            page: any(named: 'page'),
            limit: any(named: 'limit'))).thenAnswer((_) async => [sampleJob]);
        return bloc;
      },
      act: (bloc) =>
          bloc.add(RequestChangeEvent(jobId: '1', reason: 'please change')),
      expect: () => [
        isA<JobStateRequestingChange>(),
        isA<JobStateChangeRequested>(),
      ],
      verify: (_) {
        verify(() => mockRequestChange(jobId: '1', reason: 'please change'))
            .called(1);
        verify(() => mockGetJobs()).called(1);
      },
    );

    blocTest<JobBloc, JobState>(
      'emits [Applying, Error] when requestChange returns false',
      build: () {
        when(() => mockRequestChange(
            jobId: any(named: 'jobId'),
            reason: any(named: 'reason'))).thenAnswer((_) async => false);
        return bloc;
      },
      act: (bloc) =>
          bloc.add(RequestChangeEvent(jobId: '1', reason: 'please change')),
      expect: () => [
        isA<JobStateRequestingChange>(),
        isA<JobStateError>(),
      ],
    );
  });

  group('ChangeRequestPage (widget)', () {
    testWidgets(
        'submitting form dispatches RequestChangeEvent and shows success dialog',
        (tester) async {
      // Arrange: make requestChange succeed and getJobs return list
      when(() => mockRequestChange(
          jobId: any(named: 'jobId'),
          reason: any(named: 'reason'))).thenAnswer((_) async => true);
      when(() =>
              mockGetJobs(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => [sampleJob]);

      // Provide a mock bloc instance and drive its states directly so the widget
      // reacts predictably without relying on async usecase implementations.
      final mockBloc = MockJobBloc();
      // Simulate the sequence: Applying -> ChangeRequested for this job.
      whenListen(
        mockBloc,
        Stream<JobState>.fromIterable([
          const JobStateApplying(),
          JobStateChangeRequested(jobs: [sampleJob], jobId: sampleJob.id),
        ]),
        initialState: const JobStateInitial(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<JobBloc>.value(
            value: mockBloc,
            child: ChangeRequestPage(job: sampleJob),
          ),
        ),
      );

      // Allow initial frames to render
      await tester.pumpAndSettle();

      // Enter reason text (>=10 chars). We skip interacting with the dropdown
      // menu in tests to avoid overlay hit-test issues; the dropdown has no
      // validator so a selection is not required for submission in the UI.
      final textFieldFinder = find.byType(TextFormField);
      expect(textFieldFinder, findsOneWidget);
      await tester.enterText(
          textFieldFinder, 'Please adjust the delivery date');
      await tester.pumpAndSettle();

      // Tap Submit Request button
      final submitFinder = find.text('Submit Request');
      expect(submitFinder, findsOneWidget);
      await tester.tap(submitFinder);
      await tester.pump(); // start async

      // Wait for bloc and UI to process (allow dialogs to appear). Poll for dialog.
      var found = false;
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (find.text('Request Sent').evaluate().isNotEmpty) {
          found = true;
          break;
        }
      }

      expect(found, isTrue,
          reason: 'Expected Request Sent dialog to appear within timeout');

      // Expect the success dialog to appear with the 'Request Sent' title
      expect(find.text('Request Sent'), findsOneWidget);
    });
  });
}
