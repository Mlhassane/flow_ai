import 'package:flutter/material.dart';
import 'package:flow/features/main_navigation_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: 'Scan Tes Cours',
      description:
          'Prends en photo tes notes, tes fiches ou tes manuels. Notre IA analyse tout instantanément.',
      icon: Icons.document_scanner_outlined,
      color: const Color(0xFF6366F1), // Primary
    ),
    OnboardingStep(
      title: 'Génération IA',
      description:
          'L\'intelligence artificielle transforme tes documents en quiz interactifs et percutants.',
      icon: Icons.psychology_outlined,
      color: const Color(0xFFFACC15), // Secondary
    ),
    OnboardingStep(
      title: 'Maîtrise Tout',
      description:
          'Révise efficacement avec des flashcards générées sur mesure pour toi.',
      icon: Icons.school_outlined,
      color: const Color(0xFF4ADE80), // Green-ish
    ),
  ];

  void _onNext() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_run', false);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Elegant Background Elements
          Positioned(
            top: -150,
            right: -150,
            child: _buildBlurCircle(
              _steps[_currentPage].color.withOpacity(isDark ? 0.2 : 0.1),
              400,
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: _buildBlurCircle(
              _steps[_currentPage].color.withOpacity(isDark ? 0.15 : 0.05),
              350,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Premium Progress Indicator
                _buildProgressIndicator(),

                const Spacer(flex: 2),

                // Main Content with PageView
                SizedBox(
                  height: 480,
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _steps.length,
                    itemBuilder: (context, index) {
                      final step = _steps[index];
                      return _buildPageContent(step);
                    },
                  ),
                ),

                const Spacer(flex: 3),

                // Bottom Action Area
                _buildBottomActions(isDark),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurCircle(Color color, double size) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        )
        .animate(target: _currentPage.toDouble())
        .tint(color: color, duration: 600.ms)
        .blur(begin: const Offset(80, 80), end: const Offset(100, 100));
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: List.generate(_steps.length, (index) {
          final isActive = index <= _currentPage;
          return Expanded(
            child: AnimatedContainer(
              duration: 400.ms,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 4,
              decoration: BoxDecoration(
                color: isActive
                    ? _steps[index].color
                    : Theme.of(context).dividerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPageContent(OnboardingStep step) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main Iconic Element
          Container(
                height: 220,
                width: 220,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: step.color.withOpacity(0.15),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                  border: Border.all(
                    color: step.color.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(step.icon, size: 90, color: step.color)
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .moveY(
                          begin: -5,
                          end: 5,
                          duration: 2.seconds,
                          curve: Curves.easeInOut,
                        ),

                    // Decorative particle
                    Positioned(
                      top: 40,
                      right: 40,
                      child:
                          Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: step.color.withOpacity(0.4),
                                  shape: BoxShape.circle,
                                ),
                              )
                              .animate(onPlay: (c) => c.repeat())
                              .scale(
                                duration: 1.5.seconds,
                                curve: Curves.easeInOut,
                              ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8)),

          const SizedBox(height: 50),

          Text(
            step.title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 20),

          Text(
            step.description,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: 16,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildBottomActions(bool isDark) {
    final step = _steps[_currentPage];
    final isLast = _currentPage == _steps.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: _onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLast
                        ? step.color
                        : Theme.of(context).colorScheme.onSurface,
                    foregroundColor: isLast
                        ? Colors.white
                        : Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isLast ? 'COMMENCER' : 'SUIVANT',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              )
              .animate(target: isLast ? 1 : 0)
              .shimmer(delay: 1.seconds, duration: 2.seconds),

          const SizedBox(height: 16),

          if (!isLast)
            TextButton(
              onPressed: _finishOnboarding,
              child: Text(
                'Passer',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.4),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }
}

class OnboardingStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
