import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary & Accent
  static const Color primary = Color(0xFF1E3A8A); // Deep Royal Navy Blue
  static const Color primaryDark = Color(0xFF0F172A); // Midnight Slate
  static const Color primaryLight = Color(0xFF3B82F6); // Vibrant Blue
  static const Color secondary = Color(0xFFD97706); // Warm Amber / Gold
  static const Color secondaryLight = Color(0xFFFEF3C7); // Soft Amber Tint

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF8FAFC); // Crisp Light Gray
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);

  // High contrast text for elderly & first-time users
  static const Color textPrimary = Color(0xFF0F172A); // Almost pure black
  static const Color textSecondary = Color(0xFF475569); // High contrast dark slate
  static const Color textMuted = Color(0xFF64748B);

  // Strict EMI Status Colors (Requirements: Paid=Green, Due Soon=Orange, Due Today=Amber/Warning, Overdue=Red, Pending=Neutral)
  static const Color paid = Color(0xFF16A34A); // Clear Green
  static const Color paidBg = Color(0xFFDCFCE7);

  static const Color dueSoon = Color(0xFFEA580C); // Clear Orange
  static const Color dueSoonBg = Color(0xFFFFEDD5);

  static const Color dueToday = Color(0xFFD97706); // Amber / Warning
  static const Color dueTodayBg = Color(0xFFFEF3C7);

  static const Color overdue = Color(0xFFDC2626); // Alert Red
  static const Color overdueBg = Color(0xFFFEE2E2);

  static const Color pending = Color(0xFF64748B); // Neutral Slate
  static const Color pendingBg = Color(0xFFF1F5F9);

  // Status helper mapping
  static Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
      case 'COMPLETED':
        return paid;
      case 'DUE SOON':
        return dueSoon;
      case 'DUE TODAY':
        return dueToday;
      case 'OVERDUE':
        return overdue;
      case 'PENDING':
      case 'ACTIVE':
      default:
        return pending;
    }
  }

  static Color getStatusBgColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
      case 'COMPLETED':
        return paidBg;
      case 'DUE SOON':
        return dueSoonBg;
      case 'DUE TODAY':
        return dueTodayBg;
      case 'OVERDUE':
        return overdueBg;
      case 'PENDING':
      case 'ACTIVE':
      default:
        return pendingBg;
    }
  }
}
