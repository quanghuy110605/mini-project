// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF0277BD);
  static const Color primaryLight = Color(0xFF58A5F0);
  static const Color primaryDark = Color(0xFF004C8C);

  static const Color secondary = Color(0xFF00838F);
  static const Color secondaryLight = Color(0xFF4FB3BF);
  static const Color secondaryDark = Color(0xFF005662);

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57F17);
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF0277BD);

  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE8EDF2);

  static const Color textPrimary = Color(0xFF1A2332);
  static const Color textSecondary = Color(0xFF5A6A7A);
  static const Color textHint = Color(0xFF9EAAB8);

  static const Color divider = Color(0xFFE0E6EF);

  // Status colors
  static const Color statusOpen = Color(0xFF1B8C3E);
  static const Color statusOpenBg = Color(0xFFE8F5E9);
  static const Color statusClosed = Color(0xFFB71C1C);
  static const Color statusClosedBg = Color(0xFFFFEBEE);
  static const Color statusPending = Color(0xFFF57F17);
  static const Color statusPendingBg = Color(0xFFFFF8E1);
  static const Color statusAccepted = Color(0xFF1B8C3E);
  static const Color statusAcceptedBg = Color(0xFFE8F5E9);
  static const Color statusRejected = Color(0xFFB71C1C);
  static const Color statusRejectedBg = Color(0xFFFFEBEE);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0277BD), Color(0xFF0288D1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF01579B), Color(0xFF0277BD), Color(0xFF0288D1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
