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

  /// Refreshes both history and the master list of capsules
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
          // Re-apply filter if user is currently searching during a delete
          if (_isSearching) {
            _onSearchChanged(_searchController.text);
          }
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

  Future<void> _handleSearchSubmit(String query) async {
    if (query.trim().isEmpty) return;
    try {
      await _dbHelper.saveSearchQuery(query.trim());
      _loadDataFromDatabase();
    } catch (e) {
      debugPrint("Failed to save search history: $e");
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      _filteredCapsules = _allCapsules
          .where((capsule) =>
          capsule.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEDF1FA), Color(0xFFFDE8D7)])),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF9DA8C3)))
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildAnimatedItem(
                  0,
                  const Text('Search Vault',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Serif',
                          color: Color(0xFF2C3E50)))),
              const SizedBox(height: 16),
              _buildAnimatedItem(
                  1,
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 8))
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      onSubmitted: _handleSearchSubmit,
                      decoration: InputDecoration(
                        hintText: 'Search memories or reminders...',
                        hintStyle: const TextStyle(
                            color: Color(0xFFB3B9C9), fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: Color(0xFF9DA8C3), size: 22),
                        suffixIcon: _isSearching
                            ? IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: Color(0xFFB3B9C9), size: 20),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            })
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                  )),
              const SizedBox(height: 32),
              if (_errorMessage != null)
                Text(_errorMessage!,
                    style: const TextStyle(color: Colors.redAccent)),
              Expanded(
                child: _isSearching
                    ? _buildSearchResults()
                    : _buildDefaultSearchScreen(),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Results',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50))),
            Text('${_filteredCapsules.length} found',
                style: const TextStyle(fontSize: 12, color: Color(0xFF7A869A))),
          ],
        ),
        const SizedBox(height: 16),
        if (_filteredCapsules.isEmpty)
          Expanded(child: _buildNoResultsState())
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: _filteredCapsules.length,
              itemBuilder: (context, index) => _buildAnimatedItem(
                index + 2,
                CapsuleCard(
                  capsule: _filteredCapsules[index],
                  // When deleted/edited from search results, reload master list
                  onRefresh: _loadDataFromDatabase,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 64, color: const Color(0xFF9DA8C3).withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text("No matches found",
              style: TextStyle(
                  color: Color(0xFF7A869A),
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
          const Text("Try searching with a different title.",
              style:
              TextStyle(color: Color(0xFFB0B7C3), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildDefaultSearchScreen() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        if (_recentSearches.isNotEmpty)
          _buildAnimatedItem(
              2,
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 5))
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.history_rounded,
                            size: 18, color: Color(0xFF9DA8C3)),
                        SizedBox(width: 10),
                        Text('Recent Searches',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                                fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _recentSearches
                            .map((query) => _buildHistoryChip(query))
                            .toList())
                  ],
                ),
              )),
        const SizedBox(height: 32),
        _buildAnimatedItem(3, _buildSearchTipCard()),
      ],
    );
  }

  Widget _buildSearchTipCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF9DA8C3), Color(0xFF7A869A)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: Colors.white, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Search Tip",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                SizedBox(height: 4),
                Text("You can find any locked memory or reminder by its title.",
                    style: TextStyle(
                        color: Colors.white70, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryChip(String label) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        _onSearchChanged(label);
      },
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8EAF6)),
          ),
          child: Text(label,
              style: const TextStyle(
                  color: Color(0xFF2C3E50),
                  fontSize: 13,
                  fontWeight: FontWeight.w500))),
    );
  }

  Widget _buildAnimatedItem(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 80)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)), child: child)),
      child: child,
    );
  }
}