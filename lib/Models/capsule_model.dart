class CapsuleModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime openDate;
  final String tag;
  final int memoryCount;
  final List<String> mediaUrls;

  CapsuleModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.openDate,
    required this.tag,
    required this.memoryCount,
    this.mediaUrls = const [],
  });

  factory CapsuleModel.fromMap(Map<String, dynamic> map) {
    return CapsuleModel(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      description: map['description'] ?? '',
      openDate: DateTime.parse(map['openDate']),
      tag: map['tag'],
      memoryCount: map['memoryCount'],
    );
  }
}