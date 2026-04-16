# EDU-ID SaaS

A Flutter assignment app for a multi-school digital ID card and QR attendance system.

## Setup

1. Install Flutter `3.32+`.
2. Run `flutter pub get`.
3. Run `flutter run`.

## Packages Used

- `provider` for app-wide state management
- `cached_network_image` for CDN/S3-style image loading with caching and fallbacks
- `mobile_scanner` for QR scanning
- `qr_flutter` for digital ID QR generation
- `intl` for attendance and subscription date formatting

## Implemented Scope

- Role-based login and dashboard flow
- Multi-school mock data separation
- Student list and student profile
- Digital ID card with school logo, student photo, and QR code
- QR attendance with entry/exit toggling and duplicate scan prevention
- Attendance history
- Subscription status, app locking, and simulated payment success/failure
- Remote image loading, loading indicators, caching, and broken URL fallback
- Empty states and invalid QR handling

## Assumptions

- Mock users are used instead of real authentication.
- Multi-school data is filtered locally using school IDs.
- QR payload format is `EDU-ID|schoolId|studentId`.
- Duplicate scans are blocked if repeated within 30 seconds.
- Subscription lock disables feature access for expired schools until simulated payment succeeds.

## Demo Notes

- `Security Guard` can scan QR codes.
- `Student` can view only and cannot scan.
- `Super Admin` can switch between schools from the dashboard.
- `Sunrise Public Academy` starts in an expired state to demonstrate app locking and upgrade flow.
- One demo student intentionally uses a broken image URL to show fallback behavior.

## Suggested Screenshots

- Login roles
- Role-based dashboard
- Student list and profile
- Digital ID card
- QR scanner with attendance history
- Subscription expired and upgraded states
