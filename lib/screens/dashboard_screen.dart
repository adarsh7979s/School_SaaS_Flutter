import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
          onPressed: () async {
            final shouldLogout = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Sign Out'),
                content:
                    const Text('Are you sure you want to sign out?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            );
            if (shouldLogout == true && context.mounted) {
              state.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                LoginScreen.routeName,
                (route) => false,
              );
            }
          },
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'Sign Out',
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDECE7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8A494)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFAD3D28), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subscription Expired',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: const Color(0xFFAD3D28),
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Features are locked until renewal succeeds.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF7A2E1F),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (state.isSubscriptionExpired) const SizedBox(height: 18),

          // ── Stats row (admin/teacher only) ──
          if (user.role != UserRole.securityGuard)
            _StatsRow(state: state, user: user),
          if (user.role != UserRole.securityGuard) const SizedBox(height: 18),

          Text(
            'Quick Actions',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...cards.map((card) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ActionCard(card: card),
              )),
          const SizedBox(height: 18),
          _PermissionsCard(state: state),
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
            color: const Color(0xFF1565C0),
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
            color: const Color(0xFFE65100),
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
            subtitle: 'View details and attendance',
            icon: Icons.person_rounded,
            color: const Color(0xFF2E7D32),
            enabled: student != null,
            onTap: () => Navigator.pushNamed(
              context,
              StudentProfileScreen.routeName,
              arguments: student?.id,
            ),
          ),
          _DashboardAction(
            title: 'My Digital ID',
            subtitle: 'QR-enabled school ID card',
            icon: Icons.badge_rounded,
            color: const Color(0xFF6A1B9A),
            enabled: student != null && !state.isFeatureLocked,
            onTap: () => Navigator.pushNamed(
              context,
              IdCardScreen.routeName,
              arguments: student?.id,
            ),
          ),
          _DashboardAction(
            title: 'Subscription',
            subtitle: state.isSubscriptionExpired
                ? 'Your school subscription has expired'
                : 'View school plan status',
            icon: Icons.workspace_premium_rounded,
            color: const Color(0xFFE65100),
            enabled: true,
            onTap: () => Navigator.pushNamed(
              context,
              SubscriptionScreen.routeName,
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
            color: const Color(0xFF00838F),
            enabled: state.canAccessScanning(),
            onTap: () => Navigator.pushNamed(
              context,
              QrScannerScreen.routeName,
            ),
          ),
          _DashboardAction(
            title: 'Subscription',
            subtitle: 'View whether this school is active or locked',
            icon: Icons.lock_clock_outlined,
            color: const Color(0xFFE65100),
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

// ── Stats Row ──
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.state, required this.user});

  final AppState state;
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final studentCount = state.visibleStudents.length;
    final todayAttendance = state.schoolAttendance
        .where((r) =>
            r.timestamp.day == DateTime.now().day &&
            r.timestamp.month == DateTime.now().month &&
            r.timestamp.year == DateTime.now().year)
        .toList();
    final entryCount =
        todayAttendance.where((r) => r.type == AttendanceType.entry).length;

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.groups_outlined,
            label: 'Students',
            value: '$studentCount',
            color: const Color(0xFF1565C0),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.login_rounded,
            label: 'Entries Today',
            value: '$entryCount',
            color: const Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.calendar_today_rounded,
            label: 'Plan Ends',
            value: DateFormat('dd MMM').format(
              state.currentSchool?.subscriptionEndsOn ?? DateTime.now(),
            ),
            color: state.isSubscriptionExpired
                ? const Color(0xFFAD3D28)
                : const Color(0xFFE65100),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color.withValues(alpha: 0.8),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Action Card ──
class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.card});

  final _DashboardAction card;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: card.enabled ? card.onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: card.enabled
                      ? card.color.withValues(alpha: 0.10)
                      : const Color(0xFFE9EDF0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  card.icon,
                  color: card.enabled ? card.color : Colors.grey,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.title,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.black54,
                              ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                card.enabled
                    ? Icons.arrow_forward_ios_rounded
                    : Icons.lock_outline_rounded,
                size: 16,
                color: card.enabled ? card.color : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hero Card ──
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.user, required this.school});

  final AppUser user;
  final School school;

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D2B45), Color(0xFF123C63), Color(0xFF1E6781)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x330C2D4C),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white60,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.name,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                child: Text(
                  user.name[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoChip(
                label: state.describeRole(user.role),
                icon: Icons.verified_user_rounded,
              ),
              _InfoChip(
                label: school.name,
                icon: Icons.school_rounded,
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

// ── School Switcher ──
class _SchoolSwitcher extends StatelessWidget {
  const _SchoolSwitcher({required this.state, required this.currentSchool});

  final AppState state;
  final School currentSchool;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Multi-School Context',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: currentSchool.id,
              decoration: const InputDecoration(
                labelText: 'Active School',
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
          ],
        ),
      ),
    );
  }
}

// ── Permissions Card ──
class _PermissionsCard extends StatelessWidget {
  const _PermissionsCard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Role Permissions',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _PermRow(
              label: 'Student directory',
              allowed: state.canAccessStudentDirectory(),
            ),
            _PermRow(
              label: 'Own profile access',
              allowed: state.canAccessOwnStudentProfile(),
            ),
            _PermRow(
              label: 'QR scanning',
              allowed: state.canAccessScanning(),
            ),
            _PermRow(
              label: 'Subscription admin',
              allowed: state.canAccessSubscription(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermRow extends StatelessWidget {
  const _PermRow({required this.label, required this.allowed});

  final String label;
  final bool allowed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            allowed ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 18,
            color: allowed ? const Color(0xFF2E7D32) : const Color(0xFFBD5A2B),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: allowed
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFDE3DA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              allowed ? 'Allowed' : 'Blocked',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: allowed
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFBD5A2B),
              ),
            ),
          ),
        ],
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
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
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
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;
}
