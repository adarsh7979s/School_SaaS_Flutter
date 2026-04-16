import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:edu_id_saas/models/app_models.dart';
import 'package:edu_id_saas/providers/app_state.dart';
import 'package:edu_id_saas/screens/id_card_screen.dart';
import 'package:edu_id_saas/widgets/app_shell.dart';
import 'package:edu_id_saas/widgets/empty_state_card.dart';
import 'package:edu_id_saas/widgets/network_avatar.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  static const routeName = '/student-profile';

  @override
  Widget build(BuildContext context) {
    final studentId = ModalRoute.of(context)?.settings.arguments as String?;
    final state = context.watch<AppState>();
    final student = studentId == null ? null : state.getStudentById(studentId);

    if (student == null) {
      return const AppShell(
        title: 'Student Profile',
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: EmptyStateCard(
              title: 'Student unavailable',
              message: 'The requested student could not be loaded.',
            ),
          ),
        ),
      );
    }

    if (!state.canViewStudent(student.id)) {
      return const AppShell(
        title: 'Student Profile',
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: EmptyStateCard(
              title: 'Access restricted',
              message:
                  'This profile is available only to the assigned student or authorized staff of an active school.',
              icon: Icons.no_accounts_outlined,
            ),
          ),
        ),
      );
    }

    final latestAttendance = state.latestAttendanceForStudent(student.id);
    final attendanceHistory = state
        .getAttendanceForStudent(student.id)
        .take(4)
        .toList(growable: false);

    return AppShell(
      title: 'Student Profile',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  NetworkAvatar(
                    imageUrl: student.imageUrl,
                    name: student.name,
                    radius: 56,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    student.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text('Grade ${student.grade}-${student.section}'),
                  const SizedBox(height: 18),
                  _ProfileDetail(label: 'Roll Number', value: student.rollNumber),
                  _ProfileDetail(label: 'Guardian', value: student.guardianName),
                  _ProfileDetail(
                    label: 'Transport Route',
                    value: student.routeName,
                  ),
                  _ProfileDetail(label: 'QR Payload', value: student.qrValue),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(
              context,
              IdCardScreen.routeName,
              arguments: student.id,
            ),
            icon: const Icon(Icons.badge_outlined),
            label: const Text('Open Digital ID Card'),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendance Status',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    latestAttendance == null
                        ? 'Present status: Not marked yet'
                        : 'Latest status: ${state.describeAttendanceType(latestAttendance.type)}',
                  ),
                  if (latestAttendance != null)
                    Text(
                      'Updated on ${DateFormat('dd MMM, hh:mm a').format(latestAttendance.timestamp)}',
                    ),
                  const SizedBox(height: 16),
                  if (attendanceHistory.isEmpty)
                    const Text('No attendance history available.')
                  else
                    ...attendanceHistory.map(
                      (record) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Icon(
                              record.type == AttendanceType.entry
                                  ? Icons.login_rounded
                                  : Icons.logout_rounded,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.describeAttendanceType(record.type),
                              ),
                            ),
                            Text(
                              DateFormat(
                                'dd MMM, hh:mm a',
                              ).format(record.timestamp),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetail extends StatelessWidget {
  const _ProfileDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
