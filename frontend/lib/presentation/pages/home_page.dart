import 'package:flutter/material.dart';
import '../../data/repositories/mock_data_repository.dart';
import 'patient/patient_list_page.dart';
import 'appointment/appointment_list_page.dart';
import 'scan/scan_page.dart';
import 'patient/patient_register_page.dart';
import 'settings/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomeContent(),
    const PatientListPage(),
    const AppointmentListPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: colorScheme.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: colorScheme.primary),
            label: 'Patients',
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_today_outlined),
            selectedIcon:
                Icon(Icons.calendar_today, color: colorScheme.primary),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: colorScheme.primary),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final mockRepo = MockDataRepository();
    final stats = mockRepo.getDashboardStats();
    final recentPatients = mockRepo.getRecentPatients(limit: 5);
    final todayAppointments = mockRepo.getTodayAppointments();
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header AppBar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Dental Clinic',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                        ),
                        Text(
                          'Patient Management System',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                    IconButton.filledTonal(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_outlined),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Action Buttons Section
                _SectionTitle(title: 'Quick Actions'),
                const SizedBox(height: 12),
                _ActionButtonGrid(),
                const SizedBox(height: 24),

                // Quick Stats Section
                _SectionTitle(title: 'Quick Stats'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Patients',
                        value: '${stats['totalPatients']}',
                        icon: Icons.people,
                        color: colorScheme.primaryContainer,
                        iconColor: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: "Today's Appointments",
                        value: '${todayAppointments.length}',
                        icon: Icons.calendar_today,
                        color: colorScheme.secondaryContainer,
                        iconColor: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Recent Patients Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Patients',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('See All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ]),
            ),
          ),

          // Recent Patients List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final patient = recentPatients[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorScheme.primaryContainer,
                          child: Text(
                            patient.initials,
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        title: Text(patient.name),
                        subtitle: Text(
                          patient.lastVisit != null
                              ? 'Last visit: ${_formatDate(patient.lastVisit!)}'
                              : 'No visits yet',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onTap: () {},
                      ),
                    ),
                  );
                },
                childCount: recentPatients.length,
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _ActionButtonGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _ActionCard(
          icon: Icons.qr_code_scanner,
          label: 'Scan Patient',
          subtitle: 'Face/QR Code',
          color: Theme.of(context).colorScheme.primaryContainer,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScanPage()),
          ),
        ),
        _ActionCard(
          icon: Icons.person_add,
          label: 'Register',
          subtitle: 'New Patient',
          color: Theme.of(context).colorScheme.secondaryContainer,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PatientRegisterPage()),
          ),
        ),
        _ActionCard(
          icon: Icons.calendar_month,
          label: 'Schedule',
          subtitle: "Today's Appointments",
          color: Theme.of(context).colorScheme.tertiaryContainer,
          onTap: () {},
        ),
        _ActionCard(
          icon: Icons.medical_services,
          label: 'Treatments',
          subtitle: 'View All',
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          onTap: () {},
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                size: 28,
                color: colorScheme.onSurface,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color iconColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
