import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFEDF1FA), Color(0xFFFDE8D7)])),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(radius: 50, backgroundColor: Color(0xFF9DA8C3), child: Icon(Icons.person, size: 50, color: Colors.white)),
                  const SizedBox(height: 16),
                  Text(user?.displayName ?? "User Name", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(user?.email ?? "email@example.com", style: const TextStyle(color: Color(0xFF7A869A))),
                ],
              ),
            ),
            const SizedBox(height: 32),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _statCard("12", "Total Capsules"),
                _statCard("3", "Unlocked"),
                _statCard("5", "Shared With"),
                _statCard("8", "Achievements"),
              ],
            ),
            const SizedBox(height: 32),
            const Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _activityTile("Created Birthday 2026", "2 days ago"),
            _activityTile("Opened Summer Memories", "1 week ago"),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String val, String label) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(color: Color(0xFF7A869A), fontSize: 12))],
      ),
    );
  }

  Widget _activityTile(String title, String time) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(time),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}