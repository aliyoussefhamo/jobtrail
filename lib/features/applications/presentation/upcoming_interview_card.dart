import 'package:flutter/material.dart';

import '../domain/job_application.dart';

class UpcomingInterviewCard extends StatelessWidget {
  const UpcomingInterviewCard({
    required this.application,
    required this.onTap,
    super.key,
  });

  final JobApplication application;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final interviewDate = application.interviewDate!;
    final formattedDate = MaterialLocalizations.of(context)
        .formatMediumDate(interviewDate);

    return Card(
      color: const Color(0xFFFFF7E6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  color: Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upcoming interview',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${application.company} - $formattedDate',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF92400E)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
