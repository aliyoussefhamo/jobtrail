import 'package:flutter/material.dart';

enum ApplicationStatus {
  applied('Applied', Color(0xFF4F46E5), Icons.send_rounded),
  interview('Interview', Color(0xFFF59E0B), Icons.groups_rounded),
  offer('Offer', Color(0xFF10B981), Icons.celebration_rounded),
  rejected('Rejected', Color(0xFFEF4444), Icons.close_rounded);

  const ApplicationStatus(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

class JobApplication {
  const JobApplication({
    required this.company,
    required this.role,
    required this.location,
    required this.status,
    required this.note,
    required this.initials,
  });

  final String company;
  final String role;
  final String location;
  final ApplicationStatus status;
  final String note;
  final String initials;
}
