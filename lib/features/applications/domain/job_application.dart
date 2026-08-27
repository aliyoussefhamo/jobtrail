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
    required this.id,
    required this.company,
    required this.role,
    required this.location,
    required this.status,
    required this.updatedLabel,
    this.notes = '',
  });

  final String id;
  final String company;
  final String role;
  final String location;
  final ApplicationStatus status;
  final String updatedLabel;
  final String notes;

  String get initials {
    final words = company
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) {
      return '?';
    }

    if (words.length == 1) {
      final word = words.first;
      final length = word.length >= 2 ? 2 : 1;
      return word.substring(0, length).toUpperCase();
    }

    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}
