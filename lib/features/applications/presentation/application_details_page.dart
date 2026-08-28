import 'package:flutter/material.dart';

import '../domain/job_application.dart';
import 'application_details_result.dart';
import 'application_form_sheet.dart';

class ApplicationDetailsPage extends StatelessWidget {
  const ApplicationDetailsPage({required this.application, super.key});

  final JobApplication application;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Application details'),
      actions: [
        IconButton(
          tooltip: 'Edit application',
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => _openEditSheet(context),
        ),
        IconButton(
          tooltip: 'Delete application',
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: () => _confirmDelete(context),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _ApplicationHeader(application),
        const SizedBox(height: 24),
        _DetailsSection(application),
        const SizedBox(height: 20),
        _NotesSection(notes: application.notes),
      ],
    ),
  );

  Future<void> _openEditSheet(BuildContext context) async {
    final updated = await showModalBottomSheet<JobApplication>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ApplicationFormSheet(initialApplication: application),
    );
    if (updated != null && context.mounted) {
      Navigator.pop(context, ApplicationUpdated(updated));
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete application?'),
        content: Text(
          'This will permanently remove the application at '
          '${application.company}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.pop(context, const ApplicationDeleted());
    }
  }
}

class _ApplicationHeader extends StatelessWidget {
  const _ApplicationHeader(this.application);

  final JobApplication application;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: application.status.color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(
              application.initials,
              style: TextStyle(
                color: application.status.color,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            application.role,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Text(
            application.company,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: application.status.color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  application.status.icon,
                  size: 17,
                  color: application.status.color,
                ),
                const SizedBox(width: 6),
                Text(
                  application.status.label,
                  style: TextStyle(
                    color: application.status.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _DetailsSection extends StatelessWidget {
  const _DetailsSection(this.application);

  final JobApplication application;

  @override
  Widget build(BuildContext context) {
    final dateFormatter = MaterialLocalizations.of(context);
    return Card(
      child: Column(
        children: [
          _DetailTile(
            icon: Icons.business_rounded,
            label: 'Company',
            value: application.company,
          ),
          const Divider(height: 1),
          _DetailTile(
            icon: Icons.work_outline_rounded,
            label: 'Job title',
            value: application.role,
          ),
          const Divider(height: 1),
          _DetailTile(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: application.location,
          ),
          const Divider(height: 1),
          _DetailTile(
            icon: Icons.schedule_rounded,
            label: 'Last update',
            value: application.updatedLabel,
          ),
          const Divider(height: 1),
          _DetailTile(
            icon: Icons.calendar_today_outlined,
            label: 'Application date',
            value: dateFormatter.formatMediumDate(application.appliedDate),
          ),
          if (application.interviewDate != null) ...[
            const Divider(height: 1),
            _DetailTile(
              icon: Icons.event_available_outlined,
              label: 'Interview date',
              value: dateFormatter.formatMediumDate(application.interviewDate!),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(label, style: TextStyle(color: Colors.grey.shade600)),
    subtitle: Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Text(
        value,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
  );
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({required this.notes});

  final String notes;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notes_rounded),
              SizedBox(width: 9),
              Text(
                'Notes',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            notes.isEmpty ? 'No notes added yet.' : notes,
            style: TextStyle(
              color: notes.isEmpty ? Colors.grey.shade600 : null,
              height: 1.5,
            ),
          ),
        ],
      ),
    ),
  );
}
