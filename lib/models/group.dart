class Group {
  final String id;
  final String subject;
  final String level;
  final String subtitle;
  final int memberCount;
  final String iconColor;

  Group({
    required this.id,
    required this.subject,
    required this.level,
    required this.subtitle,
    required this.memberCount,
    required this.iconColor,
  });

  static List<Group> mockList() {
    return [
      Group(
        id: '1',
        subject: 'Français',
        level: 'Première',
        subtitle: 'Rejoint par Céleste et 12 autres',
        memberCount: 13,
        iconColor: 'green',
      ),
      Group(
        id: '2',
        subject: 'Mathématiques',
        level: 'Première',
        subtitle: 'Rejoint par Thomas et 24 autres',
        memberCount: 25,
        iconColor: 'blue',
      ),
      Group(
        id: '3',
        subject: 'SES',
        level: 'Première',
        subtitle: 'Rejoint par Marie et 8 autres',
        memberCount: 9,
        iconColor: 'orange',
      ),
    ];
  }
}
