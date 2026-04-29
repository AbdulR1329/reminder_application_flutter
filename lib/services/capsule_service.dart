import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'db_helper.dart';

class CapsuleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final DBHelper _dbHelper = DBHelper();

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  Future<String> _uploadMediaFile(File file, String capsuleId) async {
    if (uid == null) throw Exception("User not logged in");
    String fileName = '${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path)}';
    Reference ref = _storage.ref().child('users/$uid/$capsuleId/$fileName');
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> updateCapsule({
    required String id,
    required String title,
    required String description,
    required DateTime openDate,
  }) async {
    if (uid == null) throw Exception("User not logged in");

    try {
      // 1. Update Firestore
      await _firestore.collection('capsules').doc(id).update({
        'title': title,
        'description': description,
        'openDate': openDate.toIso8601String(),
      });

      // 2. Update Local SQLite
      final dbClient = await _dbHelper.db;
      await dbClient.update(
        'capsules',
        {
          'title': title,
          'description': description,
          'openDate': openDate.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Error updating capsule: $e");
      rethrow;
    }
  }

  Future<void> deleteCapsule(String capsuleId) async {
    if (uid == null) throw Exception("User not logged in");
    try {
      await _firestore.collection('capsules').doc(capsuleId).delete();
      final dbClient = await _dbHelper.db;
      await dbClient.delete('capsules', where: 'id = ?', whereArgs: [capsuleId]);
    } catch (e) {
      print("Error deleting capsule: $e");
      rethrow;
    }
  }

  Future<void> createFullCapsule({
    required String title,
    required String description,
    required String type,
    required DateTime openDate,
    required List<File> mediaFiles,
  }) async {
    if (uid == null) throw Exception("User not logged in");
    try {
      DocumentReference docRef = _firestore.collection('capsules').doc();
      String capsuleId = docRef.id;
      List<String> mediaUrls = [];
      for (File file in mediaFiles) {
        String url = await _uploadMediaFile(file, capsuleId);
        mediaUrls.add(url);
      }
      await docRef.set({
        'id': capsuleId,
        'userId': uid,
        'title': title,
        'description': description,
        'tag': type,
        'openDate': openDate.toIso8601String(), 
        'memoryCount': mediaFiles.length,
        'mediaUrls': mediaUrls,
        'createdAt': FieldValue.serverTimestamp(),
      });
      final dbClient = await _dbHelper.db;
      await dbClient.insert('capsules', {'id': capsuleId, 'userId': uid, 'title': title, 'description': description, 'openDate': openDate.toIso8601String(), 'tag': type, 'memoryCount': mediaFiles.length}, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print("Error creating capsule: $e");
      rethrow;
    }
  }
}
