import 'package:flutter/material.dart';

import '../domain/application_event.dart';

class ApplicationTimeline extends StatelessWidget {
  const ApplicationTimeline({required this.events, super.key});

  final List<ApplicationEvent> events;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timeline_rounded),
              SizedBox(width: 9),
              Text(
                'Application timeline',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (events.isEmpty)
            Text(
              'No activity recorded yet.',
              style: TextStyle(color: Colors.grey.shade600),
            )
          else
            ...List.generate(
              events.length,
              (index) => _TimelineItem(
                event: events[index],
                isLast: index == events.length - 1,
              ),
            ),
        ],
      ),
    ),
  );
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.event, required this.isLast});

  final ApplicationEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(event.type);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 38,
          child: Column(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: color.withValues(alpha: .12),
                child: Icon(_iconFor(event.type), size: 18, color: color),
              ),
              if (!isLast)
                Container(width: 2, height: 38, color: Colors.grey.shade300),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  MaterialLocalizations.of(context)
                      .formatMediumDate(event.occurredAt),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

IconData _iconFor(ApplicationEventType type) => switch (type) {
  ApplicationEventType.applicationCreated => Icons.send_rounded,
  ApplicationEventType.statusChanged => Icons.swap_horiz_rounded,
  ApplicationEventType.interviewScheduled => Icons.event_available_rounded,
  ApplicationEventType.noteAdded => Icons.notes_rounded,
};

Color _colorFor(ApplicationEventType type) => switch (type) {
  ApplicationEventType.applicationCreated => const Color(0xFF4F46E5),
  ApplicationEventType.statusChanged => const Color(0xFF10B981),
  ApplicationEventType.interviewScheduled => const Color(0xFFF59E0B),
  ApplicationEventType.noteAdded => const Color(0xFF64748B),
};
