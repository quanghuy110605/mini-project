// lib/providers/cv_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/cv_model.dart';
import '../data/repositories/cv_repository.dart';
import 'auth_provider.dart';

// ─── Repository ──────────────────────────────────────────────────────────────
final cvRepositoryProvider = Provider<CvRepository>((ref) {
  return CvRepository();
});

// ─── CV State ────────────────────────────────────────────────────────────────
class CvState {
  final CvModel? cv;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final bool saveSuccess;

  const CvState({
    this.cv,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.saveSuccess = false,
  });

  CvState copyWith({
    CvModel? cv,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool? saveSuccess,
    bool clearError = false,
  }) {
    return CvState(
      cv: cv ?? this.cv,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      saveSuccess: saveSuccess ?? this.saveSuccess,
    );
  }
}

// ─── CV Notifier ─────────────────────────────────────────────────────────────
class CvNotifier extends StateNotifier<CvState> {
  final CvRepository _repository;
  final String? _userId;

  CvNotifier(this._repository, this._userId) : super(const CvState()) {
    if (_userId != null) loadCv();
  }

  Future<void> loadCv() async {
    if (_userId == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final cv = await _repository.getCvByUserId(_userId);
      state = state.copyWith(cv: cv, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> saveCV(CvModel cv) async {
    state = state.copyWith(isSaving: true, saveSuccess: false, clearError: true);
    try {
      final saved = await _repository.saveCV(cv);
      state = state.copyWith(cv: saved, isSaving: false, saveSuccess: true);
    } catch (e) {
      state = state.copyWith(
          isSaving: false, errorMessage: 'Lưu CV thất bại: ${e.toString()}');
    }
  }

  void clearSaveSuccess() {
    state = state.copyWith(saveSuccess: false);
  }
}

final cvProvider = StateNotifierProvider<CvNotifier, CvState>((ref) {
  final repo = ref.watch(cvRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return CvNotifier(repo, user?.id);
});
