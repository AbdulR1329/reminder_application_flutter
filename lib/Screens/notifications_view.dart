import 'package:flutter/material.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFEDF1FA), Color(0xFFFDE8D7)])),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text("Notifications", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Serif')),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _notifTile("Time Capsule Ready!", "Your 'Summer 2024' capsule is now unlocked", "2 hours ago", Icons.access_time, true),
                  _notifTile("Group Capsule Invitation", "Sarah invited you to 'Family Reunion' capsule", "1 day ago", Icons.people_outline, false),
                  _notifTile("Reminder", "Add more memories before your capsule locks tomorrow", "2 days ago", Icons.notifications_none, false),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _notifTile(String title, String sub, String time, IconData icon, bool isNew) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: const Color(0xFFF5F7FA), child: Icon(icon, color: const Color(0xFF9DA8C3))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(sub, style: const TextStyle(fontSize: 12, color: Color(0xFF7A869A))),
                Text(time, style: const TextStyle(fontSize: 10, color: Color(0xFFB3B9C9))),
              ],
            ),
          ),
          if (isNew) const CircleAvatar(radius: 4, backgroundColor: Colors.indigoAccent)
        ],
      ),
    );
  }
}