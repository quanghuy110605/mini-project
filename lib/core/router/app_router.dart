// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/register_screen.dart';
import '../../views/auth/forgot_password_screen.dart';
import '../../views/dashboard/dashboard_screen.dart';
import '../../views/jobs/job_list_screen.dart';
import '../../views/jobs/job_detail_screen.dart';
import '../../views/jobs/recruiter_jobs_screen.dart';
import '../../views/jobs/job_form_screen.dart';
import '../../views/cv/cv_form_screen.dart';
import '../../views/applications/application_management_screen.dart';
import '../../views/shared/app_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(ref, authNotifier),
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.isAuthenticated;
      final loc = state.matchedLocation;
      final isAuthPage = loc == '/login' || loc == '/register' || loc == '/forgot-password';

      if (!isLoggedIn && !isAuthPage) return '/login';
      if (isLoggedIn && isAuthPage) {
        final role = authState.user?.role;
        switch (role) {
          case UserRole.candidate:
            return '/jobs';
          case UserRole.recruiter:
            return '/applications';
          case UserRole.admin:
            return '/dashboard';
          default:
            return '/dashboard';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      
      // ── Shell (persistent sidebar) ───────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) {
          final loc = state.matchedLocation;
          String activeRoute = loc;
          
          // Normalize sub-paths for sidebar highlighting
          if (loc.startsWith('/jobs/edit') || loc.startsWith('/jobs/new')) {
            activeRoute = '/my-jobs';
          } else if (loc.startsWith('/jobs/')) {
            activeRoute = '/jobs';
          }
          
          return AppScaffold(currentRoute: activeRoute, child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DashboardScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: '/jobs',
            name: 'jobs',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const JobListScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: '/jobs/new',
            name: 'new-job',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const JobFormScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: '/jobs/edit/:id',
            name: 'edit-job',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: JobFormScreen(jobId: state.pathParameters['id']),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: '/jobs/:id',
            name: 'job-detail',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: JobDetailScreen(jobId: state.pathParameters['id']!),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: '/my-jobs',
            name: 'my-jobs',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const RecruiterJobsScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: '/cv',
            name: 'cv',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const CvFormScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
            redirect: (context, state) {
              final user = ref.read(currentUserProvider);
              if (user?.role == UserRole.recruiter) return '/applications';
              if (user?.role == UserRole.admin) return '/dashboard';
              return null;
            },
          ),
          GoRoute(
            path: '/applications',
            name: 'applications',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ApplicationManagementScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
            redirect: (context, state) {
              final user = ref.read(currentUserProvider);
              if (user?.role == UserRole.candidate) return '/jobs';
              return null;
            },
          ),
          GoRoute(
            path: '/candidates',
            name: 'candidates',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ApplicationManagementScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Trang không tồn tại: ${state.uri}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Notifier để GoRouter re-evaluate redirect khi auth state thay đổi
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Ref ref, _) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}
