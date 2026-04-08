import 'package:flutter/material.dart';
import 'home_view.dart';
import 'search_view.dart';
import 'notifications_view.dart';
import 'create_capsule_screen.dart';
import 'profile_view.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  // The list of screens to swap between
  final List<Widget> _screens = [
    const HomeView(),
    const SearchView(),
    const CreateCapsuleScreen(),
    const NotificationsView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],

      // Custom Bottom Navigation Bar matching your design
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
            color: const Color(0xFFFDE8D7).withOpacity(0.9), // Matches gradient bottom
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
            ]
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(icon: Icons.home_outlined, label: 'Home', index: 0),
              _buildNavItem(icon: Icons.search_outlined, label: 'Search', index: 1),
              _buildCreateButton(), // The special center button
              _buildNavItem(icon: Icons.notifications_none_outlined, label: 'Alerts', index: 3),
              _buildNavItem(icon: Icons.person_outline, label: 'Profile', index: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? const Color(0xFF2C3E50) : const Color(0xFF7A869A)),
          const SizedBox(height: 4),
          Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? const Color(0xFF2C3E50) : const Color(0xFF7A869A),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              )
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF9DA8C3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white, size: 20),
            SizedBox(height: 2),
            Text('Create', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}