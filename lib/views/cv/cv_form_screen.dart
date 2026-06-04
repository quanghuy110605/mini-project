// lib/views/cv/cv_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/cv_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cv_provider.dart';
import '../shared/app_scaffold.dart';

class CvFormScreen extends ConsumerStatefulWidget {
  const CvFormScreen({super.key});

  @override
  ConsumerState<CvFormScreen> createState() => _CvFormScreenState();
}

class _CvFormScreenState extends ConsumerState<CvFormScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _infoKey = GlobalKey<FormState>();

  // Info controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _birthdayCtrl = TextEditingController();
  final _genderCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();
  final _objectiveCtrl = TextEditingController();
  final _positionCtrl = TextEditingController();

  // Dynamic lists
  final List<EducationEntry> _educations = [];
  final List<ExperienceEntry> _experiences = [];
  final List<SkillEntry> _skills = [];
  final List<ProjectEntry> _projects = [];
  final List<CertificateEntry> _certificates = [];

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _summaryCtrl.dispose();
    super.dispose();
  }

  void _initFromCv(CvModel cv) {
    if (_initialized) return;
    _initialized = true;
    _nameCtrl.text = cv.fullName;
    _emailCtrl.text = cv.email;
    _phoneCtrl.text = cv.phone;
    _addressCtrl.text = cv.address ?? '';
    _birthdayCtrl.text = cv.birthday ?? '';
    _genderCtrl.text = cv.gender ?? '';
    _summaryCtrl.text = cv.summary ?? '';
    _objectiveCtrl.text = cv.careerObjective ?? '';
    _positionCtrl.text = cv.position ?? '';
    _educations.addAll(cv.education);
    _experiences.addAll(cv.experience);
    _skills.addAll(cv.skills);
    _projects.addAll(cv.projects);
    _certificates.addAll(cv.certificates);
  }

  void _saveCV() {
    if (!_infoKey.currentState!.validate()) {
      _tabController.animateTo(0);
      return;
    }
    final user = ref.read(currentUserProvider)!;
    final cv = CvModel(
      id: 'cv_${user.id}',
      userId: user.id,
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      birthday: _birthdayCtrl.text.trim(),
      gender: _genderCtrl.text.trim(),
      summary: _summaryCtrl.text.trim(),
      careerObjective: _objectiveCtrl.text.trim(),
      position: _positionCtrl.text.trim(),
      education: List.from(_educations),
      experience: List.from(_experiences),
      skills: List.from(_skills),
      projects: List.from(_projects),
      certificates: List.from(_certificates),
      updatedAt: DateTime.now(),
    );
    ref.read(cvProvider.notifier).saveCV(cv);
  }

  @override
  Widget build(BuildContext context) {
    final cvState = ref.watch(cvProvider);

    if (cvState.cv != null) _initFromCv(cvState.cv!);

    ref.listen(cvProvider, (_, next) {
      if (next.saveSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ CV đã được lưu thành công!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        ref.read(cvProvider.notifier).clearSaveSuccess();
      }
    });

    return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hồ sơ CV của tôi',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    Text('Quản lý thông tin hồ sơ cá nhân',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 14)),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: cvState.isSaving ? null : _saveCV,
                  icon: cvState.isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.save_rounded, size: 18),
                  label: Text(cvState.isSaving ? 'Đang lưu...' : 'Lưu CV'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tabs
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorSize: TabBarIndicatorSize.label,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                tabs: const [
                  Tab(icon: Icon(Icons.person_outline, size: 18), text: 'Thông tin'),
                  Tab(icon: Icon(Icons.school_outlined, size: 18), text: 'Học vấn'),
                  Tab(icon: Icon(Icons.work_outline, size: 18), text: 'Kinh nghiệm'),
                  Tab(icon: Icon(Icons.code_rounded, size: 18), text: 'Kỹ năng'),
                  Tab(icon: Icon(Icons.assignment_outlined, size: 18), text: 'Dự án'),
                  Tab(icon: Icon(Icons.verified_outlined, size: 18), text: 'Chứng chỉ'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _InfoTab(
                    formKey: _infoKey,
                    nameCtrl: _nameCtrl,
                    emailCtrl: _emailCtrl,
                    phoneCtrl: _phoneCtrl,
                    addressCtrl: _addressCtrl,
                    birthdayCtrl: _birthdayCtrl,
                    genderCtrl: _genderCtrl,
                    summaryCtrl: _summaryCtrl,
                    objectiveCtrl: _objectiveCtrl,
                    positionCtrl: _positionCtrl,
                  ),
                  _EducationTab(
                    items: _educations,
                    onAdd: (e) => setState(() => _educations.add(e)),
                    onRemove: (i) => setState(() => _educations.removeAt(i)),
                  ),
                  _ExperienceTab(
                    items: _experiences,
                    onAdd: (e) => setState(() => _experiences.add(e)),
                    onRemove: (i) => setState(() => _experiences.removeAt(i)),
                  ),
                  _SkillTab(
                    items: _skills,
                    onAdd: (s) => setState(() => _skills.add(s)),
                    onRemove: (i) => setState(() => _skills.removeAt(i)),
                  ),
                  _ProjectTab(
                    items: _projects,
                    onAdd: (p) => setState(() => _projects.add(p)),
                    onRemove: (i) => setState(() => _projects.removeAt(i)),
                  ),
                  _CertificateTab(
                    items: _certificates,
                    onAdd: (c) => setState(() => _certificates.add(c)),
                    onRemove: (i) => setState(() => _certificates.removeAt(i)),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}

// ─── Info Tab ────────────────────────────────────────────────────────────────
class _InfoTab extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl, emailCtrl, phoneCtrl, addressCtrl, birthdayCtrl, genderCtrl, summaryCtrl, objectiveCtrl, positionCtrl;

  const _InfoTab({
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.addressCtrl,
    required this.birthdayCtrl,
    required this.genderCtrl,
    required this.summaryCtrl,
    required this.objectiveCtrl,
    required this.positionCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return _CardWrap(
      child: Form(
        key: formKey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildField(nameCtrl, 'Họ và tên *', Icons.person_outline,
                    validator: (v) => (v == null || v.isEmpty) ? 'Bắt buộc' : null)),
                const SizedBox(width: 16),
                Expanded(child: _buildField(positionCtrl, 'Vị trí ứng tuyển *', Icons.work_outline,
                    validator: (v) => (v == null || v.isEmpty) ? 'Bắt buộc' : null)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildField(emailCtrl, 'Email *', Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                    if (v == null || v.isEmpty) return 'Bắt buộc';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  }),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildField(phoneCtrl, 'Số điện thoại *', Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                    if (v == null || v.isEmpty) return 'Bắt buộc';
                    return null;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildField(birthdayCtrl, 'Ngày sinh', Icons.calendar_today_outlined)),
                const SizedBox(width: 16),
                Expanded(child: _buildField(genderCtrl, 'Giới tính', Icons.wc_outlined)),
              ],
            ),
            const SizedBox(height: 16),
            _buildField(addressCtrl, 'Địa chỉ', Icons.location_on_outlined),
            const SizedBox(height: 16),
            TextFormField(
              controller: objectiveCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Mục tiêu nghề nghiệp',
                prefixIcon: Icon(Icons.track_changes_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: summaryCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Giới thiệu bản thân',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 56),
                  child: Icon(Icons.notes_rounded),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }
}

// ─── Education Tab ────────────────────────────────────────────────────────────
class _EducationTab extends StatelessWidget {
  final List<EducationEntry> items;
  final void Function(EducationEntry) onAdd;
  final void Function(int) onRemove;

  const _EducationTab({required this.items, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return _CardWrap(
      child: Column(
        children: [
          ...items.asMap().entries.map((e) => _EducationCard(
                entry: e.value,
                index: e.key,
                onRemove: () => onRemove(e.key),
              )),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _showAddDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Thêm học vấn'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final schoolCtrl = TextEditingController();
    final degreeCtrl = TextEditingController();
    final majorCtrl = TextEditingController();
    final startCtrl = TextEditingController();
    final endCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thêm học vấn'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DialogField(ctrl: schoolCtrl, label: 'Trường học *', req: true),
                const SizedBox(height: 12),
                _DialogField(ctrl: degreeCtrl, label: 'Bằng cấp *', req: true),
                const SizedBox(height: 12),
                _DialogField(ctrl: majorCtrl, label: 'Chuyên ngành *', req: true),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _DialogField(ctrl: startCtrl, label: 'Năm bắt đầu', req: false)),
                    const SizedBox(width: 12),
                    Expanded(child: _DialogField(ctrl: endCtrl, label: 'Năm kết thúc', req: false)),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              onAdd(EducationEntry(
                id: 'edu_${DateTime.now().millisecondsSinceEpoch}',
                school: schoolCtrl.text,
                degree: degreeCtrl.text,
                major: majorCtrl.text,
                startYear: startCtrl.text,
                endYear: endCtrl.text,
              ));
              Navigator.pop(context);
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }
}

class _EducationCard extends StatelessWidget {
  final EducationEntry entry;
  final int index;
  final VoidCallback onRemove;

  const _EducationCard({required this.entry, required this.index, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.school, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('${entry.degree} - ${entry.major}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                Text('${entry.startYear} - ${entry.endYear}',
                    style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

// ─── Experience Tab ───────────────────────────────────────────────────────────
class _ExperienceTab extends StatelessWidget {
  final List<ExperienceEntry> items;
  final void Function(ExperienceEntry) onAdd;
  final void Function(int) onRemove;

  const _ExperienceTab({required this.items, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return _CardWrap(
      child: Column(
        children: [
          ...items.asMap().entries.map((e) => _ExperienceCard(
                entry: e.value,
                onRemove: () => onRemove(e.key),
              )),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _showAddDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Thêm kinh nghiệm'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final companyCtrl = TextEditingController();
    final posCtrl = TextEditingController();
    final startCtrl = TextEditingController();
    final endCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thêm kinh nghiệm'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DialogField(ctrl: companyCtrl, label: 'Công ty *', req: true),
                const SizedBox(height: 12),
                _DialogField(ctrl: posCtrl, label: 'Vị trí *', req: true),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _DialogField(ctrl: startCtrl, label: 'Từ tháng/năm', req: false)),
                    const SizedBox(width: 12),
                    Expanded(child: _DialogField(ctrl: endCtrl, label: 'Đến tháng/năm', req: false)),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Mô tả công việc'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              onAdd(ExperienceEntry(
                id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
                company: companyCtrl.text,
                position: posCtrl.text,
                startDate: startCtrl.text,
                endDate: endCtrl.text,
                description: descCtrl.text,
              ));
              Navigator.pop(context);
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  final ExperienceEntry entry;
  final VoidCallback onRemove;

  const _ExperienceCard({required this.entry, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.work_rounded, color: AppColors.secondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.position, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(entry.company, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                Text('${entry.startDate} - ${entry.isCurrent ? "Hiện tại" : entry.endDate}',
                    style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                if (entry.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(entry.description,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

// ─── Skill Tab ────────────────────────────────────────────────────────────────
class _SkillTab extends StatelessWidget {
  final List<SkillEntry> items;
  final void Function(SkillEntry) onAdd;
  final void Function(int) onRemove;

  const _SkillTab({required this.items, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return _CardWrap(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: items.asMap().entries.map((e) {
              final skill = e.value;
              return Chip(
                label: Text('${skill.name}  •  ${skill.level.displayName}'),
                backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                labelStyle: const TextStyle(color: AppColors.primary, fontSize: 13),
                deleteIcon: const Icon(Icons.close, size: 16, color: AppColors.primary),
                onDeleted: () => onRemove(e.key),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => _showAddDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Thêm kỹ năng'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    SkillLevel level = SkillLevel.intermediate;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Thêm kỹ năng'),
          content: SizedBox(
            width: 340,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DialogField(ctrl: nameCtrl, label: 'Tên kỹ năng *', req: true),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<SkillLevel>(
                    initialValue: level,
                    decoration: const InputDecoration(labelText: 'Mức độ'),
                    items: SkillLevel.values
                        .map((l) => DropdownMenuItem(value: l, child: Text(l.displayName)))
                        .toList(),
                    onChanged: (v) => setS(() => level = v ?? level),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                onAdd(SkillEntry(
                  id: 'skill_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text,
                  level: level,
                ));
                Navigator.pop(context);
              },
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Project Tab ─────────────────────────────────────────────────────────────
class _ProjectTab extends StatelessWidget {
  final List<ProjectEntry> items;
  final void Function(ProjectEntry) onAdd;
  final void Function(int) onRemove;

  const _ProjectTab({required this.items, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return _CardWrap(
      child: Column(
        children: [
          ...items.asMap().entries.map((e) => _ProjectCard(
                entry: e.value,
                onRemove: () => onRemove(e.key),
              )),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _showAddDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Thêm dự án'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thêm dự án'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DialogField(ctrl: nameCtrl, label: 'Tên dự án *', req: true),
                const SizedBox(height: 12),
                _DialogField(ctrl: roleCtrl, label: 'Vai trò *', req: true),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Mô tả dự án'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              onAdd(ProjectEntry(
                id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
                name: nameCtrl.text,
                role: roleCtrl.text,
                description: descCtrl.text,
              ));
              Navigator.pop(context);
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectEntry entry;
  final VoidCallback onRemove;

  const _ProjectCard({required this.entry, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.assignment_rounded, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(entry.role, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                if (entry.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(entry.description,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

// ─── Certificate Tab ─────────────────────────────────────────────────────────
class _CertificateTab extends StatelessWidget {
  final List<CertificateEntry> items;
  final void Function(CertificateEntry) onAdd;
  final void Function(int) onRemove;

  const _CertificateTab({required this.items, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return _CardWrap(
      child: Column(
        children: [
          ...items.asMap().entries.map((e) => _CertificateCard(
                entry: e.value,
                onRemove: () => onRemove(e.key),
              )),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _showAddDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Thêm chứng chỉ'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final issuedByCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thêm chứng chỉ'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DialogField(ctrl: nameCtrl, label: 'Tên chứng chỉ *', req: true),
                const SizedBox(height: 12),
                _DialogField(ctrl: issuedByCtrl, label: 'Đơn vị cấp *', req: true),
                const SizedBox(height: 12),
                _DialogField(ctrl: dateCtrl, label: 'Ngày cấp (MM/YYYY)', req: false),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              onAdd(CertificateEntry(
                id: 'cert_${DateTime.now().millisecondsSinceEpoch}',
                name: nameCtrl.text,
                issuedBy: issuedByCtrl.text,
                issuedDate: dateCtrl.text,
              ));
              Navigator.pop(context);
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  final CertificateEntry entry;
  final VoidCallback onRemove;

  const _CertificateCard({required this.entry, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.verified_rounded, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(entry.issuedBy, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                Text(entry.issuedDate, style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────
class _CardWrap extends StatelessWidget {
  final Widget child;
  const _CardWrap({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool req;

  const _DialogField({required this.ctrl, required this.label, required this.req});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(labelText: label),
      validator: req ? (v) => (v == null || v.isEmpty) ? 'Bắt buộc' : null : null,
    );
  }
}
