import 'package:flutter/material.dart';

import '../domain/job_application.dart';

class ApplicationFormSheet extends StatefulWidget {
  const ApplicationFormSheet({this.initialApplication, super.key});

  final JobApplication? initialApplication;

  @override
  State<ApplicationFormSheet> createState() => _ApplicationFormSheetState();
}

class _ApplicationFormSheetState extends State<ApplicationFormSheet> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController companyController;
  late final TextEditingController roleController;
  late final TextEditingController locationController;
  late final TextEditingController notesController;
  late ApplicationStatus chosenStatus;

  bool get isEditing => widget.initialApplication != null;

  @override
  void initState() {
    super.initState();
    final application = widget.initialApplication;
    companyController = TextEditingController(text: application?.company);
    roleController = TextEditingController(text: application?.role);
    locationController = TextEditingController(text: application?.location);
    notesController = TextEditingController(text: application?.notes);
    chosenStatus = application?.status ?? ApplicationStatus.applied;
  }

  @override
  void dispose() {
    companyController.dispose();
    roleController.dispose();
    locationController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void submit() {
    if (!formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      JobApplication(
        company: companyController.text.trim(),
        role: roleController.text.trim(),
        location: locationController.text.trim(),
        status: chosenStatus,
        updatedLabel: isEditing ? 'Updated just now' : 'Added just now',
        notes: notesController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      0,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 24,
    ),
    child: SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEditing ? 'Edit application' : 'Add a new application',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: companyController,
              decoration: const InputDecoration(
                labelText: 'Company',
                prefixIcon: Icon(Icons.business_rounded),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Please enter a company name'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: roleController,
              decoration: const InputDecoration(
                labelText: 'Job title',
                prefixIcon: Icon(Icons.work_outline_rounded),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Please enter a job title'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Please enter a location'
                  : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<ApplicationStatus>(
              initialValue: chosenStatus,
              decoration: const InputDecoration(
                labelText: 'Application status',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: ApplicationStatus.values
                  .map(
                    (status) => DropdownMenuItem<ApplicationStatus>(
                      value: status,
                      child: Text(status.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => chosenStatus = value);
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: notesController,
              maxLines: 3,
              maxLength: 300,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.notes_rounded),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: submit,
              icon: const Icon(Icons.save_rounded),
              label: Text(isEditing ? 'Save changes' : 'Save application'),
            ),
          ],
        ),
      ),
    ),
  );
}
