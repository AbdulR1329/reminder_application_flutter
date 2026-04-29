import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final LocalAuthentication auth = LocalAuthentication();

  bool twoFactor = false;
  bool biometric = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          twoFactor = data['twoFactor'] ?? false;
          biometric = data['biometric'] ?? false;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateSetting(String key, bool value) async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _firestore.collection('users').doc(user.uid).set({
        key: value,
      }, SetOptions(merge: true));
    } catch (e) {
      _loadUserSettings();
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      bool canCheck = await auth.canCheckBiometrics;
      bool isSupported = await auth.isDeviceSupported();

      if (!canCheck || !isSupported) {
        _showSnackBar("Biometrics not supported on this device");
        return;
      }

      try {
        bool authenticated = await auth.authenticate(
          localizedReason: 'Please authenticate to enable biometric login',
          options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
        );

        if (authenticated) {
          setState(() => biometric = true);
          _updateSetting('biometric', true);
        }
      } catch (e) {
        _showSnackBar("Authentication failed");
      }
    } else {
      setState(() => biometric = false);
      _updateSetting('biometric', false);
    }
  }

  Future<void> _handleChangePassword() async {
    final user = _auth.currentUser;
    if (user != null && user.email != null) {
      try {
        await _auth.sendPasswordResetEmail(email: user.email!);
        _showSnackBar("Password reset email sent to ${user.email}");
      } catch (e) {
        _showSnackBar("Failed to send reset email. Please try again later.");
      }
    } else {
      _showSnackBar("User email not found.");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF2C3E50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C3E50), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Back", style: TextStyle(color: Color(0xFF2C3E50), fontSize: 16, fontWeight: FontWeight.w500)),
        titleSpacing: 0,
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF4F3F8), Color(0xFFFDE8D7)],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF9DA8C3)))
              : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            children: [
              _buildAnimatedItem(0, const Text(
                "Privacy & Security",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50), fontFamily: 'Georgia'),
              )),
              const SizedBox(height: 32),

              _buildAnimatedItem(1, Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Security"),
                  _buildCardGroup([
                    _buildToggleTile(
                      icon: Icons.lock_outline,
                      title: "Two-Factor Authentication",
                      subtitle: "Add extra security to your account",
                      value: twoFactor,
                      onChanged: (val) {
                        setState(() => twoFactor = val);
                        _updateSetting('twoFactor', val);
                      },
                    ),
                    _buildDivider(),
                    _buildToggleTile(
                      icon: Icons.fingerprint,
                      title: "Biometric Login",
                      subtitle: "Use fingerprint or face ID",
                      value: biometric,
                      onChanged: _toggleBiometric,
                    ),
                  ]),
                ],
              )),

              const SizedBox(height: 24),
              _buildAnimatedItem(2, _buildCardGroup([
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: const Icon(Icons.lock_reset, color: Color(0xFF2C3E50), size: 24),
                  title: const Text("Change Password", style: TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text("Update your password regularly", style: TextStyle(color: Color(0xFF7A869A), fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right, color: Color(0xFFB0B7C3), size: 20),
                  onTap: _handleChangePassword,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ])),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widgets (unchanged logic, purely for UI consistency)
  Widget _buildAnimatedItem(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutQuint,
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF7A869A)),
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildToggleTile({required IconData icon, required String title, required String subtitle, required bool value, required Function(bool) onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2C3E50), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Color(0xFF7A869A), fontSize: 12)),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeColor: const Color(0xFF9DA8C3),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF0F2F5), indent: 56, endIndent: 16);
  }
}