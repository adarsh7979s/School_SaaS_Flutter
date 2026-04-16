import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:edu_id_saas/providers/app_state.dart';
import 'package:edu_id_saas/widgets/app_shell.dart';
import 'package:edu_id_saas/widgets/empty_state_card.dart';
import 'package:edu_id_saas/widgets/network_avatar.dart';

class IdCardScreen extends StatelessWidget {
  const IdCardScreen({super.key});

  static const routeName = '/id-card';

  @override
  Widget build(BuildContext context) {
    final studentId = ModalRoute.of(context)?.settings.arguments as String?;
    final state = context.watch<AppState>();
    final student = studentId == null ? null : state.getStudentById(studentId);
    final school = state.currentSchool;

    return AppShell(
      title: 'Digital ID Card',
      child: student == null || school == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: EmptyStateCard(
                  title: 'ID card unavailable',
                  message: 'Student or school data is missing.',
                ),
              ),
            )
          : !state.canViewStudent(student.id)
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: EmptyStateCard(
                  title: 'ID card access restricted',
                  message:
                      'Only the assigned student or authorized staff can view this digital ID card.',
                  icon: Icons.lock_outline_rounded,
                ),
              ),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF10385C),
                          Color(0xFF1D6F86),
                          Color(0xFFF0C96B),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x220C2D4C),
                          blurRadius: 24,
                          offset: Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      school.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Student Identity Pass',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                              NetworkAvatar(
                                imageUrl: school.logoUrl,
                                name: school.name,
                                radius: 28,
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              NetworkAvatar(
                                imageUrl: student.imageUrl,
                                name: student.name,
                                radius: 52,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Grade ${student.grade}-${student.section}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      student.rollNumber,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Column(
                              children: [
                                QrImageView(
                                  data: student.qrValue,
                                  size: 170,
                                  eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: Color(0xFF10385C),
                                  ),
                                  dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.square,
                                    color: Color(0xFF1D6F86),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Use this QR for campus entry and exit attendance.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
