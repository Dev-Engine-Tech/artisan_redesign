import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/get_jobs.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/get_applications.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/apply_to_job.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/accept_agreement.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/request_change.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job_application.dart';

class MockGetJobs extends Mock implements GetJobs {}

class MockGetApplications extends Mock implements GetApplications {}

class MockApplyToJob extends Mock implements ApplyToJob {}

class MockAcceptAgreement extends Mock implements AcceptAgreement {}

class MockRequestChange extends Mock implements RequestChange {}

void main() {
  late MockGetJobs mockGetJobs;
  late MockGetApplications mockGetApplications;
  late MockApplyToJob mockApplyToJob;
  late MockAcceptAgreement mockAcceptAgreement;
  late MockRequestChange mockRequestChange;
  late JobBloc bloc;

  final sampleJob = Job(
    id: '1',
    title: 'Test Job',
    category: 'Carpentry',
    description: 'Do something',
    address: '123 Main',
    minBudget: 100,
    maxBudget: 200,
    duration: '2 days',
    applied: false,
    thumbnailUrl: '',
  );

  setUpAll(() {
    registerFallbackValue(LoadJobs());
    registerFallbackValue(RefreshJobs());
    registerFallbackValue(ApplyToJobEvent(
      application: JobApplication(
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
    mockGetJobs = MockGetJobs();
    mockGetApplications = MockGetApplications();
    mockApplyToJob = MockApplyToJob();
    mockAcceptAgreement = MockAcceptAgreement();
    mockRequestChange = MockRequestChange();

    bloc = JobBloc(
      getJobs: mockGetJobs,
      getApplications: mockGetApplications,
      applyToJob: mockApplyToJob,
      acceptAgreement: mockAcceptAgreement,
      requestChange: mockRequestChange,
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state is JobStateInitial', () {
    expect(bloc.state, isA<JobStateInitial>());
  });

  group('LoadJobs', () {
    blocTest<JobBloc, JobState>(
      'emits [Loading, Loaded] when getJobs succeeds',
      build: () {
        when(() => mockGetJobs(
            page: any(named: 'page'),
            limit: any(named: 'limit'))).thenAnswer((_) async => [sampleJob]);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadJobs(page: 1, limit: 10)),
      expect: () => [
        isA<JobStateLoading>(),
        isA<JobStateLoaded>(),
      ],
      verify: (_) {
        verify(() => mockGetJobs(page: 1, limit: 10)).called(1);
      },
    );

    blocTest<JobBloc, JobState>(
      'emits [Loading, Error] when getJobs throws',
      build: () {
        when(() => mockGetJobs(
            page: any(named: 'page'),
            limit: any(named: 'limit'))).thenThrow(Exception('network'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadJobs(page: 1, limit: 10)),
      expect: () => [
        isA<JobStateLoading>(),
        isA<JobStateError>(),
      ],
    );
  });

  group('ApplyToJobEvent', () {
    blocTest<JobBloc, JobState>(
      'emits [Applying, AppliedSuccess] when applyToJob succeeds and getJobs returns list',
      build: () {
        when(() => mockApplyToJob(any(that: isA<JobApplication>())))
            .thenAnswer((_) async => true);
        when(() => mockGetJobs(
            page: any(named: 'page'),
            limit: any(named: 'limit'))).thenAnswer((_) async => [sampleJob]);
        return bloc;
      },
      act: (bloc) => bloc.add(ApplyToJobEvent(
        application: JobApplication(
          job: 1,
          duration: '2 days',
          proposal: 'test',
          paymentType: 'project',
          desiredPay: 100,
        ),
      )),
      expect: () => [
        isA<JobStateApplying>(),
        isA<JobStateAppliedSuccess>(),
      ],
      verify: (_) {
        verify(() => mockApplyToJob(any(that: isA<JobApplication>())))
            .called(1);
        verify(() => mockGetJobs()).called(1);
      },
    );

    blocTest<JobBloc, JobState>(
      'emits [Applying, Error] when applyToJob returns false',
      build: () {
        when(() => mockApplyToJob(any(that: isA<JobApplication>())))
            .thenAnswer((_) async => false);
        return bloc;
      },
      act: (bloc) => bloc.add(ApplyToJobEvent(
        application: JobApplication(
          job: 1,
          duration: '2 days',
          proposal: 'test',
          paymentType: 'project',
          desiredPay: 100,
        ),
      )),
      expect: () => [
        isA<JobStateApplying>(),
        isA<JobStateError>(),
      ],
    );

    blocTest<JobBloc, JobState>(
      'emits [Applying, Error] when applyToJob throws',
      build: () {
        when(() => mockApplyToJob(any(that: isA<JobApplication>())))
            .thenThrow(Exception('apply failed'));
        return bloc;
      },
      act: (bloc) => bloc.add(ApplyToJobEvent(
        application: JobApplication(
          job: 1,
          duration: '2 days',
          proposal: 'test',
          paymentType: 'project',
          desiredPay: 100,
        ),
      )),
      expect: () => [
        isA<JobStateApplying>(),
        isA<JobStateError>(),
      ],
    );
  });

  group('AcceptAgreementEvent', () {
    blocTest<JobBloc, JobState>(
      'emits [Applying, AgreementAccepted] when acceptAgreement succeeds and getJobs returns list',
      build: () {
        when(() => mockAcceptAgreement('1')).thenAnswer((_) async => true);
        when(() => mockGetJobs(
            page: any(named: 'page'),
            limit: any(named: 'limit'))).thenAnswer((_) async => [sampleJob]);
        return bloc;
      },
      act: (bloc) => bloc.add(AcceptAgreementEvent(jobId: '1')),
      expect: () => [
        isA<JobStateApplying>(),
        isA<JobStateAgreementAccepted>(),
      ],
      verify: (_) {
        verify(() => mockAcceptAgreement('1')).called(1);
        verify(() => mockGetJobs()).called(1);
      },
    );

    blocTest<JobBloc, JobState>(
      'emits [Applying, Error] when acceptAgreement returns false',
      build: () {
        when(() => mockAcceptAgreement('1')).thenAnswer((_) async => false);
        return bloc;
      },
      act: (bloc) => bloc.add(AcceptAgreementEvent(jobId: '1')),
      expect: () => [
        isA<JobStateApplying>(),
        isA<JobStateError>(),
      ],
    );

    blocTest<JobBloc, JobState>(
      'emits [Applying, Error] when acceptAgreement throws',
      build: () {
        when(() => mockAcceptAgreement('1'))
            .thenThrow(Exception('agreement failed'));
        return bloc;
      },
      act: (bloc) => bloc.add(AcceptAgreementEvent(jobId: '1')),
      expect: () => [
        isA<JobStateApplying>(),
        isA<JobStateError>(),
      ],
    );
  });
}
