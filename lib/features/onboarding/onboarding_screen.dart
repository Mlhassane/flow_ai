import 'package:flutter/material.dart';
import 'package:flow/core/theme.dart';
import 'package:flow/models/user.dart';
import 'package:flow/services/storage_service.dart';
import 'package:flow/features/main_navigation_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flow/services/device_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final StorageService _storageService = StorageService();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  String _selectedLevel = 'Terminale';
  String _selectedCountry = 'ML';
  String _selectedExamType = 'BAC';
  String _selectedSeries = '';
  int _currentPage = 0;

  final Map<String, String> _countries = {
    'ML': 'Mali 🇲🇱',
    'BF': 'Burkina Faso 🇧🇫',
    'NE': 'Niger 🇳🇪',
  };

  final List<String> _levels = [
    '6ème',
    '5ème',
    '4ème',
    '3ème',
    'Seconde',
    'Première',
    'Terminale',
    'Université',
  ];

  final Map<String, List<String>> _seriesByCountry = {
    'ML': ['TSE', 'TSExp', 'TLL', 'TAL', 'TSECO'],
    'BF': ['A4', 'D', 'C', 'E'],
    'NE': ['A', 'D', 'C', 'E'],
  };

  final List<OnboardingInfo> _introSteps = [
    OnboardingInfo(
      title: 'Scan Tes Cours',
      description:
          'Prends en photo tes notes, tes fiches ou tes manuels. Notre IA analyse tout instantanément.',
      icon: Icons.document_scanner_outlined,
      color: const Color(0xFF6366F1),
    ),
    OnboardingInfo(
      title: 'Génération IA',
      description:
          'L\'IA transforme tes documents en quiz interactifs et percutants sur mesure.',
      icon: Icons.psychology_outlined,
      color: const Color(0xFFFACC15),
    ),
  ];

  void _nextPage() {
    if (_currentPage < 7) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    if (_firstNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('S\'il te plaît, entre ton prénom')),
      );
      return;
    }

    // Récupération de l'ID unique du téléphone
    final deviceService = DeviceService();
    final uniqueId = await deviceService.getUniqueId();

    final newUser = User(
      id: uniqueId,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      level: _selectedLevel,
      country: _selectedCountry,
      examType: _selectedExamType,
      series: _selectedSeries,
      avatarUrl: '',
      coins: 500,
      streak: 0,
      totalFlashcards: 0,
      totalQuizzes: 0,
      badges: ['new_member'],
      subjectProgress: {},
    );

    await _storageService.saveUser(newUser);
    await _storageService.setOnboardingComplete(true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Elements
          Positioned(
            top: -150,
            right: -150,
            child: _buildBlurCircle(
              AppTheme.primaryColor.withValues(alpha: 0.05),
              400,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildLogoStep(),
                      _buildIntroStep(_introSteps[0]),
                      _buildIntroStep(_introSteps[1]),
                      _buildNameStep(),
                      _buildCountryStep(),
                      _buildLevelStep(),
                      _buildSeriesStep(),
                      _buildWelcomeStep(),
                    ],
                  ),
                ),
                _buildBottomBar(),
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
    ).animate().fadeIn(duration: 1.seconds);
  }

  Widget _buildLogoStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.asset(
              'assets/images/logo_minimalist.png',
              fit: BoxFit.cover,
            ),
          ),
        ).animate().scale(duration: 800.ms, curve: Curves.ease).fadeIn(),
        const SizedBox(height: 48),
        const Text(
          'FLOW',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            color: AppTheme.primaryColor,
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.5, end: 0),
        const SizedBox(height: 12),
        Text(
          'Ton intelligence éducative',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
        ).animate().fadeIn(delay: 600.ms),
      ],
    );
  }

  Widget _buildIntroStep(OnboardingInfo info) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            info.icon,
            size: 100,
            color: info.color,
          ).animate().scale().fadeIn(),
          const SizedBox(height: 40),
          Text(
            info.title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            info.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNameStep() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Faisons connaissance ! 👋',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ).animate().fadeIn().slideX(),
          const SizedBox(height: 12),
          Text(
            'Comment devrais-je t\'appeler ?',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 48),
          TextField(
            controller: _firstNameController,
            decoration: InputDecoration(
              hintText: 'Ton prénom',
              filled: true,
              fillColor: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
          TextField(
            controller: _lastNameController,
            decoration: InputDecoration(
              hintText: 'Ton nom (optionnel)',
              filled: true,
              fillColor: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildCountryStep() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ton pays ? 🌍',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Pour adapter le contenu à ton programme national.',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          ..._countries.entries.map((entry) {
            final isSelected = _selectedCountry == entry.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => setState(() => _selectedCountry = entry.key),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: isSelected ? FontWeight.bold : null,
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: Colors.white),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLevelStep() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ton niveau ? 🎓',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Cela m\'aidera à adapter mes explications IA.',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _levels.length,
              itemBuilder: (context, index) {
                final level = _levels[index];
                final isSelected = _selectedLevel == level;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedLevel = level;
                      // Logique automatique pour l'examen
                      if (level == '3ème') {
                        _selectedExamType = (_selectedCountry == 'ML') ? 'DEF' : 'BEPC';
                      } else if (['Seconde', 'Première', 'Terminale'].contains(level)) {
                        _selectedExamType = 'BAC';
                      } else {
                        _selectedExamType = 'AUTRE';
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      level,
                      style: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontWeight: isSelected ? FontWeight.bold : null,
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

  Widget _buildSeriesStep() {
    final series = _seriesByCountry[_selectedCountry] ?? [];
    final isLycee = ['Seconde', 'Première', 'Terminale'].contains(_selectedLevel);

    if (!isLycee) {
        return Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    const Icon(Icons.info_outline, size: 64, color: AppTheme.primaryColor),
                    const SizedBox(height: 16),
                    const Text('Série non applicable', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Tu es en $_selectedLevel.', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 32),
                    const Text('Clique sur Continuer', style: TextStyle(fontStyle: FontStyle.italic)),
                ],
            ),
        );
    }

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ta série ? 📚',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Plus précis pour les matières du Bac.',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: series.length,
              itemBuilder: (context, index) {
                final s = series[index];
                final isSelected = _selectedSeries == s;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSeries = s),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      s,
                      style: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontWeight: isSelected ? FontWeight.bold : null,
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

  Widget _buildWelcomeStep() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.rocket_launch_rounded,
              size: 80,
              color: AppTheme.primaryColor,
            ),
          ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),
          const SizedBox(height: 32),
          Text(
            'Prêt pour l\'aventure, ${_firstNameController.text} !',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Je suis ton nouveau tuteur IA Flow. Réussissons tes examens ensemble.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(8, (index) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppTheme.primaryColor
                      : Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              elevation: 0,
            ),
            child: Text(
              _currentPage == 7 ? 'Explorer Flow' : 'Continuer',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingInfo {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
