// lib/views/applications/application_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/application_model.dart';
import '../../data/models/job_model.dart';
import '../../data/models/user_model.dart';
import '../../providers/application_provider.dart';
import '../shared/app_scaffold.dart';

class ApplicationManagementScreen extends ConsumerWidget {
  const ApplicationManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ApplicationContent();
  }
}

class _ApplicationContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(recruiterApplicationsProvider);

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
                  Text('Quản lý Ứng tuyển',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  Text('Xem xét và cập nhật trạng thái hồ sơ ứng viên',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14)),
                ],
              ),
              const Spacer(),
              // Stats
              appsAsync.when(
                data: (apps) => Row(
                  children: [
                    _StatBadge(
                      label: 'Chờ duyệt',
                      count: apps
                          .where((a) => a.status == ApplicationStatus.pending)
                          .length,
                      color: AppColors.statusPending,
                      bg: AppColors.statusPendingBg,
                    ),
                    const SizedBox(width: 8),
                    _StatBadge(
                      label: 'Đã nhận',
                      count: apps
                          .where((a) => a.status == ApplicationStatus.accepted)
                          .length,
                      color: AppColors.statusAccepted,
                      bg: AppColors.statusAcceptedBg,
                    ),
                  ],
                ),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Table
          Expanded(
            child: appsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                  child: Text('Lỗi: $e',
                      style: const TextStyle(color: AppColors.error))),
              data: (apps) => _ApplicationTable(apps: apps),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationTable extends ConsumerStatefulWidget {
  final List<ApplicationModel> apps;
  const _ApplicationTable({required this.apps});

  @override
  ConsumerState<_ApplicationTable> createState() => _ApplicationTableState();
}

class _ApplicationTableState extends ConsumerState<_ApplicationTable> {
  String _statusFilter = 'all';
  final Map<String, bool> _loadingMap = {};

  List<ApplicationModel> get _filtered {
    if (_statusFilter == 'all') return widget.apps;
    return widget.apps.where((a) => a.status.name == _statusFilter).toList();
  }

  Future<void> _updateStatus(String appId, ApplicationStatus status) async {
    setState(() => _loadingMap[appId] = true);
    await ref.read(applicationListProvider.notifier).updateStatus(appId, status);
    if (mounted) setState(() => _loadingMap.remove(appId));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status == ApplicationStatus.accepted
              ? '✅ Đã chấp nhận ứng viên!'
              : '❌ Đã từ chối ứng viên'),
          backgroundColor: status == ApplicationStatus.accepted
              ? AppColors.success
              : AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // Filter tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                _FilterTab(
                    label: 'Tất cả (${widget.apps.length})',
                    isActive: _statusFilter == 'all',
                    onTap: () => setState(() => _statusFilter = 'all')),
                const SizedBox(width: 8),
                _FilterTab(
                    label:
                        'Chờ duyệt (${widget.apps.where((a) => a.status == ApplicationStatus.pending).length})',
                    isActive: _statusFilter == 'pending',
                    onTap: () => setState(() => _statusFilter = 'pending')),
                const SizedBox(width: 8),
                _FilterTab(
                    label:
                        'Đã nhận (${widget.apps.where((a) => a.status == ApplicationStatus.accepted).length})',
                    isActive: _statusFilter == 'accepted',
                    onTap: () => setState(() => _statusFilter = 'accepted')),
                const SizedBox(width: 8),
                _FilterTab(
                    label:
                        'Từ chối (${widget.apps.where((a) => a.status == ApplicationStatus.rejected).length})',
                    isActive: _statusFilter == 'rejected',
                    onTap: () => setState(() => _statusFilter = 'rejected')),
              ],
            ),
          ),

          // Table content
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Text('Không có hồ sơ nào',
                        style: TextStyle(color: AppColors.textSecondary)))
                : isDesktop
                    ? _DesktopTable(
                        apps: _filtered,
                        onUpdate: _updateStatus,
                        loadingMap: _loadingMap,
                      )
                    : _MobileList(
                        apps: _filtered,
                        onUpdate: _updateStatus,
                        loadingMap: _loadingMap,
                      ),
          ),
        ],
      ),
    );
  }
}

// ─── Desktop DataTable ────────────────────────────────────────────────────────
class _DesktopTable extends StatelessWidget {
  final List<ApplicationModel> apps;
  final Future<void> Function(String, ApplicationStatus) onUpdate;
  final Map<String, bool> loadingMap;

