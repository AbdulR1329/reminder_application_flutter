import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile_screen.dart';
import 'privacy_security_screen.dart';
import 'notifications_view.dart';
import 'help_support_screen.dart';
import 'auth/login_screen.dart';
import 'admin/admin_panel_screen.dart';
import 'main_dashboard.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<bool> _checkAdminStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return doc.data()?['isAdmin'] ?? false;
    } catch (e) {
      return false;
    }
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
          onPressed: () => Navigator.push(context,MaterialPageRoute(builder: (context)=> MainDashboard())),
        ),
        title: const Text("Back", style: TextStyle(color: Color(0xFF2C3E50), fontSize: 16, fontWeight: FontWeight.w500)),
        titleSpacing: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF4F3F8), Color(0xFFFDE8D7)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            children: [
              _buildAnimatedItem(0, const Text(
                "Settings",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50), fontFamily: 'Georgia'),
              )),
              const SizedBox(height: 32),

              _buildAnimatedItem(1, Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Account"),
                  _buildCardGroup([
                    _buildListTile(Icons.person_outline, "Edit Profile", onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                    }),
                    _buildDivider(),
                    _buildListTile(Icons.lock_outline, "Privacy & Security", onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacySecurityScreen()));
                    }),
                    _buildDivider(),
                    _buildListTile(Icons.notifications_none, "Notifications", onTap: () {
                       Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                    }),
                  ]),
                ],
              )),

              // Admin Panel Section (Conditionally shown)
              FutureBuilder<bool>(
                future: _checkAdminStatus(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data == true) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        _buildAnimatedItem(2, Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle("Administration"),
                            _buildCardGroup([
                              _buildListTile(
                                Icons.admin_panel_settings_outlined,
                                "Admin Panel",
                                iconColor: Colors.amber[800],
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPanelScreen()));
                                },
                              ),
                            ]),
                          ],
                        )),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 24),
              _buildAnimatedItem(3, Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Support"),
                  _buildCardGroup([
                    _buildListTile(Icons.help_outline, "Help & Support", onTap: () {
                       Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()));
                    }),
                  ]),
                ],
              )),

              const SizedBox(height: 24),
              _buildAnimatedItem(4, _buildCardGroup([
                _buildListTile(Icons.logout, "Log Out", iconColor: const Color(0xFF5A6684), textColor: const Color(0xFF2C3E50), onTap: () async {
                   await FirebaseAuth.instance.signOut();
                   if (context.mounted) {
                     Navigator.pushAndRemoveUntil(
                       context,
                       MaterialPageRoute(builder: (_) => const LoginScreen()),
                       (route) => false,
                     );
                   }
                }),
              ])),

              const SizedBox(height: 40),
              _buildAnimatedItem(5, const Center(
                child: Text("Time Capsule v1.0.0", style: TextStyle(color: Color(0xFF7A869A), fontSize: 12)),
              )),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper to create a staggered fade-in and slide-up animation
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

  Widget _buildListTile(IconData icon, String title, {Color? iconColor, Color? textColor, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? const Color(0xFF2C3E50), size: 22),
        title: Text(title, style: TextStyle(color: textColor ?? const Color(0xFF2C3E50), fontWeight: FontWeight.w600, fontSize: 15)),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFFB0B7C3), size: 20),
        onTap: onTap,
        splashColor: const Color(0xFF9DA8C3).withValues(alpha: 0.1),
        hoverColor: const Color(0xFF9DA8C3).withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF0F2F5), indent: 56, endIndent: 16);
  }
}
