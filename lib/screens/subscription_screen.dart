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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          school.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _StatusPill(
                              label: school.isExpired ? 'Expired' : 'Active',
                              color: school.isExpired
                                  ? const Color(0xFF9F3C2B)
                                  : const Color(0xFF1B7F4B),
                            ),
                            _StatusPill(
                              label: school.planName,
                              color: const Color(0xFF174B7A),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _InfoRow(label: 'Current Plan', value: school.planName),
                        _InfoRow(
                          label: 'Status',
                          value: school.subscriptionStatus ==
                                  SubscriptionStatus.active
                              ? 'Active'
                              : 'Expired',
                        ),
                        _InfoRow(
                          label: 'Valid Until',
                          value: DateFormat(
                            'dd MMM yyyy',
                          ).format(school.subscriptionEndsOn),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upgrade plan',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          canManageSubscription
                              ? 'Simulated payment flow for renewing or upgrading the school subscription. This unlocks app features when successful.'
                              : 'You can review subscription status here, but only super admins and school admins can run the payment flow.',
                        ),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: !canManageSubscription ||
                                  state.isProcessingPayment
                              ? null
                              : () async {
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  final result = await context
                                      .read<AppState>()
                                      .simulatePayment();
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(result.message),
                                      backgroundColor: result.success
                                          ? const Color(0xFF1B7F4B)
                                          : const Color(0xFFAD3D28),
                                    ),
                                  );
                                },
                          icon: state.isProcessingPayment
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.payment_rounded),
                          label: Text(
                            state.isProcessingPayment
                                ? 'Processing...'
                                : 'Simulate Payment',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (school.isExpired)
                  const EmptyStateCard(
                    title: 'Application locked for this school',
                    message:
                        'Student browsing and QR attendance stay disabled until payment succeeds.',
                    icon: Icons.lock_clock_outlined,
                  ),
              ],
            ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}
