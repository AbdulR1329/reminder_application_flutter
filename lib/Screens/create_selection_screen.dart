import 'package:flutter/material.dart';
import 'create_capsule_screen.dart';
import 'create_reminder_screen.dart';
import 'main_dashboard.dart';

class CreateSelectionScreen extends StatelessWidget {
  const CreateSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF2C3E50), size: 28),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainDashboard())),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEDF1FA), Color(0xFFFDE8D7)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildAnimatedItem(0, const Text(
                  "Create Something\nNew",
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50), height: 1.1, fontFamily: 'Serif'),
                )),
                const SizedBox(height: 12),
                _buildAnimatedItem(1, const Text(
                  "Choose a type of memory or alert to get started.",
                  style: TextStyle(fontSize: 16, color: Color(0xFF7A869A)),
                )),
                const SizedBox(height: 48),

                // Option 1: Time Capsule
                _buildAnimatedItem(2, _buildSelectionCard(
                  context: context,
                  title: "Time Capsule",
                  description: "Lock away photos and letters to be opened in the future. Perfect for long-term memories.",
                  icon: Icons.inventory_2_rounded,
                  color: const Color(0xFF9DA8C3),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateCapsuleScreen()));
                  },
                )),

                const SizedBox(height: 20),

                // Option 2: Reminder
                _buildAnimatedItem(3, _buildSelectionCard(
                  context: context,
                  title: "Scheduled Reminder",
                  description: "Set a specific alert for medication, meetings, or important events with optional repeats.",
                  icon: Icons.alarm_rounded,
                  color: const Color(0xFFE65100),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateReminderScreen()));
                  },
                )),
                
                const SizedBox(height: 40),
                _buildAnimatedItem(4, Center(
                  child: Text(
                    "Select an option above to continue",
                    style: TextStyle(color: const Color(0xFF7A869A).withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.2),
                  ),
                )),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required BuildContext context, required String title, required String description,
    required IconData icon, required Color color, required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                  const SizedBox(height: 8),
                  Text(description, style: const TextStyle(color: Color(0xFF7A869A), fontSize: 14, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedItem(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
