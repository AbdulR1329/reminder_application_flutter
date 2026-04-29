import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import the launcher

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final List<Map<String, String>> faqs = [
    {"q": "How do I create a capsule?", "a": "Tap the '+' icon on the dashboard and select 'Time Capsule'. Follow the steps to add your memories and set a reveal date."},
    {"q": "Can I edit a locked capsule?", "a": "No, once a capsule is locked, its contents are sealed until the reveal date. You can only edit the title and date from the vault menu."},
    {"q": "Are my memories secure?", "a": "Yes, all your photos and messages are encrypted and stored securely in the cloud. Only you can access them."},
  ];

  int? _expandedIndex;

  // --- FUNCTIONALITY METHODS ---

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@timecapsule.app',
      queryParameters: {'subject': 'Support Request: Time Capsule v1.0.0'},
    );
    if (!await launchUrl(emailLaunchUri)) {
      _showErrorSnackBar("Could not launch email app");
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showErrorSnackBar("Could not open link");
    }
  }

  void _openLiveChat() {
    // In a real app, you'd integrate Intercom, Zendesk, or Crisp here.
    // For now, we'll simulate an entry point.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Connecting to Live Support...")),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  // --- UI BUILDING ---

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
        title: const Text("Support", style: TextStyle(color: Color(0xFF2C3E50), fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFF4F3F8), Color(0xFFFDE8D7)]),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            children: [
              _buildAnimatedItem(0, const Text("Help Center", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50), fontFamily: 'Serif'))),
              const SizedBox(height: 8),
              _buildAnimatedItem(1, const Text("How can we help you today?", style: TextStyle(color: Color(0xFF7A869A), fontSize: 16))),
              const SizedBox(height: 32),

              // Linked to internal guides or website
              _buildAnimatedItem(2, _buildHelpCard(Icons.smartphone_outlined, "Getting Started", "Learn the basics of Time Capsule", () => _launchURL("https://example.com/start"))),
              _buildAnimatedItem(3, _buildHelpCard(Icons.article_outlined, "User Guide", "Complete guide to all features", () => _launchURL("https://example.com/guide"))),

              const SizedBox(height: 32),
              _buildAnimatedItem(4, const Text("Frequently Asked Questions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)))),
              const SizedBox(height: 16),

              ...List.generate(faqs.length, (index) => _buildAnimatedItem(index + 5, _buildFAQTile(index))),

              const SizedBox(height: 32),
              _buildAnimatedItem(faqs.length + 5, const Text("Contact Support", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)))),
              const SizedBox(height: 16),

              _buildAnimatedItem(faqs.length + 6, Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 8))]),
                child: Column(
                  children: [
                    _buildContactTile(Icons.email_outlined, "Email Support", "support@timecapsule.app", _launchEmail),
                    const Divider(height: 1, color: Color(0xFFF1F3F4), indent: 70),
                    _buildContactTile(Icons.chat_bubble_outline_rounded, "Live Chat", "Instant response within minutes", _openLiveChat),
                  ],
                ),
              )),

              const SizedBox(height: 40),
              _buildAnimatedItem(faqs.length + 7, Center(
                child: Column(
                  children: [
                    const Text("Time Capsule v1.0.0", style: TextStyle(color: Color(0xFF9DA8C3), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 4),
                    Text("© ${DateTime.now().year} All rights reserved.", style: const TextStyle(color: Color(0xFFB0B7C3), fontSize: 11)),
                  ],
                ),
              )),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- UPDATED WIDGETS WITH ONTAP ---

  Widget _buildHelpCard(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 8))]),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF9DA8C3).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: const Color(0xFF9DA8C3), size: 24)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.bold, fontSize: 15)), const SizedBox(height: 2), Text(subtitle, style: const TextStyle(color: Color(0xFF7A869A), fontSize: 12))])),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFB0B7C3)),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQTile(int index) {
    bool isExpanded = _expandedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _expandedIndex = isExpanded ? null : index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(faqs[index]['q']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2C3E50)))),
                AnimatedRotation(turns: isExpanded ? 0.5 : 0, duration: const Duration(milliseconds: 300), child: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF9DA8C3))),
              ],
            ),
            ClipRect(
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                alignment: Alignment.topLeft,
                heightFactor: isExpanded ? 1.0 : 0.0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(faqs[index]['a']!, style: const TextStyle(color: Color(0xFF7A869A), fontSize: 13, height: 1.5)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Color(0xFFF1F3F4), shape: BoxShape.circle), child: Icon(icon, color: Color(0xFF2C3E50), size: 20)),
      title: Text(title, style: const TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: Color(0xFF7A869A), fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFB0B7C3), size: 18),
      onTap: onTap,
    );
  }

  Widget _buildAnimatedItem(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + (index * 80)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) => Opacity(opacity: value, child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child)),
      child: child,
    );
  }
}