  const _DesktopTable({
    required this.apps,
    required this.onUpdate,
    required this.loadingMap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.backgroundLight),
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
          columnSpacing: 24,
          columns: const [
            DataColumn(label: Text('Ứng viên')),
            DataColumn(label: Text('Vị trí ứng tuyển')),
            DataColumn(label: Text('CV ID')),
            DataColumn(label: Text('Ngày nộp')),
            DataColumn(label: Text('Trạng thái')),
            DataColumn(label: Text('Hành động')),
          ],
          rows: apps.map((app) {
            final isLoading = loadingMap[app.id] == true;

            return DataRow(
              cells: [
                // Candidate
                DataCell(Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        (app.candidateName).isNotEmpty ? app.candidateName.substring(0, 1) : '?',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(app.candidateName.isNotEmpty ? app.candidateName : 'Không rõ',
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 13)),
                        Text(app.candidateEmail,
                            style: const TextStyle(
                                color: AppColors.textHint, fontSize: 11)),
                      ],
                    ),
                  ],
                )),
                // Job
                DataCell(Text(app.jobTitle.isNotEmpty ? app.jobTitle : 'Không rõ',
                    style: const TextStyle(fontSize: 13))),
                // CV ID
                DataCell(Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(app.cvId,
                      style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: AppColors.textSecondary)),
                )),
                // Date
                DataCell(Text(
                  DateFormat('dd/MM/yyyy').format(app.appliedAt),
                  style: const TextStyle(fontSize: 13),
                )),
                // Status
                DataCell(_StatusChip(status: app.status)),
                // Actions
                DataCell(
                  isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : app.status == ApplicationStatus.pending
                          ? Row(
                              children: [
                                _ActionBtn(
                                  label: 'Nhận',
                                  icon: Icons.check_rounded,
                                  color: AppColors.success,
                                  onTap: () => onUpdate(
                                      app.id, ApplicationStatus.accepted),
                                ),
                                const SizedBox(width: 6),
                                _ActionBtn(
                                  label: 'Từ chối',
                                  icon: Icons.close_rounded,
                                  color: AppColors.error,
                                  onTap: () => onUpdate(
                                      app.id, ApplicationStatus.rejected),
                                ),
                              ],
                            )
                          : Text(
                              app.status == ApplicationStatus.accepted
                                  ? '✓ Đã xử lý'
                                  : '✗ Đã xử lý',
                              style: TextStyle(
                                color: app.status == ApplicationStatus.accepted
                                    ? AppColors.success
                                    : AppColors.error,
                                fontSize: 12,
                              ),
                            ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Mobile Card List ─────────────────────────────────────────────────────────
class _MobileList extends StatelessWidget {
  final List<ApplicationModel> apps;
  final Future<void> Function(String, ApplicationStatus) onUpdate;
  final Map<String, bool> loadingMap;

  const _MobileList({
    required this.apps,
    required this.onUpdate,
    required this.loadingMap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: apps.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final app = apps[i];
        final isLoading = loadingMap[app.id] == true;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 18,
                    child: Text(app.candidateName.isNotEmpty ? app.candidateName.substring(0, 1) : '?',
                        style: const TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(app.candidateName.isNotEmpty ? app.candidateName : 'Không rõ',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(app.jobTitle.isNotEmpty ? app.jobTitle : 'Không rõ',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  _StatusChip(status: app.status),
                ],
              ),
              const SizedBox(height: 12),
              if (app.status == ApplicationStatus.pending)
                isLoading
                    ? const Center(
                        child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2)))
                    : Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  onUpdate(app.id, ApplicationStatus.accepted),
                              icon: const Icon(Icons.check_rounded, size: 16),
                              label: const Text('Chấp nhận'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  padding: const EdgeInsets.symmetric(vertical: 10)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  onUpdate(app.id, ApplicationStatus.rejected),
                              icon: const Icon(Icons.close_rounded, size: 16),
                              label: const Text('Từ chối'),
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: const BorderSide(color: AppColors.error),
                                  padding: const EdgeInsets.symmetric(vertical: 10)),
                            ),
                          ),
                        ],
                      ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Reusable widgets ─────────────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final ApplicationStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color, bg;
    String label;
    switch (status) {
      case ApplicationStatus.pending:
        color = AppColors.statusPending;
        bg = AppColors.statusPendingBg;
        label = '● Chờ duyệt';
      case ApplicationStatus.reviewed:
        color = AppColors.primary;
        bg = AppColors.primary.withValues(alpha: 0.1);
        label = '● Đang xem xét';
      case ApplicationStatus.accepted:
        color = AppColors.statusAccepted;
        bg = AppColors.statusAcceptedBg;
        label = '● Đã nhận';
      case ApplicationStatus.rejected:
        color = AppColors.statusRejected;
        bg = AppColors.statusRejectedBg;
        label = '● Từ chối';
      case ApplicationStatus.cancelled:
        color = AppColors.textHint;
        bg = AppColors.backgroundLight;
        label = '● Đã hủy';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color, bg;

  const _StatBadge(
      {required this.label,
      required this.count,
      required this.color,
      required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Text('$count',
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 20, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterTab(
      {required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isActive
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
