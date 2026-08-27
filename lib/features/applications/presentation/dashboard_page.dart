import 'package:flutter/material.dart';

import '../data/application_repository.dart';
import '../domain/job_application.dart';
import 'application_details_page.dart';
import 'application_details_result.dart';
import 'application_form_sheet.dart';
import 'applications_view_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({required this.repository, super.key});

  final ApplicationRepository repository;
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final ApplicationsViewModel viewModel;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    viewModel = ApplicationsViewModel(widget.repository)..load();
  }

  @override
  void dispose() {
    searchController.dispose();
    viewModel.dispose();
    super.dispose();
  }

  Future<void> openAddApplication() async {
    final result = await showModalBottomSheet<JobApplication>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const ApplicationFormSheet(),
    );
    if (result != null) await viewModel.add(result);
  }

  Future<void> openApplicationDetails(JobApplication application) async {
    final result = await Navigator.push<ApplicationDetailsResult>(
      context,
      MaterialPageRoute<ApplicationDetailsResult>(
        builder: (_) => ApplicationDetailsPage(application: application),
      ),
    );

    switch (result) {
      case ApplicationUpdated(application: final updated):
        await viewModel.update(application, updated);
      case ApplicationDeleted():
        await viewModel.delete(application);
      case null:
        break;
    }
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
        body: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : viewModel.errorMessage != null
            ? _LoadError(
                message: viewModel.errorMessage!,
                onRetry: viewModel.load,
              )
            : ListView(
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
                    controller: searchController,
                    onChanged: viewModel.setSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Search applications',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: viewModel.searchQuery.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              onPressed: () {
                                searchController.clear();
                                viewModel.setSearchQuery('');
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
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
                      PopupMenuButton<ApplicationSort>(
                        tooltip: 'Sort applications',
                        initialValue: viewModel.selectedSort,
                        onSelected: viewModel.setSort,
                        itemBuilder: (_) => ApplicationSort.values
                            .map(
                              (sort) => PopupMenuItem<ApplicationSort>(
                                value: sort,
                                child: Row(
                                  children: [
                                    if (sort == viewModel.selectedSort)
                                      const Icon(Icons.check_rounded, size: 18)
                                    else
                                      const SizedBox(width: 18),
                                    const SizedBox(width: 8),
                                    Text(sort.label),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        child: Row(
                          children: [
                            const Icon(Icons.sort_rounded, size: 19),
                            const SizedBox(width: 5),
                            Text(viewModel.selectedSort.label),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (items.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Center(
                          child: Text(
                            viewModel.searchQuery.isEmpty
                                ? 'No applications in this stage yet.'
                                : 'No applications match your search.',
                          ),
                        ),
                      ),
                    )
                  else
                    ...items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: JobCard(
                          item,
                          onTap: () => openApplicationDetails(item),
                        ),
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

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 44),
          const SizedBox(height: 12),
          Text(message),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
        ],
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
  const JobCard(this.item, {required this.onTap, super.key});

  final JobApplication item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
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
                          item.updatedLabel,
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
    ),
  );
}
