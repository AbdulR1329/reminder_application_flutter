import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reminder_application/Models/capsule_model.dart';
import 'package:reminder_application/Screens/capsule_detail_screen.dart';
import '../widgets/capsule_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _selectedFilter = "All";

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFEDF1FA),
            Color(0xFFFDE8D7),
          ],
        ),
      ),
      child: SafeArea(
        child: uid == null
            ? const Center(
          child: Text("User not logged in"),
        )
            : _buildFirestoreBody(uid),
      ),
    );
  }

  Widget _buildFirestoreBody(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('capsules')
          .where('userId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text("Failed to load capsules."),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF9DA8C3),
            ),
          );
        }

        final rawDocs = snapshot.data?.docs ?? [];

        List<CapsuleModel> myCapsules = rawDocs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          return CapsuleModel(
            id: data['id'] ?? doc.id,
            userId: data['userId'] ?? '',
            title: data['title'] ?? 'Untitled',
            description: data['description'] ?? '',
            openDate: DateTime.parse(
              data['openDate'] ??
                  DateTime.now().toIso8601String(),
            ),
            tag: data['tag'] ?? 'Capsule',
            memoryCount: data['memoryCount'] ?? 0,
            mediaUrls:
            List<String>.from(data['mediaUrls'] ?? []),
          );
        }).toList();

        List<CapsuleModel> filteredList =
        _getFilteredItems(myCapsules);

        return RefreshIndicator(
          onRefresh: () async {},
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            children: [
              _buildAnimatedItem(
                0,
                const Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Vault',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif',
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Your collection of locked memories and alerts',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7A869A),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              _buildAnimatedItem(
                1,
                _buildFilterBar(),
              ),

              const SizedBox(height: 28),

              if (filteredList.isEmpty)
                _buildAnimatedItem(
                  2,
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Text("No items found."),
                    ),
                  ),
                )
              else
                ...List.generate(filteredList.length,
                        (index) {
                      final item = filteredList[index];

                      return _buildAnimatedItem(
                        index + 2,
                        CapsuleCard(
                          capsule: item,

                          onRefresh: () {},

                          onTap: () {
                            final isCapsule = item.tag
                                .trim()
                                .toLowerCase() ==
                                'capsule';

                            if (isCapsule) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CapsuleDetailScreen(
                                        capsule: item,
                                      ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Reminder: ${item.title}",
                                  ),
                                  backgroundColor:
                                  const Color(
                                      0xFF2C3E50),
                                  behavior:
                                  SnackBarBehavior
                                      .floating,
                                ),
                              );
                            }
                          },
                        ),
                      );
                    }),

              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  List<CapsuleModel> _getFilteredItems(
      List<CapsuleModel> items) {
    if (_selectedFilter == "All") {
      return items;
    }

    return items.where((item) {
      final tag = item.tag.trim().toLowerCase();

      if (_selectedFilter == "Capsules") {
        return tag == "capsule";
      }

      if (_selectedFilter == "Reminders") {
        return tag == "reminder";
      }

      return true;
    }).toList();
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white,
        ),
      ),
      child: Row(
        children: [
          _buildFilterChip("All"),
          _buildFilterChip("Capsules"),
          _buildFilterChip("Reminders"),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF2C3E50)
                  : const Color(0xFF7A869A),
              fontWeight: isSelected
                  ? FontWeight.bold
                  : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedItem(
      int index,
      Widget child,
      ) {
    return TweenAnimationBuilder<double>(
      duration: Duration(
        milliseconds: 600 + (index * 80),
      ),
      tween: Tween(
        begin: 0.0,
        end: 1.0,
      ),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              0,
              20 * (1 - value),
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}