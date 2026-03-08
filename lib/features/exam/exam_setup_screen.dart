import 'package:flutter/material.dart';
import 'package:flow/core/theme.dart';
import 'package:flow/models/exam.dart';
import 'package:flow/services/exam_service.dart';
import 'package:flow/features/exam/exam_simulation_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ExamSetupScreen extends StatefulWidget {
  const ExamSetupScreen({super.key});

  @override
  State<ExamSetupScreen> createState() => _ExamSetupScreenState();
}

class _ExamSetupScreenState extends State<ExamSetupScreen> {
  final ExamService _examService = ExamService();
  final TextEditingController _subjectController = TextEditingController();

  ExamLevel _selectedLevel = ExamLevel.bac;
  Country _selectedCountry = Country.mali;
  bool _isLoading = false;

  Future<void> _startExam() async {
    if (_subjectController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saisis une matière (ex: Philosophie, SVT...)'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final exam = await _examService.generateMockExam(
        subject: _subjectController.text.trim(),
        level: _selectedLevel,
        country: _selectedCountry,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ExamSimulationScreen(exam: exam),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Simulateur d\'Examen',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Prépare ton examen blanc',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ).animate().fadeIn().slideX(),
            const SizedBox(height: 8),
            Text(
              'L\'IA va générer un sujet conforme aux programmes nationaux.',
              style: TextStyle(color: Colors.grey.shade600),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 32),

            // Matière
            const Text(
              'Matière',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                hintText: 'Ex: Mathématiques, Histoire...',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Niveau
            const Text('Niveau', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: ExamLevel.values.map((level) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(
                        level.toString().split('.').last.toUpperCase(),
                      ),
                      selected: _selectedLevel == level,
                      onSelected: (val) =>
                          setState(() => _selectedLevel = level),
                      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: _selectedLevel == level
                            ? AppTheme.primaryColor
                            : null,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Pays
            const Text('Pays', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            DropdownButtonFormField<Country>(
              value: _selectedCountry,
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              items: Country.values.map((c) {
                String flag = c == Country.mali
                    ? '🇲🇱'
                    : c == Country.burkina
                    ? '🇧🇫'
                    : '🇳🇪';
                return DropdownMenuItem(
                  value: c,
                  child: Text(
                    '$flag ${c.toString().split('.').last.toUpperCase()}',
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedCountry = val!),
            ),

            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _startExam,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Générer l\'examen',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
