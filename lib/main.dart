// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recruitment_app/core/theme/app_theme.dart';
import 'package:recruitment_app/core/router/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: RecruitmentApp(),
    ),
  );
}

class RecruitmentApp extends ConsumerWidget {
  const RecruitmentApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'RecruitPro - Hệ thống Tuyển dụng',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
