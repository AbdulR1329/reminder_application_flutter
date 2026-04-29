import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reminder_application/Models/capsule_model.dart'; // Adjust path if needed

class ReminderDetailScreen extends StatefulWidget {
  final CapsuleModel reminder;

  const ReminderDetailScreen({super.key, required this.reminder});

  @override
  State<ReminderDetailScreen> createState() => _ReminderDetailScreenState();
}

class _ReminderDetailScreenState extends State<ReminderDetailScreen> {

  bool get isUnlocked => DateTime.now().isAfter(widget.reminder.openDate);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF1FA), // Bright, clean background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Reminder",
          style: TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: isUnlocked ? _buildUnlockedView() : _buildLockedView(),
    );
  }

  // --- UI FOR WHEN IT IS STILL SCHEDULED (LOCKED) ---
  Widget _buildLockedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE65100).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.alarm, size: 80, color: Color(0xFFE65100)),
            ),
            const SizedBox(height: 32),
            const Text(
              "Scheduled Reminder",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "This reminder will alert you on\n${DateFormat('MMMM d, yyyy - h:mm a').format(widget.reminder.openDate)}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Color(0xFF7A869A), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI FOR WHEN IT IS DUE (UNLOCKED) ---
  Widget _buildUnlockedView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // THE CLEAN WHITE CARD
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Optional Media Header (If they attached a photo, like a prescription)
                if (widget.reminder.mediaUrls.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: PageView.builder(
                        itemCount: widget.reminder.mediaUrls.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            widget.reminder.mediaUrls[index],
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: CircularProgressIndicator(color: Color(0xFFE65100)));
                            },
                          );
                        },
                      ),
                    ),
                  ),

                // 2. Text Content
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.notifications_active, color: Color(0xFFE65100), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MMM d, yyyy • h:mm a').format(widget.reminder.openDate),
                            style: const TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.reminder.title,
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF2C3E50)),
                      ),

                      if (widget.reminder.description.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.reminder.description,
                            style: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF4A5568)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // 3. ACTION BUTTON
          ElevatedButton(
            onPressed: () {
              // Show a satisfying success message and close the screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("✅ Task marked as completed!"),
                  backgroundColor: Color(0xFF4CAF50),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE65100),
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
              shadowColor: const Color(0xFFE65100).withOpacity(0.5),
            ),
            child: const Text(
              "Mark as Completed",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}