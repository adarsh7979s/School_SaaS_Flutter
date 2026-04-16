enum UserRole { superAdmin, schoolAdmin, teacher, student, securityGuard }

enum SubscriptionStatus { active, expired }

enum AttendanceType { entry, exit }

class School {
  const School({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.planName,
    required this.subscriptionStatus,
    required this.subscriptionEndsOn,
  });

  final String id;
  final String name;
  final String logoUrl;
  final String planName;
  final SubscriptionStatus subscriptionStatus;
  final DateTime subscriptionEndsOn;

  bool get isExpired => subscriptionStatus == SubscriptionStatus.expired;
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    required this.schoolId,
    required this.email,
    required this.password,
    this.studentId,
  });

  final String id;
  final String name;
  final UserRole role;
  final String schoolId;
  final String email;
  final String password;
  final String? studentId;
}

class Student {
  const Student({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.grade,
    required this.section,
    required this.rollNumber,
    required this.routeName,
    required this.guardianName,
    required this.imageUrl,
    required this.qrValue,
  });

  final String id;
  final String schoolId;
  final String name;
  final String grade;
  final String section;
  final String rollNumber;
  final String routeName;
  final String guardianName;
  final String imageUrl;
  final String qrValue;
}

class AttendanceRecord {
  const AttendanceRecord({
    required this.studentId,
    required this.type,
    required this.timestamp,
    required this.scannedBy,
  });

  final String studentId;
  final AttendanceType type;
  final DateTime timestamp;
  final String scannedBy;
}

class PaymentResult {
  const PaymentResult({required this.success, required this.message});

  final bool success;
  final String message;
}
