import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flow/core/theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';
import 'package:flow/services/ai_service.dart';
import 'package:flow/features/quiz/quiz_screen.dart';
import 'package:flow/models/quiz_deck.dart';
import 'package:flow/services/storage_service.dart';
import 'package:flow/models/user.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  double _numQuestions = 5.0;
  final TextEditingController _titleController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
          // Nom par défaut basé sur la date
          _titleController.text =
              "Deck du ${DateTime.now().day}/${DateTime.now().month}";
        });
      }
    } catch (e) {
      _showError('Erreur lors de l\'accès à la caméra');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
          _titleController.text =
              "Deck du ${DateTime.now().day}/${DateTime.now().month}";
        });
      }
    } catch (e) {
      _showError('Erreur lors de l\'accès à la galerie');
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;
    if (_titleController.text.trim().isEmpty) {
      _showError('Donne un titre à ton deck');
      return;
    }

    setState(() => _isProcessing = true);

    final aiService = AIService();
    final storageService = StorageService();
    final user = User.mock();

    try {
      // 1. Génération par l'IA avec le nombre de questions choisi
      final quizCards = await aiService.generateQuizFromImage(
        File(_selectedImage!.path),
        numQuestions: _numQuestions.toInt(),
        userLevel: user.level,
      );

      if (mounted) {
        // 2. Création et Sauvegarde du Deck
        final newDeck = QuizDeck(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          createdAt: DateTime.now(),
          cards: quizCards,
        );

        await storageService.saveDeck(newDeck);

        setState(() => _isProcessing = false);
        _showSuccess();

        // 3. Navigation vers le Quiz
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(quizCards: quizCards),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _showError('Erreur lors de la génération : $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Fiche enregistrée avec succès !'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() {
      _selectedImage = null;
      _titleController.clear();
    });
  }

  void _clearImage() {
    setState(() => _selectedImage = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Subtle Dynamic Background
          Positioned.fill(
                child: Opacity(
                  opacity: 0.3,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-0.8, -0.6),
                        radius: 1.2,
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveY(
                begin: -10,
                end: 10,
                duration: 6.seconds,
                curve: Curves.easeInOut,
              ),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        if (_selectedImage != null)
                          _buildImagePreview()
                        else
                          _buildPlaceholder(),
                        const SizedBox(height: 32),
                        if (_isProcessing)
                          _buildProcessingIndicator()
                        else
                          _buildControls(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        Container(
              width: double.infinity,
              height: 350,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
                image: DecorationImage(
                  image: FileImage(File(_selectedImage!.path)),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: _clearImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.9, 0.9)),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 350,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.02,
            ),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_enhance_rounded,
                  size: 48,
                  color: AppTheme.primaryColor.withOpacity(0.8),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 2.seconds,
              ),
          const SizedBox(height: 24),
          Text(
            'Scanner un document',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Capturez vos notes ou vos cours pour créer un quiz interactif.',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Créer un Quiz',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 40,
            width: 40,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Analyse IA en cours',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
                'Extraction des concepts clés et génération des fiches de révision...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                  height: 1.5,
                ),
              )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(
                duration: 2.seconds,
                color: Colors.white.withOpacity(0.2),
              ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildControls() {
    if (_selectedImage == null) {
      return Column(
        children: [
          _buildActionButton(
            label: 'Prendre une photo',
            icon: Icons.camera_alt_rounded,
            onTap: _pickImageFromCamera,
            isPrimary: true,
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            label: 'Choisir dans la galerie',
            icon: Icons.photo_library_rounded,
            onTap: _pickImageFromGallery,
            isPrimary: false,
          ),
        ],
      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
    }

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuration du Deck',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _titleController,
            style: const TextStyle(fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              labelText: 'Titre',
              hintText: 'ex: Cours de Biologie',
              labelStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nombre de questions',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _numQuestions.toInt().toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              activeTrackColor: Theme.of(context).colorScheme.onSurface,
              inactiveTrackColor: Theme.of(
                context,
              ).dividerColor.withOpacity(0.1),
              thumbColor: Theme.of(context).colorScheme.onSurface,
              overlayColor: Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.1),
            ),
            child: Slider(
              value: _numQuestions,
              min: 3,
              max: 10,
              divisions: 7,
              onChanged: (val) => setState(() => _numQuestions = val),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _processImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.onSurface,
                foregroundColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Générer avec l\'IA',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: isPrimary
              ? Theme.of(context).colorScheme.onSurface
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: isPrimary
              ? null
              : Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isPrimary
                    ? Theme.of(context).colorScheme.surface.withOpacity(0.2)
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isPrimary
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: isPrimary
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: isPrimary
                  ? Colors.white54
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}
