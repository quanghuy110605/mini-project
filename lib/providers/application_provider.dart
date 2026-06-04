// lib/providers/application_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/application_model.dart';
import '../data/models/user_model.dart';
import '../data/repositories/application_repository.dart';
import 'auth_provider.dart';
import 'job_provider.dart';

// ─── Repository ──────────────────────────────────────────────────────────────
final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return ApplicationRepository();
});

// ─── Application list state ──────────────────────────────────────────────────
class ApplicationListNotifier
    extends StateNotifier<AsyncValue<List<ApplicationModel>>> {
  final ApplicationRepository _repository;

  ApplicationListNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = const AsyncValue.loading();
    try {
      final apps = await _repository.getApplications();
      state = AsyncValue.data(apps);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateStatus(
      String applicationId, ApplicationStatus status) async {
    await _repository.updateStatus(applicationId, status);
    // Reload list after update
    await loadAll();
  }

  Future<void> apply({
    required String jobId,
    required String candidateId,
    required String cvId,
    required String jobTitle,
    required String companyName,
    required String coverLetter,
  }) async {
    await _repository.apply(
      jobId: jobId,
      candidateId: candidateId,
      cvId: cvId,
      jobTitle: jobTitle,
      companyName: companyName,
      coverLetter: coverLetter,
    );
    await loadAll();
  }
}

final applicationListProvider = StateNotifierProvider<ApplicationListNotifier,
    AsyncValue<List<ApplicationModel>>>((ref) {
  final repo = ref.watch(applicationRepositoryProvider);
  return ApplicationListNotifier(repo);
});

// ─── Filtered applications for recruiter ────────────────────────────────────
final recruiterApplicationsProvider =
    FutureProvider<List<ApplicationModel>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  final allAppsAsync = ref.watch(applicationListProvider);
  final jobRepo = ref.watch(jobRepositoryProvider);

  if (currentUser == null) return [];
  
  if (allAppsAsync is AsyncLoading) {
    // Keep loading until apps are loaded
    await Future.delayed(const Duration(milliseconds: 100));
    return []; // Or throw to trigger loading state if we really wanted to, but Riverpod handles FutureProvider well
  }

  final apps = allAppsAsync.value ?? [];
  if (currentUser.role == UserRole.admin) return apps;

  final recruiterJobs = await jobRepo.getJobsByRecruiter(currentUser.id);
  final recruiterJobIds = recruiterJobs.map((j) => j.id).toSet();
  
  return apps.where((a) => recruiterJobIds.contains(a.jobId)).toList();
});

// ─── Applications for current candidate ──────────────────────────────────────
final candidateApplicationsProvider =
    Provider<AsyncValue<List<ApplicationModel>>>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  final allApps = ref.watch(applicationListProvider);

  if (currentUser == null) return const AsyncValue.data([]);

  return allApps.whenData(
    (apps) => apps.where((a) => a.candidateId == currentUser.id).toList(),
  );
});
