class Flashcard {
  final String id;
  final String title;
  final String subject;
  final String authorName;
  final String authorAvatar;
  final String imageUrl;
  final int likes;
  final int comments;
  final int bookmarks;
  final DateTime createdAt;
  final List<String> tags;

  Flashcard({
    required this.id,
    required this.title,
    required this.subject,
    required this.authorName,
    required this.authorAvatar,
    required this.imageUrl,
    required this.likes,
    required this.comments,
    required this.bookmarks,
    required this.createdAt,
    required this.tags,
  });

  static List<Flashcard> mockList() {
    return [
      Flashcard(
        id: '1',
        title: 'Le krack boursier de 1929',
        subject: 'SES',
        authorName: 'Jon',
        authorAvatar: 'https://i.pravatar.cc/150?u=jon',
        imageUrl:
            'https://images.unsplash.com/photo-1516979187457-637abb4f9353?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
        likes: 981,
        comments: 32,
        bookmarks: 127,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        tags: ['SES', 'Histoire', 'Économie'],
      ),
      Flashcard(
        id: '2',
        title: 'Les figures de style en français',
        subject: 'Français',
        authorName: 'Marie',
        authorAvatar: 'https://i.pravatar.cc/150?u=marie',
        imageUrl:
            'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
        likes: 1245,
        comments: 67,
        bookmarks: 234,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        tags: ['Français', 'Littérature'],
      ),
      Flashcard(
        id: '3',
        title: 'Théorème de Pythagore',
        subject: 'Mathématiques',
        authorName: 'Lucas',
        authorAvatar: 'https://i.pravatar.cc/150?u=lucas',
        imageUrl:
            'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
        likes: 756,
        comments: 45,
        bookmarks: 189,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        tags: ['Mathématiques', 'Géométrie'],
      ),
      Flashcard(
        id: '4',
        title: 'La Révolution française',
        subject: 'Histoire',
        authorName: 'Sophie',
        authorAvatar: 'https://i.pravatar.cc/150?u=sophie',
        imageUrl:
            'https://images.unsplash.com/photo-1461360370896-922624d12aa1?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
        likes: 892,
        comments: 54,
        bookmarks: 156,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        tags: ['Histoire', 'France'],
      ),
      Flashcard(
        id: '5',
        title: 'Present Perfect vs Past Simple',
        subject: 'Anglais',
        authorName: 'Emma',
        authorAvatar: 'https://i.pravatar.cc/150?u=emma',
        imageUrl:
            'https://images.unsplash.com/photo-1546410531-bb4caa6b424d?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
        likes: 634,
        comments: 28,
        bookmarks: 98,
        createdAt: DateTime.now().subtract(const Duration(hours: 16)),
        tags: ['Anglais', 'Grammaire'],
      ),
    ];
  }
}
