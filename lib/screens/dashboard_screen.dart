import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:edu_id_saas/models/app_models.dart';
import 'package:edu_id_saas/providers/app_state.dart';
import 'package:edu_id_saas/screens/id_card_screen.dart';
import 'package:edu_id_saas/screens/login_screen.dart';
import 'package:edu_id_saas/screens/qr_scanner_screen.dart';
import 'package:edu_id_saas/screens/student_list_screen.dart';
import 'package:edu_id_saas/screens/student_profile_screen.dart';
import 'package:edu_id_saas/screens/subscription_screen.dart';
import 'package:edu_id_saas/widgets/app_shell.dart';
import 'package:edu_id_saas/widgets/empty_state_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const routeName = '/dashboard';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser;
    final school = state.currentSchool;

    if (user == null || school == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      });
      return const SizedBox.shrink();
    }

    final cards = _buildActions(context, state, user);

    return AppShell(
      title: 'Dashboard',
      actions: [
        IconButton(
          onPressed: () {
            state.logout();
            Navigator.pushReplacementNamed(context, LoginScreen.routeName);
          },
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _HeroCard(user: user, school: school),
          const SizedBox(height: 18),
          if (user.role == UserRole.superAdmin)
            _SchoolSwitcher(state: state, currentSchool: school),
          if (user.role == UserRole.superAdmin) const SizedBox(height: 18),
          if (state.isSubscriptionExpired)
            const EmptyStateCard(
              title: 'Subscription expired',
              message:
                  'Student browsing and QR attendance are locked for this school until renewal succeeds.',
              icon: Icons.lock_outline_rounded,
            ),
          if (state.isSubscriptionExpired) const SizedBox(height: 18),
          Text(
            'Quick actions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cards.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              mainAxisSpacing: 14,
              childAspectRatio: 1.9,
            ),
            itemBuilder: (context, index) {
              final card = cards[index];
              return Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: card.enabled ? card.onTap : null,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: card.enabled
                              ? const Color(0xFFDBE9FA)
                              : const Color(0xFFE9EDF0),
                          child: Icon(
                            card.icon,
                            color: card.enabled
                                ? const Color(0xFF174B7A)
                                : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card.title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 6),
                              Text(card.subtitle),
                            ],
                          ),
                        ),
                        Icon(
                          card.enabled
                              ? Icons.arrow_forward_rounded
                              : Icons.lock_outline_rounded,
                          color: card.enabled
                              ? const Color(0xFF174B7A)
                              : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Role permissions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Student directory: ${state.canAccessStudentDirectory() ? 'Allowed' : 'Blocked'}',
                  ),
                  Text(
                    'Own profile access: ${state.canAccessOwnStudentProfile() ? 'Allowed' : 'Blocked'}',
                  ),
                  Text(
                    'QR scanning: ${state.canAccessScanning() ? 'Allowed' : 'Blocked'}',
                  ),
                  Text(
                    'Subscription admin: ${state.canAccessSubscription() ? 'Allowed' : 'Blocked'}',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_DashboardAction> _buildActions(
    BuildContext context,
    AppState state,
    AppUser user,
  ) {
    final student = state.currentStudent;

    switch (user.role) {
      case UserRole.superAdmin:
      case UserRole.schoolAdmin:
      case UserRole.teacher:
        return [
          _DashboardAction(
            title: 'Students',
            subtitle: state.canAccessStudentDirectory()
                ? 'Browse school-wise students and profiles'
                : 'Directory is locked until subscription renewal',
            icon: Icons.groups_rounded,
            enabled: state.canAccessStudentDirectory(),
            onTap: () => Navigator.pushNamed(
              context,
              StudentListScreen.routeName,
            ),
          ),
          _DashboardAction(
            title: 'Subscription',
            subtitle: state.canAccessSubscription()
                ? 'Review plan status and payment flow'
                : 'View-only role',
            icon: Icons.workspace_premium_rounded,
            enabled: state.canAccessSubscription(),
            onTap: () => Navigator.pushNamed(
              context,
              SubscriptionScreen.routeName,
            ),
          ),
        ];
      case UserRole.student:
        return [
          _DashboardAction(
            title: 'My Profile',
            subtitle: 'View student details and attendance history',
            icon: Icons.person_rounded,
            enabled: student != null,
            onTap: () => Navigator.pushNamed(
              context,
              StudentProfileScreen.routeName,
              arguments: student?.id,
            ),
          ),
          _DashboardAction(
            title: 'My Digital ID',
            subtitle: 'Open QR-enabled school ID card',
            icon: Icons.badge_rounded,
            enabled: student != null,
            onTap: () => Navigator.pushNamed(
              context,
              IdCardScreen.routeName,
              arguments: student?.id,
            ),
          ),
        ];
      case UserRole.securityGuard:
        return [
          _DashboardAction(
            title: 'QR Attendance',
            subtitle: state.canAccessScanning()
                ? 'Scan student codes for entry and exit'
                : 'Scanner is locked for expired subscriptions',
            icon: Icons.qr_code_scanner_rounded,
            enabled: state.canAccessScanning(),
            onTap: () => Navigator.pushNamed(
              context,
              QrScannerScreen.routeName,
            ),
          ),
          _DashboardAction(
            title: 'Subscription Status',
            subtitle: 'View whether this school is active or locked',
            icon: Icons.lock_clock_outlined,
            enabled: true,
            onTap: () => Navigator.pushNamed(
              context,
              SubscriptionScreen.routeName,
            ),
          ),
        ];
    }
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.user, required this.school});

  final AppUser user;
  final School school;

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF123C63), Color(0xFF1E6781)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${user.name}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${state.describeRole(user.role)} - ${school.name}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoChip(
                label: school.planName,
                icon: Icons.workspace_premium_outlined,
              ),
              _InfoChip(
                label: school.isExpired ? 'Expired' : 'Active',
                icon: school.isExpired
                    ? Icons.lock_outline_rounded
                    : Icons.verified_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SchoolSwitcher extends StatelessWidget {
  const _SchoolSwitcher({required this.state, required this.currentSchool});

  final AppState state;
  final School currentSchool;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: DropdownButtonFormField<String>(
          value: currentSchool.id,
          decoration: const InputDecoration(
            labelText: 'Switch School',
            prefixIcon: Icon(Icons.school_outlined),
          ),
          items: state.schools
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item.id,
                  child: Text(item.name),
                ),
              )
              .toList(growable: false),
          onChanged: (value) {
            if (value != null) state.switchSchool(value);
          },
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardAction {
  const _DashboardAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
}
