import 'package:flutter/material.dart';
import 'welcome_screen_three.dart';

class WelcomeScreenTwo extends StatelessWidget {
  const WelcomeScreenTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEDF1FA), Color(0xFFFDE8D7)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(color: Color(0xFFFFF3E0), shape: BoxShape.circle),
                              child: const Icon(Icons.lock_outline_rounded, size: 32, color: Color(0xFF2C3E50)),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Lock Memories in Time',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, fontFamily: 'Serif', color: Color(0xFF2C3E50)),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Seal your photos, videos, and messages. Set a date and let time work its magic.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Color(0xFF7A869A), height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Dots: Screen 2 is active
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(isActive: false),
                  _buildDot(isActive: true),
                  _buildDot(isActive: false),
                ],
              ),
              const SizedBox(height: 40),

              // Bottom Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context), // Goes back to Screen 1
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF7A869A)),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const WelcomeScreenThree()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9DA8C3),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Next", style: TextStyle(color: Colors.white)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot({required bool isActive}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF9DA8C3) : const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}