import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reminder_application/Models/capsule_model.dart';

class CapsuleDetailScreen extends StatelessWidget {
  final CapsuleModel capsule;

  const CapsuleDetailScreen({super.key, required this.capsule});

  @override
  Widget build(BuildContext context) {
    // Check if the current date is past the unlock date
    bool isUnlocked = DateTime.now().isAfter(capsule.openDate);

    return Scaffold(
      backgroundColor: const Color(0xFFEDF1FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // THE RECEIVING HERO: The icon from the previous screen lands here!
            Hero(
              tag: 'capsule_icon_${capsule.id}',
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  color: isUnlocked ? const Color(0xFFFFF3E0) : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Icon(
                  isUnlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                  size: 50,
                  color: isUnlocked ? const Color(0xFFE65100) : const Color(0xFF9DA8C3),
                ),
              ),
            ),

            const SizedBox(height: 32),
            Text(capsule.title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Serif', color: Color(0xFF2C3E50))),
            const SizedBox(height: 8),

            // Implicit Animation: Fades text based on lock status
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: Text(
                isUnlocked ? "The wait is over." : "Sealed until ${DateFormat('MMMM d, yyyy').format(capsule.openDate)}",
                key: ValueKey(isUnlocked),
                style: TextStyle(fontSize: 16, color: isUnlocked ? const Color(0xFFE65100) : const Color(0xFF7A869A)),
              ),
            ),

            const SizedBox(height: 40),

            // The Content Area
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                ),
                child: _buildContent(isUnlocked),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isUnlocked) {
    if (!isUnlocked) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.hourglass_empty, size: 60, color: Color(0xFFE8EAF6)),
          const SizedBox(height: 24),
          const Text("Patience...", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
          const SizedBox(height: 12),
          const Text("This capsule's memories are still gestating. Come back when the time is right.", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF7A869A))),
        ],
      );
    }

    // If Unlocked, show the gallery! (We will just show placeholders for now if you didn't upload photos)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Memories Unlocked", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
        const SizedBox(height: 24),
        Expanded(
          child: capsule.mediaUrls.isEmpty
              ? const Center(child: Text("No photos were saved in this capsule.", style: TextStyle(color: Color(0xFF7A869A))))
              : GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16),
            itemCount: capsule.mediaUrls.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(capsule.mediaUrls[index], fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(color: const Color(0xFFF5F7FA), child: const Center(child: CircularProgressIndicator(color: Color(0xFF9DA8C3))));
                  },
                ),
              );
            },
          ),
        )
      ],
    );
  }
}