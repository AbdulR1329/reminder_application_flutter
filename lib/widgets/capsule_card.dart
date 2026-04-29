import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reminder_application/Models/capsule_model.dart';
import 'package:reminder_application/Screens/capsule_detail_screen.dart';
import 'package:reminder_application/Screens/edit_capsule_screen.dart';
import 'package:reminder_application/services/capsule_service.dart';

class CapsuleCard extends StatelessWidget {
  final CapsuleModel capsule;
  final VoidCallback onRefresh;
  final VoidCallback? onTap; // Added parameter

  const CapsuleCard({
    super.key,
    required this.capsule,
    required this.onRefresh,
    this.onTap, // Added to constructor
  });

  Future<void> _handleDelete(BuildContext context) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Item?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await CapsuleService().deleteCapsule(capsule.id);
      onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    bool isUnlocked = now.isAfter(capsule.openDate);

    return GestureDetector(
      // Priority: 1. Use passed onTap (from HomeView), 2. Default Navigation
      onTap: onTap ?? () async {
        await Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) =>
                CapsuleDetailScreen(capsule: capsule),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
                      .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                  child: child,
                ),
              );
            },
          ),
        );
        onRefresh();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            Hero(
              tag: 'capsule_icon_${capsule.id}',
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isUnlocked ? const Color(0xFFFFF3E0) : const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isUnlocked ? Icons.lock_open : Icons.lock_clock,
                  color: isUnlocked ? const Color(0xFFE65100) : const Color(0xFF9DA8C3),
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    capsule.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isUnlocked
                        ? 'Ready to open!'
                        : 'Unlocks ${DateFormat('MMM d, yyyy').format(capsule.openDate)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isUnlocked ? const Color(0xFFE65100) : const Color(0xFF7A869A),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Color(0xFFB3B9C9)),
              onSelected: (val) async {
                if (val == 'edit') {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditCapsuleScreen(capsule: capsule)),
                  );
                  onRefresh();
                } else if (val == 'delete') {
                  _handleDelete(context);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 8),
                    Text("Edit"),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text("Delete", style: TextStyle(color: Colors.redAccent)),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}