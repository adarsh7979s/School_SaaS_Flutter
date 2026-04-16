import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:edu_id_saas/providers/app_state.dart';
import 'package:edu_id_saas/screens/student_profile_screen.dart';
import 'package:edu_id_saas/widgets/app_shell.dart';
import 'package:edu_id_saas/widgets/empty_state_card.dart';
import 'package:edu_id_saas/widgets/network_avatar.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  static const routeName = '/students';

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final allStudents = state.visibleStudents;
    final students = _searchQuery.isEmpty
        ? allStudents
        : allStudents
            .where((s) =>
                s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                s.rollNumber
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                s.grade.contains(_searchQuery))
            .toList();

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
          : Column(
              children: [
                // ── Search bar ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search by name, roll number, or grade…',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () =>
                                  setState(() => _searchQuery = ''),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Text(
                        '${students.length} student${students.length != 1 ? 's' : ''} found',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                // ── List ──
                Expanded(
                  child: students.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: EmptyStateCard(
                              title: 'No students found',
                              message:
                                  'Try adjusting your search query or check other schools.',
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: students.length,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
                                  title: Text(
                                    student.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    'Grade ${student.grade}-${student.section} • ${student.rollNumber}',
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
                ),
              ],
            ),
    );
  }
}
