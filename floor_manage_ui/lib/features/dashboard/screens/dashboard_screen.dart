import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/user_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(userProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: [
                  if (user.role == 'admin')
                    _DashboardCard(
                      icon: Icons.upload_file,
                      title: 'Upload Floor Plan',
                      subtitle: 'Admin Only',
                      color: Colors.blue.shade50,
                      iconColor: Colors.blue,
                      onTap: () => context.push('/admin/upload'),
                    ),
                  _DashboardCard(
                    icon: Icons.meeting_room,
                    title: 'Meeting Rooms',
                    subtitle: 'Book & View',
                    color: Colors.orange.shade50,
                    iconColor: Colors.orange,
                    onTap: () => context.push('/rooms'),
                  ),
                  _DashboardCard(
                    icon: Icons.map_outlined,
                    title: 'Floor Map',
                    subtitle: 'Visual Layout',
                    color: Colors.green.shade50,
                    iconColor: Colors.green,
                    onTap: () => context.push('/floor-map'),
                  ),
                  _DashboardCard(
                    icon: Icons.calendar_today,
                    title: 'My Bookings',
                    subtitle: 'View Schedule',
                    color: Colors.purple.shade50,
                    iconColor: Colors.purple,
                    onTap: () => context.push('/my-bookings'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: iconColor),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
