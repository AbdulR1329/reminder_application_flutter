import 'package:flutter/material.dart';
import 'dart:async';
import 'welcome_screen_one.dart'; // Add this import

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    Timer(const Duration(seconds: 3), () {
      // Navigates to the new Onboarding flow
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>WelcomeScreenOne()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEDF1FA),
              Color(0xFFFDE8D7),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.access_time,
                size: 40,
                color: Color(0xFF8B93B0),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Time Capsule',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                fontFamily: 'Serif',
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Preserve your precious memories',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF7A869A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}