import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:reminder_application/Screens/splash_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.initialize();
  
  runApp(const TimeCapsuleApp());
}

class TimeCapsuleApp extends StatelessWidget {
  const TimeCapsuleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('admin').doc('app_config').snapshots(),
      builder: (context, snapshot) {
        String appName = "Time Capsule"; // Default
        if (snapshot.hasData && snapshot.data!.exists) {
          appName = snapshot.data!['appName'] ?? "Time Capsule";
        }

        return MaterialApp(
          title: appName,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF9DA8C3),
            scaffoldBackgroundColor: const Color(0xFFF4F3F8),
          ),
          home: SplashScreen(appName: appName), // Pass it to splash
        );
      },
    );
  }
}
