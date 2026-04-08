import 'package:flutter/material.dart';
import 'login_screen.dart';

class ForgotPasswordSuccessScreen extends StatelessWidget {
  final String email;

  const ForgotPasswordSuccessScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFEDF1FA), Color(0xFFFDE8D7)]),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF7A869A), size: 18),
                  label: const Text('Back', style: TextStyle(color: Color(0xFF7A869A))),
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Forgot Password?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, fontFamily: 'Serif', color: Color(0xFF2C3E50))),
                        const SizedBox(height: 8),
                        const Text("No worries, we'll send you reset instructions", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Color(0xFF7A869A))),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(32.0),
                          decoration: BoxDecoration(
                            color: Colors.white, borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(color: Color(0xFFF3E5F5), shape: BoxShape.circle),
                                child: const Icon(Icons.check_circle_outline, size: 40, color: Color(0xFF7B1FA2)),
                              ),
                              const SizedBox(height: 24),
                              const Text('Check Your Email', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Serif', color: Color(0xFF2C3E50))),
                              const SizedBox(height: 12),
                              Text(
                                "We've sent password reset instructions to\n$email",
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14, color: Color(0xFF7A869A), height: 1.5),
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF9DA8C3), padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text("Back to Login", style: TextStyle(color: Colors.white, fontSize: 16)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}