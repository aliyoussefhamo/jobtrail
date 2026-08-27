import 'package:flutter/material.dart';

void main() => runApp(const JobTrailApp());

class JobTrailApp extends StatelessWidget {
  const JobTrailApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'JobTrail',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
      scaffoldBackgroundColor: const Color(0xFFF7F7FC),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
    home: const DashboardPage(),
  );
}

enum Status {
  applied('Applied', Color(0xFF4F46E5), Icons.send_rounded),
  interview('Interview', Color(0xFFF59E0B), Icons.groups_rounded),
  offer('Offer', Color(0xFF10B981), Icons.celebration_rounded),
  rejected('Rejected', Color(0xFFEF4444), Icons.close_rounded);

  const Status(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

class Job {
  const Job(
    this.company,
    this.role,
    this.place,
    this.status,
    this.note,
    this.initials,
  );
  final String company, role, place, note, initials;
  final Status status;
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Status? selected;
  static const jobs = [
    Job(
      'Nova Labs',
      'Flutter Developer',
      'Berlin - Remote',
      Status.interview,
      'Interview tomorrow, 10:00',
      'NL',
    ),
    Job(
      'Northstar GmbH',
      'Mobile Software Engineer',
      'Frankfurt - Hybrid',
      Status.applied,
      'Applied 2 days ago',
      'NG',
    ),
    Job(
      'Pixel Forge',
      'iOS & Flutter Developer',
      'Hamburg - Remote',
      Status.offer,
      'Offer received today',
      'PF',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final shown = selected == null
        ? jobs
        : jobs.where((job) => job.status == selected).toList();
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
          const SummaryCard(),
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
              itemCount: Status.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final status = Status.values[i];
                return FilterChip(
                  selected: selected == status,
                  avatar: Icon(status.icon, size: 16),
                  label: Text(status.label),
                  onSelected: (_) => setState(
                    () => selected = selected == status ? null : status,
                  ),
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
          if (shown.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Center(
                  child: Text('No applications in this stage yet.'),
                ),
              ),
            )
          else
            ...shown.map(
              (job) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: JobCard(job),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add application'),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key});
  @override
  Widget build(BuildContext context) => Container(
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
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Metric('12', 'Applications')),
            Expanded(child: Metric('3', 'Interviews')),
            Expanded(child: Metric('1', 'Offer')),
          ],
        ),
        SizedBox(height: 20),
        Text(
          '25% interview rate',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 9),
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(99)),
          child: LinearProgressIndicator(
            value: .25,
            minHeight: 7,
            color: Colors.white,
            backgroundColor: Color(0x55FFFFFF),
          ),
        ),
      ],
    ),
  );
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
  const JobCard(this.job, {super.key});
  final Job job;
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
              color: job.status.color.withValues(alpha: .11),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              job.initials,
              style: TextStyle(
                color: job.status.color,
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
                  job.role,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "${job.company} - ${job.place}",
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
                        color: job.status.color.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        job.status.label,
                        style: TextStyle(
                          color: job.status.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        job.note,
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
