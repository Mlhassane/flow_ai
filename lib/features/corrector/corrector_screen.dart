import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flow/core/theme.dart';
import 'package:flow/models/correction.dart';
import 'package:flow/services/corrector_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flow/widgets/cauri_icon.dart';
import 'package:flow/models/user.dart';

class CorrectorScreen extends StatefulWidget {
  const CorrectorScreen({super.key});

  @override
  State<CorrectorScreen> createState() => _CorrectorScreenState();
}

class _CorrectorScreenState extends State<CorrectorScreen> {
  final CorrectorService _correctorService = CorrectorService();
  final ImagePicker _picker = ImagePicker();
  final User _currentUser = User.mock();

  File? _selectedImage;
  CorrectionResult? _result;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _result = null;
      });
      _processImage();
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    setState(() => _isLoading = true);

    try {
      final result = await _correctorService.correctExam(
        _selectedImage!,
        userLevel: _currentUser.level,
      );
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Correcteur IA',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background decoration
          Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor.withOpacity(0.05),
                  ),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: 0, end: 50, duration: 4.seconds),

          _isLoading
              ? _buildLoadingView()
              : (_result == null ? _buildInitialView() : _buildResultView()),
        ],
      ),
    );
  }

  Widget _buildInitialView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fact_check_rounded,
                size: 80,
                color: AppTheme.primaryColor,
              ),
            ).animate().scale(curve: Curves.easeOutBack, duration: 600.ms),
            const SizedBox(height: 32),
            const Text(
              'Analyse ton épreuve',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Prends en photo ton sujet d\'examen. L\'IA va le corriger et t\'expliquer les points clés.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            _buildActionButton(
              icon: Icons.camera_alt_rounded,
              label: 'Prendre une photo',
              onTap: () => _pickImage(ImageSource.camera),
              isPrimary: true,
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              icon: Icons.photo_library_rounded,
              label: 'Choisir dans la galerie',
              onTap: () => _pickImage(ImageSource.gallery),
              isPrimary: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.primaryColor),
          const SizedBox(height: 24),
          const Text(
            'L\'IA analyse ton épreuve...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
          const SizedBox(height: 8),
          const Text(
            'Cela peut prendre quelques secondes',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    if (_result != null && !_result!.isExam) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 60,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            const Text(
              'Ce n\'est pas une épreuve !',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            _buildActionButton(
              icon: Icons.refresh_rounded,
              label: 'Essayer une autre image',
              onTap: () => setState(() => _result = null),
              isPrimary: true,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.category_rounded,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  _result!.subject.toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideX(begin: -0.2, end: 0),
          const SizedBox(height: 20),
          _buildResultCard(
            title: 'Correction de ton Prof IA',
            icon: Icons.school_rounded,
            content: _result!.structuredCorrection,
            color: Colors.blue,
            isBlackboard: true,
          ),
          const SizedBox(height: 20),
          _buildResultCard(
            title: 'Le mot du Prof',
            icon: Icons.lightbulb_rounded,
            content: _result!.pedagogicalAdvice,
            color: Colors.amber,
          ),
          const SizedBox(height: 24),
          const Text(
            'POUR T\'ENTRAÎNER (LOGIQUE SIMILAIRE)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.grey,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          ..._result!.similarExercises
              .map((exo) => _buildExerciseCard(exo))
              .toList(),
          const SizedBox(height: 40),
          _buildActionButton(
            icon: Icons.refresh_rounded,
            label: 'Nouvelle photo au tableau',
            onTap: () => setState(() => _result = null),
            isPrimary: false,
          ),
          const SizedBox(height: 100), // Spacing for bottom nav
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildResultCard({
    required String title,
    required IconData icon,
    required String content,
    required Color color,
    bool isBlackboard = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isBlackboard
            ? (Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade900
                  : Colors.white)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: isBlackboard
            ? Border.all(color: color.withOpacity(0.3), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              fontFamily: isBlackboard ? 'monospace' : null,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: CauriIcon(size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(content, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppTheme.primaryColor
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: isPrimary
              ? null
              : Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isPrimary
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
