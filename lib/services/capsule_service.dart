import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sqflite/sqflite.dart'; // Required for ConflictAlgorithm
import 'package:path/path.dart' as p; // Required to get file extensions (.jpg, .mp4)
import 'db_helper.dart';

class CapsuleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final DBHelper _dbHelper = DBHelper();

  // Safely get the current user ID
  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  // --- 1. Upload a single file to Firebase Storage ---
  Future<String> _uploadMediaFile(File file, String capsuleId) async {
    if (uid == null) throw Exception("User not logged in");

    // Create a unique filename: timestamp + original extension (e.g., 16843920.jpg)
    String fileName = '${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path)}';

    // Save to folder path: users / uid / capsuleId / filename
    Reference ref = _storage.ref().child('users/$uid/$capsuleId/$fileName');

    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask;

    // Return the secure, public URL
    return await snapshot.ref.getDownloadURL();
  }

  // --- 2. Create the full capsule ---
  Future<void> createFullCapsule({
    required String title,
    required String description,
    required String type,
    required List<File> mediaFiles,
  }) async {
    if (uid == null) throw Exception("User not logged in");

    try {
      // A. Create a blank document first so we can generate a unique ID
      DocumentReference docRef = _firestore.collection('capsules').doc();
      String capsuleId = docRef.id;

      // B. Upload all selected photos/videos and collect their URLs
      List<String> mediaUrls = [];
      for (File file in mediaFiles) {
        String url = await _uploadMediaFile(file, capsuleId);
        mediaUrls.add(url);
      }

      // C. Prepare the data (Setting unlock date to 1 year from now for testing)
      DateTime openDate = DateTime.now().add(const Duration(days: 365));

      Map<String, dynamic> capsuleData = {
        'id': capsuleId,
        'userId': uid,
        'title': title,
        'description': description,
        'tag': type,
        'openDate': openDate.toIso8601String(),
        'memoryCount': mediaFiles.length,
        'mediaUrls': mediaUrls, // The array of image/video links
        'createdAt': FieldValue.serverTimestamp(),
      };

      // D. Save to Firestore (The Cloud)
      await docRef.set(capsuleData);

      // E. Save to SQLite (Local Cache for instant search)
      final dbClient = await _dbHelper.db;
      await dbClient.insert(
          'capsules',
          {
            'id': capsuleId,
            'userId': uid,
            'title': title,
            'openDate': openDate.toIso8601String(),
            'tag': type,
            'memoryCount': mediaFiles.length,
          },
          conflictAlgorithm: ConflictAlgorithm.replace
      );

      print("Capsule Created Successfully!");

    } catch (e) {
      print("Error creating capsule: $e");
      rethrow; // Pass error back to UI to show a SnackBar if it fails
    }
  }

  // --- 3. Sync existing capsules from Cloud to Local ---
  Future<void> syncCapsules() async {
    if (uid == null) return;

    QuerySnapshot snapshot = await _firestore
        .collection('capsules')
        .where('userId', isEqualTo: uid)
        .get();

    final dbClient = await _dbHelper.db;

    for (var doc in snapshot.docs) {
      await dbClient.insert(
          'capsules',
          {
            'id': doc.id,
            'userId': uid,
            'title': doc['title'],
            'openDate': doc['openDate'],
            'tag': doc['tag'],
            'memoryCount': doc['memoryCount'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace
      );
    }
  }
}