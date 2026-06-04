// lib/views/jobs/job_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/job_model.dart';
import '../../providers/job_provider.dart';
import '../../views/shared/app_scaffold.dart';
import 'widgets/job_card.dart';

class JobListScreen extends ConsumerWidget {
  const JobListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _JobListContent();
  }
}

class _JobListContent extends ConsumerStatefulWidget {
  @override
  ConsumerState<_JobListContent> createState() => _JobListContentState();
}

class _JobListContentState extends ConsumerState<_JobListContent> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(jobListProvider);
    final filter = ref.watch(jobFilterProvider);
    final locations = ref.watch(locationListProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 1100;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Danh sách việc làm',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  jobsAsync.when(
                    data: (jobs) => Text(
                      '${jobs.length} vị trí đang tuyển',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                    ),
                    loading: () => const Text('Đang tải...'),
                    error: (_, __) => const SizedBox(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Search & Filter bar ──────────────────────────────────────────
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              // Search field - take more space if available
              SizedBox(
                width: isDesktop ? 400 : double.infinity,
                child: _SearchField(controller: _searchController),
              ),
              // Location filter
              SizedBox(
                width: isDesktop ? 220 : (MediaQuery.of(context).size.width - 60) / 2,
                child: locations.when(
                  data: (locs) => _LocationFilter(locations: locs),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => _LocationFilter(locations: []),
                ),
              ),
              // Status filter
              SizedBox(
                width: isDesktop ? 200 : (MediaQuery.of(context).size.width - 60) / 2,
                child: _StatusFilter(),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Active filters
          if (filter.keyword.isNotEmpty || filter.location != 'all' || filter.statusFilter != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  const Text('Bộ lọc: ',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                  if (filter.keyword.isNotEmpty)
                    _FilterChip(label: 'Từ khóa: "${filter.keyword}"'),
                  if (filter.location != 'all')
                    _FilterChip(label: '📍 ${filter.location}'),
                  if (filter.statusFilter != null)
                    _FilterChip(
                        label: filter.statusFilter == JobStatus.open
                            ? '🟢 Đang tuyển'
                            : '🔴 Đã đóng'),
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      ref.read(jobFilterProvider.notifier).reset();
                    },
                    child: const Text('Xóa tất cả',
                        style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // ── Job grid ─────────────────────────────────────────────────────
          Expanded(
            child: jobsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Center(
                child: Text('Lỗi: $e',
                    style: const TextStyle(color: AppColors.error)),
              ),
              data: (jobs) {
                if (jobs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 64, color: AppColors.textHint),
                        const SizedBox(height: 16),
                        const Text(
                          AppStrings.noJobsFound,
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            ref.read(jobFilterProvider.notifier).reset();
                          },
                          child: const Text('Xóa bộ lọc'),
                        ),
                      ],
                    ),
                  );
                }

                final crossAxisCount = _getCrossAxisCount(context);

                return MasonryGridView.count(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    return JobCard(job: jobs[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1400) return 4;
    if (width >= 1000) return 3;
    if (width >= 600) return 2;
    return 1;
  }
}

// ─── Search Field ─────────────────────────────────────────────────────────────
class _SearchField extends ConsumerWidget {
  final TextEditingController controller;

  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      controller: controller,
      onChanged: (v) => ref.read(jobFilterProvider.notifier).updateKeyword(v),
      decoration: InputDecoration(
        hintText: AppStrings.searchJobs,
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  controller.clear();
                  ref.read(jobFilterProvider.notifier).updateKeyword('');
                },
              )
            : null,
      ),
    );
  }
}

// ─── Location Filter ──────────────────────────────────────────────────────────
class _LocationFilter extends ConsumerWidget {
  final List<String> locations;

  const _LocationFilter({required this.locations});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(jobFilterProvider);

    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: filter.location,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.textHint),
      ),
      items: [
        const DropdownMenuItem(
            value: 'all', child: Text(AppStrings.allLocations)),
        ...locations.map(
          (loc) => DropdownMenuItem(value: loc, child: Text(loc)),
        ),
      ],
      onChanged: (v) {
        if (v != null) {
          ref.read(jobFilterProvider.notifier).updateLocation(v);
        }
      },
    );
  }
}

// ─── Status Filter ────────────────────────────────────────────────────────────
class _StatusFilter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(jobFilterProvider);

    return DropdownButtonFormField<JobStatus?>(
      isExpanded: true,
      initialValue: filter.statusFilter,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.filter_list_rounded, color: AppColors.textHint),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text('Tất cả')),
        DropdownMenuItem(value: JobStatus.open, child: Text('🟢 Đang tuyển')),
        DropdownMenuItem(value: JobStatus.closed, child: Text('🔴 Đã đóng')),
      ],
      onChanged: (v) => ref.read(jobFilterProvider.notifier).updateStatus(v),
    );
  }
}

// ─── Filter Chip ──────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;

  const _FilterChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.primary, fontSize: 12),
      ),
    );
  }
}
