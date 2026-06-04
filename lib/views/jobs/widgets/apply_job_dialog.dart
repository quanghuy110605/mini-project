// lib/views/jobs/widgets/apply_job_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/job_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/cv_provider.dart';
import '../../../providers/application_provider.dart';

class ApplyJobDialog extends ConsumerStatefulWidget {
  final JobModel job;
  const ApplyJobDialog({super.key, required this.job});

  @override
  ConsumerState<ApplyJobDialog> createState() => _ApplyJobDialogState();
}

class _ApplyJobDialogState extends ConsumerState<ApplyJobDialog> {
  final _coverLetterCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _coverLetterCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleApply() async {
    if (!_formKey.currentState!.validate()) return;
    
    final user = ref.read(currentUserProvider)!;
    final cvState = ref.read(cvProvider);
    
    if (cvState.cv == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng tạo CV trước khi ứng tuyển')),
      );
      return;
    }

    await ref.read(applicationListProvider.notifier).apply(
      jobId: widget.job.id,
      candidateId: user.id,
      cvId: cvState.cv!.id,
      jobTitle: widget.job.title,
      companyName: widget.job.company,
      coverLetter: _coverLetterCtrl.text.trim(),
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Ứng tuyển thành công!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cvState = ref.watch(cvProvider);

    return AlertDialog(
      title: Text('Ứng tuyển: ${widget.job.title}'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hồ sơ sử dụng:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description_outlined, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        cvState.cv?.fullName ?? 'Chưa có CV',
                        style: TextStyle(
                          color: cvState.cv == null ? Colors.red : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Thư giới thiệu:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _coverLetterCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Giới thiệu ngắn gọn về bản thân và lý do bạn phù hợp với công việc này...',
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập thư giới thiệu' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        ElevatedButton(
          onPressed: _handleApply,
          child: const Text('Gửi ứng tuyển'),
        ),
      ],
    );
  }
}
