// lib/views/shared/app_scaffold.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';

class NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  final List<UserRole> allowedRoles;

  const NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
    required this.allowedRoles,
  });
}

final _navItems = [
  const NavItem(
    label: AppStrings.dashboard,
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard,
    route: '/dashboard',
    allowedRoles: [UserRole.candidate, UserRole.recruiter, UserRole.admin],
  ),
  const NavItem(
    label: AppStrings.jobList,
    icon: Icons.work_outline,
    activeIcon: Icons.work,
    route: '/jobs',
    allowedRoles: [UserRole.candidate, UserRole.recruiter, UserRole.admin],
  ),
  const NavItem(
    label: 'Việc làm của tôi',
    icon: Icons.business_center_outlined,
    activeIcon: Icons.business_center,
    route: '/my-jobs',
    allowedRoles: [UserRole.recruiter, UserRole.admin],
  ),
  const NavItem(
    label: AppStrings.myCV,
    icon: Icons.description_outlined,
    activeIcon: Icons.description,
    route: '/cv',
    allowedRoles: [UserRole.candidate],
  ),
  const NavItem(
    label: AppStrings.applications,
    icon: Icons.assignment_outlined,
    activeIcon: Icons.assignment,
    route: '/applications',
    allowedRoles: [UserRole.recruiter, UserRole.admin],
  ),
  const NavItem(
    label: AppStrings.candidates,
    icon: Icons.people_outline,
    activeIcon: Icons.people,
    route: '/candidates',
    allowedRoles: [UserRole.admin],
  ),
];

class AppScaffold extends ConsumerWidget {
  final Widget child;
  final String currentRoute;

  const AppScaffold({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final visibleItems =
        _navItems.where((item) => item.allowedRoles.contains(user.role)).toList();

    if (isDesktop) {
      return _DesktopScaffold(
        user: user,
        navItems: visibleItems,
        currentRoute: currentRoute,
        child: child,
      );
    } else {
      return _MobileScaffold(
        user: user,
        navItems: visibleItems,
        currentRoute: currentRoute,
        child: child,
      );
    }
  }
}

// ─── Desktop Layout ──────────────────────────────────────────────────────────
class _DesktopScaffold extends ConsumerWidget {
  final UserModel user;
  final List<NavItem> navItems;
  final String currentRoute;
  final Widget child;

  const _DesktopScaffold({
    required this.user,
    required this.navItems,
    required this.currentRoute,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Row(
        children: [
          // ── Sidebar ──────────────────────────────────────────────────────
          _Sidebar(
            user: user,
            navItems: navItems,
            currentRoute: currentRoute,
            onLogout: () => ref.read(authProvider.notifier).logout(),
          ),
          // ── Main content ─────────────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                _TopBar(user: user),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mobile Layout ───────────────────────────────────────────────────────────
class _MobileScaffold extends ConsumerWidget {
  final UserModel user;
  final List<NavItem> navItems;
  final String currentRoute;
  final Widget child;

  const _MobileScaffold({
    required this.user,
    required this.navItems,
    required this.currentRoute,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              user.name.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      drawer: _DrawerMenu(
        user: user,
        navItems: navItems,
        currentRoute: currentRoute,
        onLogout: () => ref.read(authProvider.notifier).logout(),
      ),
      body: child,
    );
  }
}

// ─── Sidebar Widget ──────────────────────────────────────────────────────────
class _Sidebar extends StatelessWidget {
  final UserModel user;
  final List<NavItem> navItems;
  final String currentRoute;
  final VoidCallback onLogout;

  const _Sidebar({
    required this.user,
    required this.navItems,
    required this.currentRoute,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppColors.divider)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Brand header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: AppColors.heroGradient,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.work_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.appName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Pro',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // User info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.backgroundLight,
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user.roleDisplayName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Nav items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: navItems.map((item) {
                  final isActive = currentRoute.startsWith(item.route);
                  return _NavItemTile(
                    item: item,
                    isActive: isActive,
                  );
                }).toList(),
              ),
            ),
          ),

          // Logout
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
            title: const Text(
              AppStrings.logout,
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w500),
            ),
            onTap: onLogout,
            shape: const RoundedRectangleBorder(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _NavItemTile extends StatelessWidget {
  final NavItem item;
  final bool isActive;

  const _NavItemTile({required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: InkWell(
        onTap: () => context.go(item.route),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                isActive ? item.activeIcon : item.icon,
                color:
                    isActive ? AppColors.primary : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                item.label,
                style: TextStyle(
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              if (isActive) ...[
                const Spacer(),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Drawer Menu ─────────────────────────────────────────────────────────────
class _DrawerMenu extends StatelessWidget {
  final UserModel user;
  final List<NavItem> navItems;
  final String currentRoute;
  final VoidCallback onLogout;

  const _DrawerMenu({
    required this.user,
    required this.navItems,
    required this.currentRoute,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: _Sidebar(
        user: user,
        navItems: navItems,
        currentRoute: currentRoute,
        onLogout: () {
          Navigator.pop(context);
          onLogout();
        },
      ),
    );
  }
}

// ─── Top Bar ─────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final UserModel user;

  const _TopBar({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Text(
            _getGreeting(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          // Notification bell
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.textSecondary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary,
            child: Text(
              user.name.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng! ☀️';
    if (hour < 17) return 'Chào buổi chiều! 🌤';
    return 'Chào buổi tối! 🌙';
  }
}
