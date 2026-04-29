import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = "";
  // UPDATED: View indices are now 0: Users, 1: Analytics, 2: Settings
  int _currentView = 0;

  String _appName = "Time Capsule Pro";
  String _maxStorage = "500 MB";
  String _lockDuration = "365 Days";

  @override
  void initState() {
    super.initState();
    _loadGlobalSettings();
  }

  Future<void> _loadGlobalSettings() async {
    try {
      final doc = await _firestore.collection('admin').doc('app_config').get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _appName = data['appName'] ?? _appName;
          _maxStorage = data['maxStorage'] ?? _maxStorage;
          _lockDuration = data['lockDuration'] ?? _lockDuration;
        });
      }
    } catch (e) {
      debugPrint("Error loading settings: $e");
    }
  }

  Future<void> _saveGlobalSettings() async {
    try {
      await _firestore.collection('admin').doc('app_config').set({
        'appName': _appName,
        'maxStorage': _maxStorage,
        'lockDuration': _lockDuration,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("System configuration updated successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update settings: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showEditDialog(String title, String currentValue, Function(String) onSave) async {
    TextEditingController controller = TextEditingController(text: currentValue);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $title"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: "Enter new $title"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[300], height: 1),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5F6368)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Console",
          style: TextStyle(color: Color(0xFF5F6368), fontSize: 18, fontWeight: FontWeight.w500),
        ),
        actions: [
          if (_currentView == 0) _buildTopSearchBar(),
          const SizedBox(width: 20),
        ],
      ),
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBreadcrumbs(),
                  const SizedBox(height: 20),
                  Expanded(child: _getMainContent()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UPDATED: Removed case 1 (Permissions)
  Widget _getMainContent() {
    switch (_currentView) {
      case 0: return _buildDataTableCard();
      case 1: return _buildAnalyticsView();
      case 2: return _buildSettingsView();
      default: return _buildDataTableCard();
    }
  }

  // UPDATED: Removed the Permissions sidebar item
  Widget _buildSidebar() {
    return Container(
      width: 240,
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _sidebarItem(Icons.people, "Users", _currentView == 0, 0),
            _sidebarItem(Icons.analytics_outlined, "Analytics", _currentView == 1, 1),
            _sidebarItem(Icons.settings, "Settings", _currentView == 2, 2),
          ],
        ),
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String label, bool isSelected, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE8F0FE) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: () => setState(() => _currentView = index),
        dense: true,
        leading: Icon(icon, color: isSelected ? const Color(0xFF1A73E8) : const Color(0xFF5F6368)),
        title: Text(
          label,
          style: TextStyle(color: isSelected ? const Color(0xFF1A73E8) : const Color(0xFF5F6368), fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildTopSearchBar() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      constraints: const BoxConstraints(maxWidth: 400),
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: const InputDecoration(
          hintText: "Search...",
          prefixIcon: Icon(Icons.search, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(top: 8),
        ),
      ),
    );
  }

  // UPDATED: Cleaned up breadcrumb paths
  Widget _buildBreadcrumbs() {
    String currentPath = _currentView == 0 ? "users" : _currentView == 1 ? "analytics" : "settings";
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const Text("Console", style: TextStyle(color: Color(0xFF1A73E8))),
          const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          Text(currentPath, style: const TextStyle(color: Color(0xFF5F6368))),
        ],
      ),
    );
  }

  Widget _buildAnalyticsView() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('capsules').snapshots(),
      builder: (context, capsuleSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('users').snapshots(),
          builder: (context, userSnapshot) {
            if (!capsuleSnapshot.hasData || !userSnapshot.hasData) return const Center(child: CircularProgressIndicator());

            final allCapsules = capsuleSnapshot.data!.docs;
            final capsules = allCapsules.where((d) => (d.data() as Map<String, dynamic>)['tag'] == 'Capsule').length;
            final reminders = allCapsules.where((d) => (d.data() as Map<String, dynamic>)['tag'] == 'Reminder').length;
            final totalUsers = userSnapshot.data!.docs.length;

            return ListView(
              children: [
                const Text("System Overview", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF202124))),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildStatBox("Total Users", totalUsers.toString(), Icons.people_outline, Colors.blue),
                    const SizedBox(width: 16),
                    _buildStatBox("Time Capsules", capsules.toString(), Icons.inventory_2_outlined, Colors.purple),
                    const SizedBox(width: 16),
                    _buildStatBox("Active Reminders", reminders.toString(), Icons.alarm_outlined, Colors.orange),
                  ],
                ),
                const SizedBox(height: 32),
                const Text("Recent Global Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF202124))),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
                  child: Column(
                    children: allCapsules.take(5).map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return ListTile(
                        leading: const Icon(Icons.history_toggle_off_rounded),
                        title: Text(data['title'] ?? "Untitled"),
                        subtitle: Text("Created by user: ${data['userId']}"),
                        trailing: Text(data['tag'] ?? "Item", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 16),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF202124))),
            Text(label, style: const TextStyle(color: Color(0xFF5F6368), fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTableCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: LinearProgressIndicator());

          final users = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final searchLower = _searchQuery.toLowerCase();
            return (data['name'] ?? "").toLowerCase().contains(searchLower) ||
                (data['email'] ?? "").toLowerCase().contains(searchLower);
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  children: [
                    _headerCell("Identifier", 2),
                    _headerCell("Email", 2),
                    _headerCell("Role", 1),
                    _headerCell("Capsules", 1),
                    _headerCell("User UID", 2),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
                  itemBuilder: (context, index) {
                    final data = users[index].data() as Map<String, dynamic>;
                    final uid = users[index].id;
                    return _buildUserRow(uid, data);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingsView() {
    return SingleChildScrollView(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("App Configuration", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF202124))),
              const Divider(height: 40),
              _buildConfigItem("Application Name", _appName, () {
                _showEditDialog("Application Name", _appName, (val) => setState(() => _appName = val));
              }),
              const Divider(),
              _buildConfigItem("Max Media Storage", _maxStorage, () {
                _showEditDialog("Max Media Storage", _maxStorage, (val) => setState(() => _maxStorage = val));
              }),
              const Divider(),
              _buildConfigItem("Default Lock Duration", _lockDuration, () {
                _showEditDialog("Default Lock Duration", _lockDuration, (val) => setState(() => _lockDuration = val));
              }),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: _saveGlobalSettings,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A73E8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)
                  ),
                  child: const Text("Save System Changes"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigItem(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
            Row(
              children: [
                Text(value, style: const TextStyle(color: Color(0xFF5F6368))),
                const SizedBox(width: 8),
                const Icon(Icons.edit, size: 16, color: Color(0xFF1A73E8)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF5F6368)),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildUserRow(String uid, Map<String, dynamic> data) {
    final isAdmin = data['isAdmin'] ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(data['name'] ?? "—", style: const TextStyle(fontSize: 13, color: Color(0xFF1A73E8)), overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: Text(data['email'] ?? "—", style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isAdmin ? Colors.orange[50] : Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isAdmin ? "Admin" : "User",
                textAlign: TextAlign.center,
                style: TextStyle(color: isAdmin ? Colors.orange[800] : Colors.blue[800], fontSize: 11, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('capsules').where('userId', isEqualTo: uid).snapshots(),
              builder: (context, snapshot) {
                int count = snapshot.data?.docs.length ?? 0;
                return Text(
                  "$count",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                );
              },
            ),
          ),
          Expanded(flex: 2, child: Text(uid, style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.grey[600]), overflow: TextOverflow.ellipsis)),
          _buildRowActions(uid, data['name'] ?? ""),
        ],
      ),
    );
  }

  Widget _buildRowActions(String uid, String name) {
    return SizedBox(
      width: 40,
      child: PopupMenuButton(
        icon: const Icon(Icons.more_vert, size: 18),
        itemBuilder: (context) => [
          const PopupMenuItem(child: Text("Edit")),
          PopupMenuItem(
            child: const Text("Delete User", style: TextStyle(color: Colors.red)),
            onTap: () => _deleteUser(uid, name),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(String uid, String name) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete $name?"),
        content: const Text("This user and all their data will be permanently removed."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _firestore.collection('users').doc(uid).delete();
    }
  }
}