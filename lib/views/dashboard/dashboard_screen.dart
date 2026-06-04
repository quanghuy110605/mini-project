// lib/views/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/application_model.dart';
import '../../data/models/job_model.dart';
import '../../data/models/user_model.dart';
import '../../providers/application_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_provider.dart';
import '../shared/app_scaffold.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _DashboardContent();
  }
}

class _DashboardContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final jobsAsync = ref.watch(jobListProvider);
    final appsAsync = ref.watch(applicationListProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome banner
          _WelcomeBanner(user: user),
          const SizedBox(height: 24),

          // Stat cards
          jobsAsync.when(
            data: (jobs) => appsAsync.when(
              data: (apps) => _StatCards(jobs: jobs, apps: apps, user: user),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 24),

          // Recent jobs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Việc làm nổi bật',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              TextButton(
                onPressed: () => context.go('/jobs'),
                child: const Text('Xem tất cả →'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          jobsAsync.when(
            data: (jobs) => _RecentJobs(jobs: jobs.take(4).toList()),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  final UserModel? user;
  const _WelcomeBanner({this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào, ${user?.name ?? "Bạn"} 👋',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                user?.roleDisplayName ?? '',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '🚀 Hệ thống tuyển dụng chuyên nghiệp',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCards extends StatelessWidget {
  final List<JobModel> jobs;
  final List<ApplicationModel> apps;
  final UserModel? user;

  const _StatCards({required this.jobs, required this.apps, this.user});

  @override
  Widget build(BuildContext context) {
    final openJobs = jobs.where((j) => j.isOpen).length;
    final pendingApps =
        apps.where((a) => a.status == ApplicationStatus.pending).length;
    final acceptedApps =
        apps.where((a) => a.status == ApplicationStatus.accepted).length;

    final stats = user?.role == UserRole.candidate
        ? [
            _StatData('Việc làm mở', '$openJobs', Icons.work_rounded,
                AppColors.primary, AppColors.primary.withValues(alpha: 0.1)),
            _StatData('Đã ứng tuyển', '${apps.where((a) => a.candidateId == user?.id).length}',
                Icons.send_rounded, AppColors.secondary,
                AppColors.secondary.withValues(alpha: 0.1)),
            _StatData('Được chấp nhận', '$acceptedApps', Icons.check_circle_rounded,
                AppColors.success, AppColors.statusAcceptedBg),
          ]
        : [
            _StatData('Tổng việc làm', '${jobs.length}', Icons.work_rounded,
                AppColors.primary, AppColors.primary.withValues(alpha: 0.1)),
            _StatData('Đang tuyển', '$openJobs', Icons.circle_rounded,
                AppColors.statusOpen, AppColors.statusOpenBg),
            _StatData('Đơn chờ duyệt', '$pendingApps', Icons.hourglass_empty_rounded,
                AppColors.statusPending, AppColors.statusPendingBg),
            _StatData('Đã chấp nhận', '$acceptedApps', Icons.check_circle_rounded,
                AppColors.success, AppColors.statusAcceptedBg),
          ];

    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width >= 900 ? stats.length : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: stats.map((s) => _StatCard(data: s)).toList(),
    );
  }
}

class _StatData {
  final String label, value;
  final IconData icon;
  final Color color, bg;
  const _StatData(this.label, this.value, this.icon, this.color, this.bg);
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: data.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.value,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: data.color)),
              Text(data.label,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentJobs extends StatelessWidget {
  final List<JobModel> jobs;
  const _RecentJobs({required this.jobs});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: jobs.map((job) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    job.company.substring(0, 1),
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    Text('${job.company} • ${job.location}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(job.salaryDisplay,
                      style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: job.isOpen
                          ? AppColors.statusOpenBg
                          : AppColors.statusClosedBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      job.isOpen ? 'Đang tuyển' : 'Đã đóng',
                      style: TextStyle(
                          fontSize: 11,
                          color: job.isOpen
                              ? AppColors.statusOpen
                              : AppColors.statusClosed,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
