# EDU-ID SaaS — Multi-School ID Card + QR Attendance System

A production-ready Multi-School SaaS Mobile Application built with Flutter. Supports digital ID card viewing, QR-based attendance tracking, role-based access control, subscription management, and cloud asset handling.

---

## Setup Steps

1. **Prerequisites:** Flutter SDK `^3.x.x` installed and configured
2. Clone or extract this repository:
   ```bash
   git clone <repo-url>
   cd FlutterInternship2
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

> **Note:** QR scanning requires a real device camera. On emulators, use the built-in "Demo Valid Scan" / "Demo Invalid Scan" buttons on the QR Scanner screen.

---

## Packages Used

| Package | Version | Purpose |
|---------|---------|---------|
| `provider` | ^6.1.5 | Centralized state management via `ChangeNotifier` |
| `cached_network_image` | ^3.4.1 | CDN image loading with disk caching, loading placeholders, and error fallbacks |
| `mobile_scanner` | ^7.0.1 | High-performance camera-based QR code scanning |
| `qr_flutter` | ^4.1.0 | QR code generation for digital ID cards |
| `intl` | ^0.20.2 | Date/time formatting and localization |
| `lottie` | ^3.3.1 | Rich micro-animations for onboarding flow |
| `shared_preferences` | ^2.2.3 | Persistent key-value storage (onboarding completion flag) |
| `flutter_launcher_icons` | ^0.13.1 | Custom app icon generation (dev dependency) |

---

## Architecture

```
lib/
├── main.dart              # App entry point, routing, theme configuration
├── models/
│   └── app_models.dart    # Domain models: School, AppUser, Student, AttendanceRecord
├── providers/
│   └── app_state.dart     # Central state management (ChangeNotifier)
├── services/
│   └── mock_data_service.dart  # Mock backend data layer
├── screens/
│   ├── onboarding_screen.dart  # First-time user onboarding
│   ├── login_screen.dart       # Email/password auth + quick role selection
│   ├── dashboard_screen.dart   # Role-specific dashboard with stats
│   ├── student_list_screen.dart    # Searchable student directory
│   ├── student_profile_screen.dart # Student details + attendance history
│   ├── id_card_screen.dart     # Digital ID card with QR code
│   ├── qr_scanner_screen.dart  # Camera QR scanner + attendance log
│   └── subscription_screen.dart    # Plan status + payment simulation
└── widgets/
    ├── app_shell.dart         # Reusable Scaffold wrapper
    ├── empty_state_card.dart  # Zero-data placeholder component
    └── network_avatar.dart    # CachedNetworkImage avatar with fallback
```

### App Flow
```
Onboarding → Login → Dashboard → Student List → Student Profile → ID Card
                                → QR Scanner → Attendance History
                                → Subscription → Payment Flow
```

---

## Feature Coverage (All 18 Tasks)

### Section 1 — App Setup
- ✅ Flutter project with clean folder structure (models, providers, services, screens, widgets)
- ✅ Complete navigation system with named routes and smooth iOS-style page transitions

### Section 2 — Auth & Role System
- ✅ Five roles: Super Admin, School Admin, Teacher, Student, Security Guard
- ✅ Email/password authentication with form validation
- ✅ Quick-login panel with role-specific icons and colors for easy evaluation
- ✅ Different dashboard layout per role (switch-based routing)

### Section 3 — User & Student Module
- ✅ Student list with real-time search (by name, roll number, or grade)
- ✅ Student profile with CDN-loaded image, details, guardian info, and attendance history

### Section 4 — ID Card Module
- ✅ Digital ID card with gradient design, student photo, school logo, and scannable QR code

### Section 5 — QR Attendance System
- ✅ Camera-based QR scanning via `mobile_scanner`
- ✅ Automatic entry/exit toggling logic
- ✅ 30-second duplicate scan prevention
- ✅ Demo buttons for testing without a camera (valid, invalid, wrong-school QR)

### Section 6 — Workflow & Validation
- ✅ Attendance states: Entry / Exit with timestamped history
- ✅ Role-based access control enforced throughout the app
  - Security Guard → Can scan QR codes
  - Student → Can view own profile and ID card only
  - Admin/Teacher → Can browse student directory
  - Only Admin roles → Can manage subscriptions

### Section 7 — Subscription Module
- ✅ Subscription status card with gradient styling (green=active, red=expired)
- ✅ Plan details, features checklist, and validity date
- ✅ Simulated payment flow with 2-second processing delay
- ✅ Random success/failure outcome with rich SnackBar feedback
- ✅ On success: subscription upgraded for 12 months, features unlocked

### Section 8 — Cloud Asset Handling
- ✅ All images loaded from Unsplash CDN URLs
- ✅ Loading state: circular progress indicator placeholder
- ✅ Error fallback: initials-based avatar for broken URLs

### Section 9 — Performance & Optimization
- ✅ `CachedNetworkImage` for disk-level image caching
- ✅ `ListView.builder` for lazy list rendering
- ✅ `NeverScrollableScrollPhysics` for nested scroll optimization
- ✅ Cupertino page transitions for smooth navigation feel

### Section 10 — Advanced Logic
- ✅ Multi-school handling: 2 schools with data separation, Super Admin school switcher
- ✅ Edge case handling:
  - Invalid QR format → error message
  - Broken image URL → fallback avatar (student "Broken Asset Demo")
  - Empty states → dedicated `EmptyStateCard` widget
- ✅ App locking: Expired subscription (Sunrise Public Academy) disables features with lock icons and upgrade prompts

---

## Assumptions & Design Choices

- **Authentication:** Mock-based authentication simulating real SaaS infrastructure. Evaluators can use the quick-login panel to instantly switch between all 5 roles without typing credentials.
- **Backend:** As the assignment specifies backend is optional, `MockDataService` emulates a cloud database with in-memory data structures. All data relationships (schools → users → students → attendance) are properly modeled.
- **Multi-tenancy:** Two demo schools demonstrate data isolation. "Green Valley High School" has an active subscription while "Sunrise Public Academy" is expired to showcase the app-locking feature.
- **Onboarding persistence:** Uses `shared_preferences` to show the onboarding screen only once per installation.
- **QR format:** Uses a structured payload format: `EDU-ID|<schoolId>|<studentId>` for reliable parsing and validation.

---

## Testing the App

### Quick Start
1. Launch the app → complete onboarding (shown only once)
2. On the login screen, tap any user from the "Quick Login" list
3. Explore the dashboard, student list, ID cards, QR scanner, and subscription

### Key Test Scenarios
| Scenario | How to Test |
|----------|-------------|
| Role-based dashboard | Login as each of the 5 roles — different actions appear |
| QR attendance | Login as "Vikram Yadav" (Security Guard) → QR Scanner → tap "Demo Valid Scan" |
| Duplicate scan block | Tap "Demo Valid Scan" twice within 30 seconds |
| Invalid QR | Tap "Demo Invalid Scan" |
| Wrong school QR | Tap "Demo Wrong School" |
| Broken image | Login as School Admin for Sunrise Academy → browse students → see "Broken Asset Demo" |
| App locking | Login as "Nisha Kapoor" (School Admin, Sunrise Academy) → features are locked |
| Payment flow | Go to Subscription → tap "Simulate Payment" (randomly succeeds or fails) |
| Multi-school | Login as Super Admin → use school dropdown to switch between schools |
| Student search | Login as Admin/Teacher → Students → type in search bar |

---

## Build

Pre-built APK is available in:
```
dist_apk/EduID_SaaS_v1.0.apk
```
