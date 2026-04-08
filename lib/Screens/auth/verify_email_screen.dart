import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home_screen.dart';
import '../../services/auth_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  Timer? timer;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    if (!isEmailVerified) {
      timer = Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerified());
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    });

    if (isEmailVerified) {
      timer?.cancel();
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFEDF1FA), Color(0xFFFDE8D7)])),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(padding: const EdgeInsets.all(24), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.mark_email_unread_outlined, size: 64, color: Color(0xFF9DA8C3))),
                const SizedBox(height: 32),
                const Text('Verify Your Email', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, fontFamily: 'Serif', color: Color(0xFF2C3E50))),
                const SizedBox(height: 16),
                const Text('We have sent a verification link to your email address. Please click the link to activate your account.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Color(0xFF7A869A), height: 1.5)),
                const SizedBox(height: 40),
                const CircularProgressIndicator(color: Color(0xFF9DA8C3)),
                const SizedBox(height: 24),
                const Text('Waiting for verification...', style: TextStyle(color: Color(0xFF7A869A))),
                const SizedBox(height: 40),
                TextButton(
                  onPressed: () async {
                    await _authService.sendEmailVerification();
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification email resent!')));
                  },
                  child: const Text("Resend Email", style: TextStyle(color: Color(0xFF2C3E50), fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                TextButton(
                  onPressed: () { FirebaseAuth.instance.signOut(); Navigator.pop(context); },
                  child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}