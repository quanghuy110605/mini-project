// lib/views/jobs/job_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/job_model.dart';
import '../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_provider.dart';
import 'widgets/apply_job_dialog.dart';

class JobDetailScreen extends ConsumerWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(jobByIdProvider(jobId));
    final user = ref.watch(currentUserProvider);

    return jobAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Lỗi: $e')),
      data: (job) {
        if (job == null) {
          return const Center(child: Text('Không tìm thấy công việc'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.business_rounded,
                          color: AppColors.primary, size: 40),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(job.title,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                          Text(job.company,
                              style: const TextStyle(
                                  fontSize: 18, color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 16, color: AppColors.textHint),
                              const SizedBox(width: 4),
                              Text(job.location,
                                  style: const TextStyle(color: AppColors.textHint)),
                              const SizedBox(width: 16),
                              const Icon(Icons.access_time_rounded,
                                  size: 16, color: AppColors.textHint),
                              const SizedBox(width: 4),
                              Text(job.employmentType,
                                  style: const TextStyle(color: AppColors.textHint)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (user?.role == UserRole.candidate)
                      ElevatedButton(
                        onPressed: () => _showApplyDialog(context, job),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Ứng tuyển ngay'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Content
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Details
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection('Mô tả công việc', job.description),
                        const SizedBox(height: 24),
                        _buildSection('Yêu cầu ứng viên', job.requirement),
                        const SizedBox(height: 24),
                        _buildSection('Quyền lợi', job.benefit),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Right Column: Summary info
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Thông tin chung',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          _buildInfoRow(Icons.monetization_on_outlined, 'Mức lương',
                              job.salaryDisplay),
                          _buildInfoRow(Icons.group_outlined, 'Số lượng tuyển',
                              '${job.quantity} người'),
                          _buildInfoRow(
                              Icons.history_outlined, 'Kinh nghiệm', job.experience),
                          _buildInfoRow(
                              Icons.calendar_month_outlined,
                              'Hạn nộp hồ sơ',
                              '${job.deadline.day}/${job.deadline.month}/${job.deadline.year}'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(content,
            style: const TextStyle(
                fontSize: 15, height: 1.6, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
              Text(value,
                  style:
                      const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  void _showApplyDialog(BuildContext context, JobModel job) {
    showDialog(
      context: context,
      builder: (ctx) => ApplyJobDialog(job: job),
    );
  }
}
