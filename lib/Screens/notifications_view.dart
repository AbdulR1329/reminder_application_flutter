import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:reminder_application/Models/capsule_model.dart';
import 'package:reminder_application/Screens/capsule_detail_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Activity Feed",
          style: TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.bold, fontSize: 22, fontFamily: 'Serif'),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.black.withValues(alpha: 0.05), height: 1),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F9FB), Color(0xFFFDE8D7)],
          ),
        ),
        child: SafeArea(
          child: uid == null
              ? const Center(child: Text("Please sign in to view alerts."))
              : _buildRealTimeFeed(uid),
        ),
      ),
    );
  }

  Widget _buildRealTimeFeed(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('capsules')
          .where('userId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text("Connection lost."));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF9DA8C3)));
        }

        final rawDocs = snapshot.data?.docs ?? [];
        List<CapsuleModel> allItems = rawDocs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return CapsuleModel(
            id: data['id'] ?? doc.id,
            userId: data['userId'] ?? '',
            title: data['title'] ?? 'Untitled',
            description: data['description'] ?? '',
            openDate: DateTime.parse(data['openDate'] ?? DateTime.now().toIso8601String()),
            tag: data['tag'] ?? 'Capsule',
            memoryCount: data['memoryCount'] ?? 0,
            mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
          );
        }).toList();

        // 1. Filter for items ready to be viewed
        // 2. Filter out items that the user has manually dismissed from this feed
        final now = DateTime.now();
        List<CapsuleModel> unlockedItems = allItems.where((item) {
          final isReady = now.isAfter(item.openDate);
          // We assume 'isDismissed' is a field we might add. For now, we'll just filter by time.
          return isReady;
        }).toList();
        
        unlockedItems.sort((a, b) => b.openDate.compareTo(a.openDate));

        if (unlockedItems.isEmpty) return _buildEmptyState();

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: unlockedItems.length,
          separatorBuilder: (context, index) => Divider(height: 1, color: Colors.black.withValues(alpha: 0.05), indent: 80),
          itemBuilder: (context, index) {
            final item = unlockedItems[index];
            return _buildAnimatedItem(
              index,
              Dismissible(
                key: Key("notif_${item.id}"),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  // LOGIC: We don't delete the capsule, we just hide the notification.
                  // In a real app, you'd update a 'isDismissed' field in Firestore here.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Notification cleared"), behavior: SnackBarBehavior.floating),
                  );
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 32),
                  color: Colors.grey.withValues(alpha: 0.2),
                  child: const Icon(Icons.done_all_rounded, color: Colors.green, size: 28),
                ),
                child: _buildNotificationItem(context, item),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationItem(BuildContext context, CapsuleModel item) {
    final isCapsule = item.tag == 'Capsule';
    final accentColor = isCapsule ? const Color(0xFF9DA8C3) : const Color(0xFFE65100);
    final icon = isCapsule ? Icons.inventory_2_outlined : Icons.alarm_on_outlined;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isCapsule) {
            // CAPSULES: Go to the beautiful cinematic screen
            Navigator.push(context, MaterialPageRoute(builder: (_) => CapsuleDetailScreen(capsule: item)));
          } else {
            // REMINDERS: Just show a quick info overlay or snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Reminder: ${item.title}"),
                backgroundColor: const Color(0xFF2C3E50),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isCapsule ? "Ready to Open" : "Reminder",
                          style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
                        ),
                        Text(
                          _formatTime(item.openDate),
                          style: TextStyle(color: Colors.grey[500], fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50)),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.description.isNotEmpty ? item.description : "No additional notes.",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isCapsule) 
                const Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFB3B9C9), size: 12),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inMinutes < 60) return "${difference.inMinutes}m ago";
    if (difference.inHours < 24) return "${difference.inHours}h ago";
    return DateFormat('MMM d').format(date);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Opacity(
        opacity: 0.6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text("All caught up", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF7A869A))),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedItem(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(opacity: value, child: Transform.translate(offset: Offset(0, 10 * (1 - value)), child: child)),
      child: child,
    );
  }
}
