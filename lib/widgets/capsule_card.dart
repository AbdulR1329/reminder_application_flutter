import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reminder_application/Models/capsule_model.dart';
import 'package:reminder_application/Screens/capsule_detail_screen.dart'; // We will create this next!

class CapsuleCard extends StatelessWidget {
  final CapsuleModel capsule;

  const CapsuleCard({super.key, required this.capsule});

  @override
  Widget build(BuildContext context) {
    bool isUnlocked = DateTime.now().isAfter(capsule.openDate);

    return GestureDetector(
      onTap: () {
        // Custom Page Transition (Fades and scales up slightly)
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) => CapsuleDetailScreen(capsule: capsule),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                  child: child,
                ),
              );
            },
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            // THE HERO ANIMATION: This icon will fly to the next screen
            Hero(
              tag: 'capsule_icon_${capsule.id}',
              child: Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: isUnlocked ? const Color(0xFFFFF3E0) : const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                    isUnlocked ? Icons.lock_open : Icons.lock_clock,
                    color: isUnlocked ? const Color(0xFFE65100) : const Color(0xFF9DA8C3),
                    size: 28
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(capsule.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                  const SizedBox(height: 4),
                  Text(
                    isUnlocked ? 'Ready to open!' : 'Unlocks ${DateFormat('MMM d, yyyy').format(capsule.openDate)}',
                    style: TextStyle(fontSize: 14, color: isUnlocked ? const Color(0xFFE65100) : const Color(0xFF7A869A)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFB3B9C9)),
          ],
        ),
      ),
    );
  }
}