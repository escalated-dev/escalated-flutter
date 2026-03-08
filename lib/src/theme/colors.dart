import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF6366F1);

  // Surface
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF171717);

  // Background
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color backgroundDark = Color(0xFF0A0A0A);

  // Text
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  // Border
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0x0FFFFFFF);

  // Status colors
  static const Color statusOpen = Color(0xFF3B82F6);
  static const Color statusInProgress = Color(0xFFF59E0B);
  static const Color statusWaitingOnCustomer = Color(0xFF8B5CF6);
  static const Color statusWaitingOnAgent = Color(0xFFEC4899);
  static const Color statusEscalated = Color(0xFFEF4444);
  static const Color statusResolved = Color(0xFF10B981);
  static const Color statusClosed = Color(0xFF6B7280);
  static const Color statusReopened = Color(0xFFF97316);

  // Priority colors
  static const Color priorityLow = Color(0xFF6B7280);
  static const Color priorityMedium = Color(0xFF3B82F6);
  static const Color priorityHigh = Color(0xFFF59E0B);
  static const Color priorityUrgent = Color(0xFFF97316);
  static const Color priorityCritical = Color(0xFFEF4444);

  // SLA colors
  static const Color slaGreen = Color(0xFF10B981);
  static const Color slaYellow = Color(0xFFF59E0B);
  static const Color slaRed = Color(0xFFEF4444);

  static Color statusColor(String status) {
    switch (status) {
      case 'open':
        return statusOpen;
      case 'in_progress':
        return statusInProgress;
      case 'waiting_on_customer':
        return statusWaitingOnCustomer;
      case 'waiting_on_agent':
        return statusWaitingOnAgent;
      case 'escalated':
        return statusEscalated;
      case 'resolved':
        return statusResolved;
      case 'closed':
        return statusClosed;
      case 'reopened':
        return statusReopened;
      default:
        return statusOpen;
    }
  }

  static Color priorityColor(String priority) {
    switch (priority) {
      case 'low':
        return priorityLow;
      case 'medium':
        return priorityMedium;
      case 'high':
        return priorityHigh;
      case 'urgent':
        return priorityUrgent;
      case 'critical':
        return priorityCritical;
      default:
        return priorityMedium;
    }
  }
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

class AppRadius {
  AppRadius._();

  static const double base = 8;
  static const double card = 12;
  static const double badge = 24;

  static final BorderRadius baseBorder = BorderRadius.circular(base);
  static final BorderRadius cardBorder = BorderRadius.circular(card);
  static final BorderRadius badgeBorder = BorderRadius.circular(badge);
}
