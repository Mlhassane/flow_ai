import 'package:flutter/material.dart';
import 'package:flow/widgets/flashcard_widget.dart';

/// Page de démonstration du widget FlashcardWidget
/// Pour tester, ajoutez cette route dans votre navigation ou lancez-la directement
class FlashcardDemoPage extends StatelessWidget {
  const FlashcardDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Démonstration Flashcard',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Instruction
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Appuyez sur la carte pour la retourner',
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Flashcard
              Expanded(
                child: FlashcardWidget(
                  question: 'Les causes du Krack de 1929',
                  answer:
                      'Le krack de 1929 fait suite à la première Guerre mondiale et une période de surproduction et de forte spéculation.',
                  subject: 'SES',
                  onTap: () {
                    // Optionnel : ajouter un feedback sonore ou haptique
                    debugPrint('Carte retournée');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
