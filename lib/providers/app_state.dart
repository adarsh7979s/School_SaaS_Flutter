import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:edu_id_saas/models/app_models.dart';
import 'package:edu_id_saas/services/mock_data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  AppState({MockDataService? dataService, bool hasCompletedOnboarding = false})
    : _dataService = dataService ?? const MockDataService(),
      _hasCompletedOnboarding = hasCompletedOnboarding {
    _schools = _dataService.getSchools();
    _users = _dataService.getUsers();
    _students = _dataService.getStudents();
    _attendance = _dataService.getSeedAttendance();
  }

  final MockDataService _dataService;
  late final List<School> _schools;
  late final List<AppUser> _users;
  late final List<Student> _students;
  late final List<AttendanceRecord> _attendance;

  AppUser? _currentUser;
  String? _selectedSchoolId;
  String? _scannerMessage;
  bool _isProcessingPayment = false;
  bool _hasCompletedOnboarding;

  AppUser? get currentUser => _currentUser;
  String? get scannerMessage => _scannerMessage;
  bool get isProcessingPayment => _isProcessingPayment;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  List<School> get schools => List.unmodifiable(_schools);

  School? get currentSchool {
    final schoolId = _selectedSchoolId ?? _currentUser?.schoolId;
    if (schoolId == null) return null;
    return _schools.where((school) => school.id == schoolId).firstOrNull;
  }

  List<AppUser> get loginOptions => List.unmodifiable(_users);

  List<Student> get visibleStudents {
    final schoolId = currentSchool?.id;
    if (schoolId == null) return List.unmodifiable(_students);
    return _students
        .where((student) => student.schoolId == schoolId)
        .toList(growable: false);
  }

  bool get isSubscriptionExpired => currentSchool?.isExpired ?? false;
  bool get isFeatureLocked => isSubscriptionExpired;

  bool canAccessScanning() {
    return _currentUser?.role == UserRole.securityGuard &&
        !isFeatureLocked;
  }

  bool canAccessStudents() {
    final role = _currentUser?.role;
    return role != null && role != UserRole.securityGuard;
  }

  bool canAccessStudentDirectory() {
    final role = _currentUser?.role;
    return (role == UserRole.superAdmin ||
            role == UserRole.schoolAdmin ||
            role == UserRole.teacher) &&
        !isFeatureLocked;
  }

  bool canAccessOwnStudentProfile() {
    return _currentUser?.role == UserRole.student &&
        currentStudent != null;
  }

  bool canAccessSubscription() {
    final role = _currentUser?.role;
    return role == UserRole.superAdmin || role == UserRole.schoolAdmin;
  }

  Student? get currentStudent {
    final studentId = _currentUser?.studentId;
    if (studentId == null) return null;
    return getStudentById(studentId);
  }

  void loginAs(AppUser user) {
    _currentUser = user;
    _selectedSchoolId = user.role == UserRole.superAdmin
        ? _schools.first.id
        : user.schoolId;
    _scannerMessage = null;
    notifyListeners();
  }

  Future<String?> authenticate(String email, String password) async {
    await Future<void>.delayed(const Duration(seconds: 1)); // Simulate network request
    for (final user in _users) {
      if (user.email == email && user.password == password) {
        loginAs(user);
        return null; // Success
      }
    }
    return 'Invalid email or password.';
  }

  void completeOnboarding() {
    if (_hasCompletedOnboarding) return;
    _hasCompletedOnboarding = true;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('has_completed_onboarding', true);
    });
  }

  void logout() {
    _currentUser = null;
    _selectedSchoolId = null;
    _scannerMessage = null;
    notifyListeners();
  }

  void switchSchool(String schoolId) {
    if (_currentUser?.role != UserRole.superAdmin) return;
    final schoolExists = _schools.any((school) => school.id == schoolId);
    if (!schoolExists) return;
    _selectedSchoolId = schoolId;
    _scannerMessage = null;
    notifyListeners();
  }

  Student? getStudentById(String id) {
    for (final student in _students) {
      if (student.id == id) return student;
    }
    return null;
  }

  bool canViewStudent(String studentId) {
    final user = _currentUser;
    if (user == null) return false;
    // Students can always view their own profile, even if subscription expired
    if (user.role == UserRole.student) return user.studentId == studentId;
    if (isFeatureLocked) return false;
    if (user.role == UserRole.securityGuard) return false;

    final student = getStudentById(studentId);
    if (student == null) return false;
    return student.schoolId == currentSchool?.id;
  }

  List<AttendanceRecord> getAttendanceForStudent(String studentId) {
    final records = _attendance
        .where((record) => record.studentId == studentId)
        .toList();
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  AttendanceRecord? latestAttendanceForStudent(String studentId) {
    final records = getAttendanceForStudent(studentId);
    return records.isEmpty ? null : records.first;
  }

  List<AttendanceRecord> get schoolAttendance {
    final studentIds = visibleStudents.map((student) => student.id).toSet();
    final records = _attendance
        .where((record) => studentIds.contains(record.studentId))
        .toList();
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  String processQrValue(String rawValue) {
    if (_currentUser == null) {
      _scannerMessage = 'Please log in first.';
      notifyListeners();
      return _scannerMessage!;
    }

    if (!canAccessScanning()) {
      _scannerMessage = isSubscriptionExpired
          ? 'Scanning is locked because the subscription has expired.'
          : 'Only security guards can scan QR codes.';
      notifyListeners();
      return _scannerMessage!;
    }

    final parts = rawValue.split('|');
    if (parts.length != 3 || parts.first != 'EDU-ID') {
      _scannerMessage =
          'Invalid QR code. Please scan a valid EDU-ID student pass.';
      notifyListeners();
      return _scannerMessage!;
    }

    final schoolId = parts[1];
    final studentId = parts[2];

    if (schoolId != currentSchool?.id) {
      _scannerMessage =
          'This QR belongs to another school and cannot be used here.';
      notifyListeners();
      return _scannerMessage!;
    }

    final student = getStudentById(studentId);
    if (student == null) {
      _scannerMessage = 'Student not found for this QR code.';
      notifyListeners();
      return _scannerMessage!;
    }

    if (student.schoolId != schoolId) {
      _scannerMessage =
          'QR data mismatch detected. This pass is not valid for the selected school.';
      notifyListeners();
      return _scannerMessage!;
    }

    final latestRecord = latestAttendanceForStudent(studentId);
    final now = DateTime.now();

    if (latestRecord != null &&
        now.difference(latestRecord.timestamp).inSeconds < 30) {
      _scannerMessage =
          'Duplicate scan blocked for ${student.name}. Please wait before rescanning.';
      notifyListeners();
      return _scannerMessage!;
    }

    final nextType =
        latestRecord == null || latestRecord.type == AttendanceType.exit
        ? AttendanceType.entry
        : AttendanceType.exit;

    _attendance.add(
      AttendanceRecord(
        studentId: studentId,
        type: nextType,
        timestamp: now,
        scannedBy: _currentUser!.name,
      ),
    );

    _scannerMessage =
        '${student.name} marked ${describeAttendanceType(nextType)} successfully.';
    notifyListeners();
    return _scannerMessage!;
  }

  Future<PaymentResult> simulatePayment() async {
    final user = _currentUser;
    if (user == null || !canAccessSubscription()) {
      return const PaymentResult(
        success: false,
        message: 'Only super admins and school admins can manage payments.',
      );
    }

    final school = currentSchool;
    if (school == null) {
      return const PaymentResult(
        success: false,
        message: 'No school selected.',
      );
    }

    _isProcessingPayment = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(seconds: 2));

    final success = Random().nextBool();
    final index = _schools.indexWhere((item) => item.id == school.id);

    if (index == -1) {
      _isProcessingPayment = false;
      notifyListeners();
      return const PaymentResult(
        success: false,
        message: 'Selected school no longer exists.',
      );
    }

    if (success) {
      _schools[index] = School(
        id: school.id,
        name: school.name,
        logoUrl: school.logoUrl,
        planName: 'Enterprise Plus',
        subscriptionStatus: SubscriptionStatus.active,
        subscriptionEndsOn: DateTime.now().add(const Duration(days: 365)),
      );
    }

    _isProcessingPayment = false;
    notifyListeners();

    return PaymentResult(
      success: success,
      message: success
          ? 'Payment successful. Subscription upgraded for the next 12 months.'
          : 'Payment failed. Please try again with another method.',
    );
  }

  String describeRole(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.schoolAdmin:
        return 'School Admin';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.student:
        return 'Student';
      case UserRole.securityGuard:
        return 'Security Guard';
    }
  }

  String describeAttendanceType(AttendanceType type) {
    switch (type) {
      case AttendanceType.entry:
        return 'Entry';
      case AttendanceType.exit:
        return 'Exit';
    }
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
