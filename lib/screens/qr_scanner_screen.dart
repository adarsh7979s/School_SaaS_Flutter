import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import 'package:edu_id_saas/models/app_models.dart';
import 'package:edu_id_saas/providers/app_state.dart';
import 'package:edu_id_saas/widgets/app_shell.dart';
import 'package:edu_id_saas/widgets/empty_state_card.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  static const routeName = '/qr-scanner';

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _handledScan = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final records = state.schoolAttendance.take(8).toList(growable: false);

    return AppShell(
      title: 'QR Attendance',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (!state.canAccessScanning())
            const EmptyStateCard(
              title: 'Scanner unavailable',
              message:
                  'Only active-school security guards can use the scanner.',
              icon: Icons.no_accounts_outlined,
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                height: 280,
                child: MobileScanner(
                  controller: _controller,
                  onDetect: (capture) {
                    if (_handledScan) return;
                    final code = capture.barcodes.firstOrNull?.rawValue;
                    if (code == null || code.isEmpty) return;

                    _handledScan = true;
                    final message = context.read<AppState>().processQrValue(
                      code,
                    );
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(message)));

                    Future<void>.delayed(const Duration(seconds: 2), () {
                      if (mounted) _handledScan = false;
                    });
                  },
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (state.canAccessScanning())
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.tonal(
                  onPressed: () {
                    final student = state.visibleStudents.isEmpty
                        ? null
                        : state.visibleStudents.first;
                    if (student == null) return;
                    final message = state.processQrValue(student.qrValue);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(message)));
                  },
                  child: const Text('Demo Valid Scan'),
                ),
                FilledButton.tonal(
                  onPressed: () {
                    final message = state.processQrValue('INVALID|QR');
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(message)));
                  },
                  child: const Text('Demo Invalid Scan'),
                ),
                FilledButton.tonal(
                  onPressed: () {
                    final otherSchoolQr = state.currentSchool?.id == 'school_alpha'
                        ? 'EDU-ID|school_beta|s4'
                        : 'EDU-ID|school_alpha|s1';
                    final message = state.processQrValue(otherSchoolQr);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(message)));
                  },
                  child: const Text('Demo Wrong School'),
                ),
              ],
            ),
          const SizedBox(height: 20),
          Text(
            'Recent attendance',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (records.isEmpty)
            const EmptyStateCard(
              title: 'No scans yet',
              message:
                  'Attendance history will appear here once a QR is processed.',
            )
          else
            ...records.map((record) {
              final student = state.getStudentById(record.studentId);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: record.type == AttendanceType.entry
                          ? const Color(0xFFDBF5E5)
                          : const Color(0xFFFDE3DA),
                      child: Icon(
                        record.type == AttendanceType.entry
                            ? Icons.login_rounded
                            : Icons.logout_rounded,
                        color: record.type == AttendanceType.entry
                            ? const Color(0xFF1D8A52)
                            : const Color(0xFFBD5A2B),
                      ),
                    ),
                    title: Text(student?.name ?? 'Unknown Student'),
                    subtitle: Text(
                      '${state.describeAttendanceType(record.type)} - ${DateFormat('dd MMM, hh:mm a').format(record.timestamp)}',
                    ),
                    trailing: Text(record.scannedBy, textAlign: TextAlign.end),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
