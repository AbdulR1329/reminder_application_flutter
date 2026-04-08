import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reminder_application/Models/capsule_model.dart';
import '../widgets/capsule_card.dart';
import '../services/db_helper.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<CapsuleModel> myCapsules = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRealCapsules();
  }

  // ASYNC: Try-Catch for Local Database Reads
  Future<void> _loadRealCapsules() async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      if (mounted) setState(() { _isLoading = false; _errorMessage = "User not logged in"; });
      return;
    }

    try {
      final capsules = await DBHelper().getUserCapsules(uid);
      if (mounted) {
        setState(() {
          myCapsules = capsules;
          _isLoading = false;
          _errorMessage = null; // Clear any previous errors
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load local capsules. Please restart the app.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFEDF1FA), Color(0xFFFDE8D7)])),
      child: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF9DA8C3)));
    }

    if (_errorMessage != null) {
      return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
          )
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        const Text('My Capsules', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, fontFamily: 'Serif', color: Color(0xFF2C3E50))),
        const SizedBox(height: 4),
        Text('${myCapsules.length} time capsules waiting to be opened', style: const TextStyle(fontSize: 14, color: Color(0xFF7A869A))),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {}, // Handled by BottomNav now
                icon: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 18),
                label: const Text('Your Vault', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9DA8C3), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        if (myCapsules.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: Text("You haven't created any capsules yet!", style: TextStyle(color: Color(0xFF7A869A)))),
          )
        else
          ...myCapsules.map((capsule) => CapsuleCard(capsule: capsule)).toList(),

        const SizedBox(height: 40),
      ],
    );
  }
}