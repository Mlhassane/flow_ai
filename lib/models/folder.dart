class Folder {
  final String id;
  final String name;
  final String subject;
  final int flashcardCount;
  final String color;
  final DateTime lastModified;

  Folder({
    required this.id,
    required this.name,
    required this.subject,
    required this.flashcardCount,
    required this.color,
    required this.lastModified,
  });

  static List<Folder> mockList() {
    return [
      Folder(
        id: '1',
        name: 'Économie mondiale',
        subject: 'SES',
        flashcardCount: 24,
        color: 'blue',
        lastModified: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Folder(
        id: '2',
        name: 'Figures de style',
        subject: 'Français',
        flashcardCount: 18,
        color: 'purple',
        lastModified: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Folder(
        id: '3',
        name: 'Trigonométrie',
        subject: 'Mathématiques',
        flashcardCount: 32,
        color: 'green',
        lastModified: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Folder(
        id: '4',
        name: 'Révolution française',
        subject: 'Histoire',
        flashcardCount: 15,
        color: 'orange',
        lastModified: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Folder(
        id: '5',
        name: 'Verbes irréguliers',
        subject: 'Anglais',
        flashcardCount: 45,
        color: 'red',
        lastModified: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      Folder(
        id: '6',
        name: 'Chimie organique',
        subject: 'Physique-Chimie',
        flashcardCount: 28,
        color: 'teal',
        lastModified: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }
}
