class CapsuleModel {
  final String id;
  final String userId; // THIS ensures privacy between users
  final String title;
  final DateTime openDate;
  final String tag;
  final int memoryCount;

  CapsuleModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.openDate,
    required this.tag,
    required this.memoryCount,
  });
  factory CapsuleModel.fromMap(Map<String, dynamic> map) {
    return CapsuleModel(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      openDate: DateTime.parse(map['openDate']),
      tag: map['tag'],
      memoryCount: map['memoryCount'],
    );
  }
}
