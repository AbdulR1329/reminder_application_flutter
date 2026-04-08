class UserModel {
  final String uid;
  final String fullName;
  final String email;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
  });

  // Used when reading from SQLite or Firebase
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
    );
  }

  // Used when writing to SQLite or Firebase
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
    };
  }
}