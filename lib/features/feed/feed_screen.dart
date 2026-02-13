import 'package:flutter/material.dart';
import 'package:flow/models/flashcard.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final List<Flashcard> flashcards = Flashcard.mockList();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Content
          PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: flashcards.length,
            onPageChanged: (index) {
              setState(() => currentIndex = index);
            },
            itemBuilder: (context, index) {
              return _buildFeedItem(context, flashcards[index]);
            },
          ),

          // Top Search Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: _buildTopSearchBar(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text('fiche de SES', style: TextStyle(fontSize: 14)),
          ),
          Icon(Icons.search, color: Colors.grey.shade400, size: 20),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.5, end: 0);
  }

  Widget _buildFeedItem(BuildContext context, Flashcard flashcard) {
    return Stack(
      children: [
        // The Paper/Sheet
        Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 120),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(flashcard.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.95),
                    ],
                    begin: const Alignment(0, 0.5),
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                          flashcard.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.3, end: 0),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildTag(flashcard.subject),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 12,
                          backgroundImage: NetworkImage(flashcard.authorAvatar),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Par ${flashcard.authorName}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 300.ms),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Right side buttons
        Positioned(
          right: 30,
          bottom: 150,
          child: Column(
            children: [
              _buildInteractionItem(
                Icons.bookmark_border_rounded,
                flashcard.bookmarks.toString(),
                0,
              ),
              _buildInteractionItem(
                Icons.chat_bubble_outline_rounded,
                flashcard.comments.toString(),
                1,
              ),
              _buildInteractionItem(
                Icons.favorite_border_rounded,
                flashcard.likes.toString(),
                2,
              ),
              _buildInteractionItem(Icons.ios_share_rounded, '', 3),
              const SizedBox(height: 20),
              Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF86EFAC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 24,
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(delay: 2000.ms, duration: 1500.ms)
                  .then()
                  .shake(delay: 500.ms),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.blue.shade400,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildInteractionItem(IconData icon, String count, int index) {
    return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              Icon(icon, color: Colors.grey.shade600, size: 28),
              if (count.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        )
        .animate()
        .fadeIn(delay: (400 + 100 * index).ms, duration: 400.ms)
        .slideX(begin: 0.5, end: 0, delay: (400 + 100 * index).ms);
  }
}
