import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:edu_id_saas/providers/app_state.dart';
import 'package:edu_id_saas/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const routeName = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      animationPath: 'lib/lottie/Student transparent.json',
      title: 'Digital Student Identity',
      description:
          'View secure digital ID cards with student photo, school branding, and QR verification in one place.',
    ),
    _OnboardingPageData(
      animationPath: 'lib/lottie/campus library school building office mocca animation.json',
      title: 'School-Wise SaaS Management',
      description:
          'Handle multiple schools with role-based access, school filtering, and subscription-aware dashboards.',
    ),
    _OnboardingPageData(
      animationPath: 'lib/lottie/SaaS Meeting.json',
      title: 'Smart QR Attendance',
      description:
          'Let security teams scan entry and exit passes quickly while preventing duplicate or invalid attendance events.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7FBFF), Color(0xFFEAF4FB), Color(0xFFDCEFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'EDU-ID',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F4C81),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _goToLogin,
                      child: const Text('Skip'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (value) {
                      setState(() {
                        _currentPage = value;
                      });
                    },
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return Column(
                        children: [
                          Expanded(
                            flex: 6,
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(top: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.86),
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x140F4C81),
                                    blurRadius: 24,
                                    offset: Offset(0, 14),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Lottie.asset(
                                  page.animationPath,
                                  fit: BoxFit.contain,
                                  repeat: true,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF123C63),
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            page.description,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: const Color(0xFF48637A),
                                  height: 1.45,
                                ),
                          ),
                          const Spacer(),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 10,
                      width: _currentPage == index ? 28 : 10,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? const Color(0xFF0F4C81)
                            : const Color(0xFFBFD0DF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _currentPage == 0
                            ? null
                            : () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 280),
                                  curve: Curves.easeOut,
                                );
                              },
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: isLastPage
                            ? _goToLogin
                            : () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 280),
                                  curve: Curves.easeOut,
                                );
                              },
                        child: Text(isLastPage ? 'Get Started' : 'Next'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goToLogin() {
    context.read<AppState>().completeOnboarding();
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.animationPath,
    required this.title,
    required this.description,
  });

  final String animationPath;
  final String title;
  final String description;
}
