import 'package:flutter/material.dart';

import '../data/application_repository.dart';
import '../domain/job_application.dart';
import 'applications_view_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final ApplicationsViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = ApplicationsViewModel(InMemoryApplicationRepository());
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Future<void> openAddApplication() async {
    final result = await showModalBottomSheet<JobApplication>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const AddApplicationSheet(),
    );
    if (result != null) viewModel.add(result);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) {
      final items = viewModel.visibleApplications;
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.route_rounded, color: Colors.white),
              ),
              const SizedBox(width: 10),
              const Text(
                'JobTrail',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Badge(
                smallSize: 7,
                child: Icon(Icons.notifications_none_rounded),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 104),
          children: [
            Text(
              'Good morning, Ali',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Your next opportunity is already on the trail.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 24),
            SummaryCard(
              total: viewModel.allApplications.length,
              interviews: viewModel.count(ApplicationStatus.interview),
              offers: viewModel.count(ApplicationStatus.offer),
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search applications',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ApplicationStatus.values.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final status = ApplicationStatus.values[i];
                  return FilterChip(
                    selected: viewModel.selectedStatus == status,
                    avatar: Icon(status.icon, size: 16),
                    label: Text(status.label),
                    onSelected: (_) => viewModel.toggleFilter(status),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Text(
                  'Recent applications',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text('See all')),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(28),
                  child: Center(
                    child: Text('No applications in this stage yet.'),
                  ),
                ),
              )
            else
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: JobCard(item),
                ),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: openAddApplication,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add application'),
        ),
      );
    },
  );
}

class AddApplicationSheet extends StatefulWidget {
  const AddApplicationSheet({super.key});
  @override
  State<AddApplicationSheet> createState() => _AddApplicationSheetState();
}

class _AddApplicationSheetState extends State<AddApplicationSheet> {
  final formKey = GlobalKey<FormState>();
  final companyController = TextEditingController();
  final roleController = TextEditingController();
  final locationController = TextEditingController();
  ApplicationStatus chosenStatus = ApplicationStatus.applied;

  @override
  void dispose() {
    companyController.dispose();
    roleController.dispose();
    locationController.dispose();
    super.dispose();
  }

  void submit() {
    if (!formKey.currentState!.validate()) return;
    final company = companyController.text.trim();
    Navigator.pop(
      context,
      JobApplication(
        company: company,
        role: roleController.text.trim(),
        location: locationController.text.trim(),
        status: chosenStatus,
        note: 'Added just now',
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
            const Text(
              'Add a new application',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
            TextFormField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a location';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<ApplicationStatus>(
              initialValue: chosenStatus,
              decoration: const InputDecoration(
                labelText: 'Application status',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: ApplicationStatus.values.map((status) {
                return DropdownMenuItem<ApplicationStatus>(
                  value: status,
                  child: Text(status.label),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    chosenStatus = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: submit,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save application'),
            ),
          ],
        ),
      ),
    ),
  );
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    required this.total,
    required this.interviews,
    required this.offers,
    super.key,
  });
  final int total, interviews, offers;

  @override
  Widget build(BuildContext context) {
    final rate = total == 0 ? 0.0 : interviews / total;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x334F46E5),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Metric(total.toString(), 'Applications')),
              Expanded(child: Metric(interviews.toString(), 'Interviews')),
              Expanded(child: Metric(offers.toString(), 'Offers')),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "${(rate * 100).round()}% interview rate",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: rate,
              minHeight: 7,
              color: Colors.white,
              backgroundColor: const Color(0x55FFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}

class Metric extends StatelessWidget {
  const Metric(this.value, this.label, {super.key});
  final String value, label;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 27,
          fontWeight: FontWeight.w800,
        ),
      ),
      Text(label, style: const TextStyle(color: Color(0xCCFFFFFF))),
    ],
  );
}

class JobCard extends StatelessWidget {
  const JobCard(this.item, {super.key});
  final JobApplication item;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: item.status.color.withValues(alpha: .11),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              item.initials,
              style: TextStyle(
                color: item.status.color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.role,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "${item.company} - ${item.location}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: item.status.color.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        item.status.label,
                        style: TextStyle(
                          color: item.status.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        item.note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    ),
  );
}
