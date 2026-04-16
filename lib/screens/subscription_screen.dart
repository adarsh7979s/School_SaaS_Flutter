import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:edu_id_saas/models/app_models.dart';
import 'package:edu_id_saas/providers/app_state.dart';
import 'package:edu_id_saas/widgets/app_shell.dart';
import 'package:edu_id_saas/widgets/empty_state_card.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  static const routeName = '/subscription';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final school = state.currentSchool;
    final canManageSubscription = state.canAccessSubscription();

    return AppShell(
      title: 'Subscription',
      child: school == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: EmptyStateCard(
                  title: 'School unavailable',
                  message: 'Select a school to view plan details.',
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ── Status Card ──
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: school.isExpired
                          ? const [Color(0xFF6D1F11), Color(0xFFAD3D28)]
                          : const [Color(0xFF0D2B45), Color(0xFF1E6781)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (school.isExpired
                                ? const Color(0xFFAD3D28)
                                : const Color(0xFF1E6781))
                            .withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            school.isExpired
                                ? Icons.error_outline_rounded
                                : Icons.verified_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            school.isExpired ? 'EXPIRED' : 'ACTIVE',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        school.name,
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${school.planName} Plan',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                color: Colors.white70, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              school.isExpired
                                  ? 'Expired on ${DateFormat('dd MMM yyyy').format(school.subscriptionEndsOn)}'
                                  : 'Valid until ${DateFormat('dd MMM yyyy').format(school.subscriptionEndsOn)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Plan Details Card ──
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Plan Details',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 16),
                        _DetailRow(
                          icon: Icons.workspace_premium_rounded,
                          label: 'Current Plan',
                          value: school.planName,
                        ),
                        _DetailRow(
                          icon: Icons.toggle_on_rounded,
                          label: 'Status',
                          value: school.isExpired ? 'Expired' : 'Active',
                          valueColor: school.isExpired
                              ? const Color(0xFFAD3D28)
                              : const Color(0xFF2E7D32),
                        ),
                        _DetailRow(
                          icon: Icons.date_range_rounded,
                          label: 'Valid Until',
                          value: DateFormat('dd MMM yyyy')
                              .format(school.subscriptionEndsOn),
                        ),
                        _DetailRow(
                          icon: Icons.school_rounded,
                          label: 'School',
                          value: school.name,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Features included card ──
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Features Included',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 14),
                        _FeatureRow(
                            label: 'Digital ID Cards',
                            active: !school.isExpired),
                        _FeatureRow(
                            label: 'QR-based Attendance',
                            active: !school.isExpired),
                        _FeatureRow(
                            label: 'Student Directory',
                            active: !school.isExpired),
                        _FeatureRow(
                            label: 'Multi-School Support',
                            active: !school.isExpired),
                        _FeatureRow(
                            label: 'Cloud CDN Assets', active: true),
                        _FeatureRow(
                            label: 'Role-Based Access', active: true),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Payment Card ──
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.payment_rounded,
                                color: Color(0xFF0E3B5F)),
                            const SizedBox(width: 10),
                            Text(
                              'Upgrade or Renew',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          canManageSubscription
                              ? 'Simulated payment flow. On success, your subscription will be upgraded for 12 months and all features will be unlocked.'
                              : 'Only Super Admins and School Admins can manage payments. Contact your administrator.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.black54,
                                  ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton.icon(
                            onPressed: !canManageSubscription ||
                                    state.isProcessingPayment
                                ? null
                                : () async {
                                    final messenger =
                                        ScaffoldMessenger.of(context);
                                    final result = await context
                                        .read<AppState>()
                                        .simulatePayment();
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(
                                              result.success
                                                  ? Icons.check_circle_rounded
                                                  : Icons.error_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                                child:
                                                    Text(result.message)),
                                          ],
                                        ),
                                        backgroundColor: result.success
                                            ? const Color(0xFF1B7F4B)
                                            : const Color(0xFFAD3D28),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  },
                            icon: state.isProcessingPayment
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.payment_rounded),
                            label: Text(
                              state.isProcessingPayment
                                  ? 'Processing Payment…'
                                  : 'Simulate Payment',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF0E3B5F),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (school.isExpired)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDECE7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8A494)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline_rounded,
                            color: Color(0xFFAD3D28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'App features are locked. Complete payment to restore access.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: const Color(0xFF7A2E1F),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF5A7A99)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            active ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 18,
            color: active ? const Color(0xFF2E7D32) : const Color(0xFFBD5A2B),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.black87 : Colors.black38,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
