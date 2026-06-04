// lib/providers/job_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/job_model.dart';
import '../data/repositories/job_repository.dart';
import '../providers/auth_provider.dart';

// ─── Repository ──────────────────────────────────────────────────────────────
final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepository();
});

// ─── Filter state ────────────────────────────────────────────────────────────
class JobFilterState {
  final String keyword;
  final String location;
  final JobStatus? statusFilter;

  const JobFilterState({
    this.keyword = '',
    this.location = 'all',
    this.statusFilter,
  });

  JobFilterState copyWith({
    String? keyword,
    String? location,
    JobStatus? statusFilter,
    bool clearStatus = false,
  }) {
    return JobFilterState(
      keyword: keyword ?? this.keyword,
      location: location ?? this.location,
      statusFilter: clearStatus ? null : (statusFilter ?? this.statusFilter),
    );
  }
}

class JobFilterNotifier extends StateNotifier<JobFilterState> {
  JobFilterNotifier() : super(const JobFilterState());

  void updateKeyword(String keyword) {
    state = state.copyWith(keyword: keyword);
  }

  void updateLocation(String location) {
    state = state.copyWith(location: location);
  }

  void updateStatus(JobStatus? status) {
    state = state.copyWith(statusFilter: status, clearStatus: status == null);
  }

  void reset() {
    state = const JobFilterState();
  }
}

final jobFilterProvider =
    StateNotifierProvider<JobFilterNotifier, JobFilterState>((ref) {
  return JobFilterNotifier();
});

// ─── Jobs list (async) ───────────────────────────────────────────────────────
final jobListProvider = FutureProvider<List<JobModel>>((ref) async {
  final repo = ref.watch(jobRepositoryProvider);
  final filter = ref.watch(jobFilterProvider);

  return repo.searchJobs(
    keyword: filter.keyword,
    location: filter.location,
    status: filter.statusFilter,
  );
});

// ─── Locations ───────────────────────────────────────────────────────────────
final locationListProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(jobRepositoryProvider);
  return repo.getLocations();
});

// ─── Single job ──────────────────────────────────────────────────────────────
final jobByIdProvider = FutureProvider.family<JobModel?, String>((ref, id) async {
  final repo = ref.watch(jobRepositoryProvider);
  return repo.getJobById(id);
});

// ─── Recruiter's jobs ────────────────────────────────────────────────────────
final recruiterJobsProvider = FutureProvider<List<JobModel>>((ref) async {
  final repo = ref.watch(jobRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return repo.getJobsByRecruiter(user.id);
});

// ─── Job Operations Notifier ──────────────────────────────────────────────────
class JobState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  JobState({this.isLoading = false, this.isSuccess = false, this.error});

  JobState copyWith({bool? isLoading, bool? isSuccess, String? error}) {
    return JobState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }
}

class JobNotifier extends StateNotifier<JobState> {
  final JobRepository _repository;
  final Ref _ref;

  JobNotifier(this._repository, this._ref) : super(JobState());

  Future<void> saveJob(JobModel job) async {
    state = state.copyWith(isLoading: true);
    final success = await _repository.saveJob(job);
    if (success) {
      state = state.copyWith(isLoading: false, isSuccess: true);
      _ref.invalidate(jobListProvider);
      _ref.invalidate(recruiterJobsProvider);
    } else {
      state = state.copyWith(isLoading: false, error: 'Lỗi khi lưu tin tuyển dụng');
    }
  }

  Future<void> deleteJob(String jobId) async {
    state = state.copyWith(isLoading: true);
    final success = await _repository.deleteJob(jobId);
    if (success) {
      state = state.copyWith(isLoading: false, isSuccess: true);
      _ref.invalidate(jobListProvider);
      _ref.invalidate(recruiterJobsProvider);
    } else {
      state = state.copyWith(isLoading: false, error: 'Lỗi khi xóa tin');
    }
  }

  void reset() {
    state = JobState();
  }
}

final jobOpsProvider = StateNotifierProvider<JobNotifier, JobState>((ref) {
  final repo = ref.watch(jobRepositoryProvider);
  return JobNotifier(repo, ref);
});
