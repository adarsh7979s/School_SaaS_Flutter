import 'package:edu_id_saas/models/app_models.dart';

class MockDataService {
  const MockDataService();

  List<School> getSchools() {
    return [
      School(
        id: 'school_alpha',
        name: 'Green Valley High School',
        logoUrl:
            'https://picsum.photos/seed/school_alpha/200',
        planName: 'Enterprise Plus',
        subscriptionStatus: SubscriptionStatus.active,
        subscriptionEndsOn: DateTime(2026, 12, 31),
      ),
      School(
        id: 'school_beta',
        name: 'Sunrise Public Academy',
        logoUrl:
            'https://picsum.photos/seed/school_beta/200',
        planName: 'Starter',
        subscriptionStatus: SubscriptionStatus.expired,
        subscriptionEndsOn: DateTime(2026, 3, 15),
      ),
    ];
  }

  List<AppUser> getUsers() {
    return const [
      AppUser(
        id: 'u1',
        name: 'Aanya Sharma',
        role: UserRole.superAdmin,
        schoolId: 'school_alpha',
        email: 'superadmin@eduid.com',
        password: 'password123',
      ),
      AppUser(
        id: 'u2',
        name: 'Rahul Mehta',
        role: UserRole.schoolAdmin,
        schoolId: 'school_alpha',
        email: 'admin.greenvalley@eduid.com',
        password: 'password123',
      ),
      AppUser(
        id: 'u3',
        name: 'Meera Iyer',
        role: UserRole.teacher,
        schoolId: 'school_alpha',
        email: 'teacher.greenvalley@eduid.com',
        password: 'password123',
      ),
      AppUser(
        id: 'u4',
        name: 'Arjun Patel',
        role: UserRole.student,
        schoolId: 'school_alpha',
        studentId: 's1',
        email: 'arjun@greenvalley.edu',
        password: 'password123',
      ),
      AppUser(
        id: 'u5',
        name: 'Vikram Yadav',
        role: UserRole.securityGuard,
        schoolId: 'school_alpha',
        email: 'security.greenvalley@eduid.com',
        password: 'password123',
      ),
      AppUser(
        id: 'u6',
        name: 'Nisha Kapoor',
        role: UserRole.schoolAdmin,
        schoolId: 'school_beta',
        email: 'admin.sunrise@eduid.com',
        password: 'password123',
      ),
      AppUser(
        id: 'u7',
        name: 'Kabir Singh',
        role: UserRole.student,
        schoolId: 'school_beta',
        studentId: 's5',
        email: 'kabir@sunrise.edu',
        password: 'password123',
      ),
      AppUser(
        id: 'u8',
        name: 'Rohan Das',
        role: UserRole.securityGuard,
        schoolId: 'school_beta',
        email: 'security.sunrise@eduid.com',
        password: 'password123',
      ),
    ];
  }

  List<Student> getStudents() {
    return const [
      Student(
        id: 's1',
        schoolId: 'school_alpha',
        name: 'Arjun Patel',
        grade: '10',
        section: 'A',
        rollNumber: 'GVH-1021',
        routeName: 'Route 5',
        guardianName: 'Kiran Patel',
        imageUrl:
            'https://picsum.photos/seed/arjun/400',
        qrValue: 'EDU-ID|school_alpha|s1',
      ),
      Student(
        id: 's2',
        schoolId: 'school_alpha',
        name: 'Sara Nair',
        grade: '9',
        section: 'B',
        rollNumber: 'GVH-0955',
        routeName: 'Route 1',
        guardianName: 'Anita Nair',
        imageUrl:
            'https://picsum.photos/seed/sara/400',
        qrValue: 'EDU-ID|school_alpha|s2',
      ),
      Student(
        id: 's3',
        schoolId: 'school_alpha',
        name: 'Vihaan Roy',
        grade: '8',
        section: 'C',
        rollNumber: 'GVH-0830',
        routeName: 'Route 3',
        guardianName: 'Sonia Roy',
        imageUrl:
            'https://picsum.photos/seed/vihaan/400',
        qrValue: 'EDU-ID|school_alpha|s3',
      ),
      Student(
        id: 's4',
        schoolId: 'school_beta',
        name: 'Ishita Verma',
        grade: '7',
        section: 'A',
        rollNumber: 'SPA-0712',
        routeName: 'Route 2',
        guardianName: 'Raj Verma',
        imageUrl:
            'https://picsum.photos/seed/ishita/400',
        qrValue: 'EDU-ID|school_beta|s4',
      ),
      Student(
        id: 's5',
        schoolId: 'school_beta',
        name: 'Kabir Singh',
        grade: '11',
        section: 'D',
        rollNumber: 'SPA-1140',
        routeName: 'Route 8',
        guardianName: 'Ritu Singh',
        imageUrl:
            'https://picsum.photos/seed/kabir/400',
        qrValue: 'EDU-ID|school_beta|s5',
      ),
      Student(
        id: 's6',
        schoolId: 'school_beta',
        name: 'Broken Asset Demo',
        grade: '6',
        section: 'C',
        rollNumber: 'SPA-0603',
        routeName: 'Route 4',
        guardianName: 'Fallback Parent',
        imageUrl: 'https://cdn.invalid-domain.example/missing-student.png',
        qrValue: 'EDU-ID|school_beta|s6',
      ),
    ];
  }

  List<AttendanceRecord> getSeedAttendance() {
    return [
      AttendanceRecord(
        studentId: 's1',
        type: AttendanceType.entry,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        scannedBy: 'Vikram Yadav',
      ),
      AttendanceRecord(
        studentId: 's2',
        type: AttendanceType.entry,
        timestamp: DateTime.now().subtract(
          const Duration(hours: 3, minutes: 40),
        ),
        scannedBy: 'Vikram Yadav',
      ),
    ];
  }
}
