import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job_application.dart';
import 'package:artisans_circle/features/jobs/domain/repositories/job_repository.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/get_jobs.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/apply_to_job.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/accept_agreement.dart';

class MockJobRepository extends Mock implements JobRepository {}

void main() {
  late MockJobRepository mockRepository;
  late GetJobs getJobs;
  late ApplyToJob applyToJob;
  late AcceptAgreement acceptAgreement;

  setUpAll(() {
    registerFallbackValue(const JobApplication(
      job: 1,
      duration: '1 week',
      proposal: 'Test proposal',
      paymentType: 'project',
      desiredPay: 5000,
    ));
  });

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

  final sampleApplication = JobApplication(
    job: 1,
    duration: '1 week',
    proposal: 'I can complete this job excellently',
    paymentType: 'project',
    desiredPay: 5000,
    milestones: [],
    materials: [],
    attachments: [],
  );

  setUp(() {
    mockRepository = MockJobRepository();
    getJobs = GetJobs(mockRepository);
    applyToJob = ApplyToJob(mockRepository);
    acceptAgreement = AcceptAgreement(mockRepository);
  });

  group('GetJobs usecase', () {
    test('calls repository.getJobs and returns list of jobs', () async {
      when(() => mockRepository.getJobs(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => [sampleJob]);

      final result = await getJobs(page: 1, limit: 10);

      expect(result, isA<List<Job>>());
      expect(result.length, 1);
      expect(result.first.id, '1');
      verify(() => mockRepository.getJobs(page: 1, limit: 10)).called(1);
    });

    test('propagates exceptions from repository', () async {
      when(() => mockRepository.getJobs(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenThrow(Exception('network error'));

      expect(() => getJobs(page: 1, limit: 10), throwsA(isA<Exception>()));
    });
  });

  group('ApplyToJob usecase', () {
    test('returns true when repository.applyToJob succeeds', () async {
      when(() => mockRepository.applyToJob(any())).thenAnswer((_) async => true);

      final result = await applyToJob(sampleApplication);

      expect(result, true);
      verify(() => mockRepository.applyToJob(any())).called(1);
    });

    test('propagates exceptions from repository', () async {
      when(() => mockRepository.applyToJob(any())).thenThrow(Exception('apply failed'));

      expect(() => applyToJob(sampleApplication), throwsA(isA<Exception>()));
    });
  });

  group('AcceptAgreement usecase', () {
    test('returns true when repository.acceptAgreement succeeds', () async {
      when(() => mockRepository.acceptAgreement('1')).thenAnswer((_) async => true);

      final result = await acceptAgreement('1');

      expect(result, true);
      verify(() => mockRepository.acceptAgreement('1')).called(1);
    });

    test('propagates exceptions from repository', () async {
      when(() => mockRepository.acceptAgreement('1')).thenThrow(Exception('agreement failed'));

      expect(() => acceptAgreement('1'), throwsA(isA<Exception>()));
    });
  });
}
