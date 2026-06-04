// lib/views/jobs/job_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/job_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_provider.dart';

class JobFormScreen extends ConsumerStatefulWidget {
  final String? jobId;
  const JobFormScreen({super.key, this.jobId});

  @override
  ConsumerState<JobFormScreen> createState() => _JobFormScreenState();
}

class _JobFormScreenState extends ConsumerState<JobFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _salaryMinCtrl = TextEditingController();
  final _salaryMaxCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _reqCtrl = TextEditingController();
  final _benCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();

  String _employmentType = 'Full-time';
  JobStatus _status = JobStatus.open;
  DateTime _deadline = DateTime.now().add(const Duration(days: 30));

  bool _initialized = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _companyCtrl.dispose();
    _locationCtrl.dispose();
    _salaryMinCtrl.dispose();
    _salaryMaxCtrl.dispose();
    _descCtrl.dispose();
    _reqCtrl.dispose();
    _benCtrl.dispose();
    _expCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _initFromJob(JobModel job) {
    if (_initialized) return;
    _initialized = true;
    _titleCtrl.text = job.title;
    _companyCtrl.text = job.company;
    _locationCtrl.text = job.location;
    _salaryMinCtrl.text = job.salaryMin.toString();
    _salaryMaxCtrl.text = job.salaryMax.toString();
    _descCtrl.text = job.description;
    _reqCtrl.text = job.requirement;
    _benCtrl.text = job.benefit;
    _expCtrl.text = job.experience;
    _qtyCtrl.text = job.quantity.toString();
    _employmentType = job.employmentType;
    _status = job.status;
    _deadline = job.deadline;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider)!;
    final job = JobModel(
      id: widget.jobId ?? 'job_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleCtrl.text.trim(),
      company: _companyCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      salaryMin: int.parse(_salaryMinCtrl.text),
      salaryMax: int.parse(_salaryMaxCtrl.text),
      status: _status,
      description: _descCtrl.text.trim(),
      requirement: _reqCtrl.text.trim(),
      benefit: _benCtrl.text.trim(),
      experience: _expCtrl.text.trim(),
      employmentType: _employmentType,
      quantity: int.parse(_qtyCtrl.text),
      deadline: _deadline,
      tags: [],
      recruiterId: user.id,
      postedAt: DateTime.now(),
    );

    await ref.read(jobOpsProvider.notifier).saveJob(job);
    if (mounted) context.go('/my-jobs');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.jobId != null) {
      final jobAsync = ref.watch(jobByIdProvider(widget.jobId!));
      jobAsync.whenData((job) {
        if (job != null) _initFromJob(job);
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.jobId == null ? 'Đăng tin tuyển dụng' : 'Chỉnh sửa tin',
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  _buildField(_titleCtrl, 'Tiêu đề công việc *'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _buildField(_companyCtrl, 'Tên công ty *')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildField(_locationCtrl, 'Địa điểm *')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _buildField(_salaryMinCtrl, 'Lương tối thiểu',
                              isNum: true)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildField(_salaryMaxCtrl, 'Lương tối đa',
                              isNum: true)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildField(_qtyCtrl, 'Số lượng tuyển',
                              isNum: true)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _employmentType,
                          decoration: const InputDecoration(
                              labelText: 'Hình thức làm việc'),
                          items: const [
                            DropdownMenuItem(
                                value: 'Full-time', child: Text('Full-time')),
                            DropdownMenuItem(
                                value: 'Part-time', child: Text('Part-time')),
                            DropdownMenuItem(
                                value: 'Intern', child: Text('Intern')),
                            DropdownMenuItem(
                                value: 'Remote', child: Text('Remote')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _employmentType = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<JobStatus>(
                          value: _status,
                          decoration:
                              const InputDecoration(labelText: 'Trạng thái'),
                          items: const [
                            DropdownMenuItem(
                                value: JobStatus.open, child: Text('Đang tuyển')),
                            DropdownMenuItem(
                                value: JobStatus.closed, child: Text('Đã đóng')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _status = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildField(_expCtrl, 'Kinh nghiệm yêu cầu'),
                  const SizedBox(height: 16),
                  _buildField(_descCtrl, 'Mô tả công việc *', maxLines: 5),
                  const SizedBox(height: 16),
                  _buildField(_reqCtrl, 'Yêu cầu ứng viên *', maxLines: 5),
                  const SizedBox(height: 16),
                  _buildField(_benCtrl, 'Quyền lợi *', maxLines: 5),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      child: const Text('Lưu tin'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label,
      {int maxLines = 1, bool isNum = false}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label, alignLabelWithHint: true),
      validator: (v) => (v == null || v.isEmpty) ? 'Bắt buộc' : null,
    );
  }
}
