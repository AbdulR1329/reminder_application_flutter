import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reminder_application/Models/capsule_model.dart';
import '../widgets/capsule_card.dart';
import '../services/db_helper.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final DBHelper _dbHelper = DBHelper();

  bool _isSearching = false;
  bool _isLoading = true;
  String? _errorMessage;

  List<String> _recentSearches = [];
  List<CapsuleModel> _allCapsules = [];
  List<CapsuleModel> _filteredCapsules = [];

  @override
  void initState() {
    super.initState();
    _loadDataFromDatabase();
  }

  // ASYNC: Try-Catch for Fetching History & Capsules
  Future<void> _loadDataFromDatabase() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    try {
      final recent = await _dbHelper.getRecentSearches();
      final capsules = await _dbHelper.getUserCapsules(uid);

      if (mounted) {
        setState(() {
          _recentSearches = recent;
          _allCapsules = capsules;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Could not load search data.";
        });
      }
    }
  }

  // ASYNC: Try-Catch for Saving to SQLite
  Future<void> _handleSearchSubmit(String query) async {
    if (query.trim().isEmpty) return;

    try {
      await _dbHelper.saveSearchQuery(query.trim());
      _loadDataFromDatabase(); // Refresh chips
    } catch (e) {
      // Silently fail if history can't save, no need to interrupt user flow
      print("Failed to save search history: $e");
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      _filteredCapsules = _allCapsules.where((capsule) =>
          capsule.title.toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFEDF1FA), Color(0xFFFDE8D7)])),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF9DA8C3)))
            : Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Search', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, fontFamily: 'Serif', color: Color(0xFF2C3E50))),
              const SizedBox(height: 16),

              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onSubmitted: _handleSearchSubmit,
                decoration: InputDecoration(
                  hintText: 'Search your time capsules...',
                  hintStyle: const TextStyle(color: Color(0xFFB3B9C9)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFB3B9C9)),
                  suffixIcon: _isSearching
                      ? IconButton(icon: const Icon(Icons.close, color: Color(0xFFB3B9C9)), onPressed: () { _searchController.clear(); _onSearchChanged(''); })
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 24),

              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)),

              Expanded(
                child: _isSearching ? _buildSearchResults() : _buildDefaultSearchScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Results (${_filteredCapsules.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
        const SizedBox(height: 16),
        if (_filteredCapsules.isEmpty)
          const Center(child: Text("No capsules found.", style: TextStyle(color: Color(0xFF7A869A))))
        else
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCapsules.length,
              itemBuilder: (context, index) => CapsuleCard(capsule: _filteredCapsules[index]),
            ),
          ),
      ],
    );
  }

  Widget _buildDefaultSearchScreen() {
    return ListView(
      children: [
        if (_recentSearches.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [Icon(Icons.access_time, size: 16, color: Color(0xFF7A869A)), SizedBox(width: 8), Text('Recent Searches', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)))]),
                const SizedBox(height: 16),
                Wrap(spacing: 8, runSpacing: 8, children: _recentSearches.map((query) => _buildHistoryChip(query)).toList())
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHistoryChip(String label) {
    return GestureDetector(
      onTap: () { _searchController.text = label; _onSearchChanged(label); },
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE8EAF6)), borderRadius: BorderRadius.circular(20)), child: Text(label, style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 12))),
    );
  }
}