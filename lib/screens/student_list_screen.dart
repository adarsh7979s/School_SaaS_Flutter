import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:edu_id_saas/providers/app_state.dart';
import 'package:edu_id_saas/screens/student_profile_screen.dart';
import 'package:edu_id_saas/widgets/app_shell.dart';
import 'package:edu_id_saas/widgets/empty_state_card.dart';
import 'package:edu_id_saas/widgets/network_avatar.dart';

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  static const routeName = '/students';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final students = state.visibleStudents;

    return AppShell(
      title: 'Students',
      child: !state.canAccessStudentDirectory()
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: EmptyStateCard(
                  title: 'Directory locked',
                  message:
                      'Only admins and teachers can browse students for an active school.',
                  icon: Icons.lock_outline_rounded,
                ),
              ),
            )
          : students.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: EmptyStateCard(
                  title: 'No students found',
                  message: 'This school does not have demo students yet.',
                ),
              ),
            )
          : ListView.builder(
              itemCount: students.length,
              padding: const EdgeInsets.all(20),
              itemBuilder: (context, index) {
                final student = students[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(14),
                      leading: NetworkAvatar(
                        imageUrl: student.imageUrl,
                        name: student.name,
                        radius: 30,
                      ),
                      title: Text(student.name),
                      subtitle: Text(
                        'Grade ${student.grade}-${student.section} - ${student.rollNumber}',
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                      ),
                      onTap: () => Navigator.pushNamed(
                        context,
                        StudentProfileScreen.routeName,
                        arguments: student.id,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
