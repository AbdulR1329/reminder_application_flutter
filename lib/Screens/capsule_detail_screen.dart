import 'dart:ui'; // <--- REQUIRED FOR THE FROSTED GLASS BLUR
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reminder_application/Models/capsule_model.dart';

class CapsuleDetailScreen extends StatefulWidget {
  final CapsuleModel capsule;

  const CapsuleDetailScreen({super.key, required this.capsule});

  @override
  State<CapsuleDetailScreen> createState() => _CapsuleDetailScreenState();
}

class _CapsuleDetailScreenState extends State<CapsuleDetailScreen> with TickerProviderStateMixin {

  bool get isUnlocked => DateTime.now().isAfter(widget.capsule.openDate);

  late AnimationController _sheetController;
  late Animation<Offset> _sheetSlide;
  late Animation<double> _sheetFade;

  late AnimationController _bgController;
  late Animation<double> _bgScale;

  @override
  void initState() {
    super.initState();

    // Slower, more elegant slide up
    _sheetController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _sheetSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _sheetController, curve: Curves.easeOutCubic),
    );
    _sheetFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sheetController, curve: Curves.easeOut),
    );

    // Cinematic Background Zoom
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 20));
    _bgScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOutSine),
    );

    if (isUnlocked) {
      _sheetController.forward();
      _bgController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black, // Dark background makes the fade-ins look better
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.2)), // Aesthetic thin border
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: isUnlocked ? _buildUnlockedView() : _buildLockedView(),
    );
  }

  // --- UI FOR WHEN IT IS STILL LOCKED ---
  Widget _buildLockedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 80, color: Colors.white.withOpacity(0.5)),
            const SizedBox(height: 32),
            const Text(
              "Memory Locked",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w300, color: Colors.white, letterSpacing: 2),
            ),
            const SizedBox(height: 16),
            Text(
              "Unsealing on\n${DateFormat('MMMM d, yyyy').format(widget.capsule.openDate)}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.5), height: 1.5, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI FOR WHEN IT IS UNLOCKED (Frosted Glass Aesthetics) ---
  Widget _buildUnlockedView() {
    if (widget.capsule.mediaUrls.isEmpty) return _buildTextOnlyView();

    return Stack(
      children: [
        // 1. FRONT IMAGE (Animated Cinematic Zoom)
        Positioned.fill(
          child: ScaleTransition(
            scale: _bgScale,
            child: PageView.builder(
                itemCount: widget.capsule.mediaUrls.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    widget.capsule.mediaUrls[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator(color: Colors.white24));
                    },
                  );
                }
            ),
          ),
        ),

        // 2. MOODY VIGNETTE (Darkens the edges slightly to draw eyes to the center)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
              ),
            ),
          ),
        ),

        // 3. AESTHETIC FROSTED GLASS BOTTOM SHEET
        Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: _sheetSlide,
            child: FadeTransition(
              opacity: _sheetFade,
              child: ClipRRect( // Clips the blur so it doesn't bleed everywhere
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // THE MAGIC BLUR
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(32, 40, 32, 48),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4), // Dark translucent tint
                      border: Border(
                        top: BorderSide(color: Colors.white.withOpacity(0.2), width: 1), // Shine effect on top edge
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.capsule.title.toUpperCase(), // Uppercase for editorial look
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat('MMMM d, yyyy • h:mm a').format(widget.capsule.openDate),
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w400, fontSize: 14, letterSpacing: 0.5),
                          ),

                          if (widget.capsule.description.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Text(
                              widget.capsule.description,
                              style: TextStyle(fontSize: 16, height: 1.7, color: Colors.white.withOpacity(0.9)),
                            ),
                          ],

                          if (widget.capsule.mediaUrls.length > 1) ...[
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_back_ios, size: 12, color: Colors.white.withOpacity(0.5)),
                                const SizedBox(width: 8),
                                Text(
                                  "SWIPE TO BROWSE",
                                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white.withOpacity(0.5)),
                              ],
                            )
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Backup view for text-only reminders
  Widget _buildTextOnlyView() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            Text(
                widget.capsule.title.toUpperCase(),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.5)
            ),
            const SizedBox(height: 8),
            Text(
                "UNLOCKED ON ${DateFormat('MMM d, yyyy').format(widget.capsule.openDate)}",
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w600, letterSpacing: 1)
            ),
            const SizedBox(height: 40),
            if (widget.capsule.description.isNotEmpty) ...[
              Container(
                height: 2, width: 40, color: Colors.white.withOpacity(0.3),
                margin: const EdgeInsets.only(bottom: 24),
              ),
              Text(
                  widget.capsule.description,
                  style: TextStyle(fontSize: 18, height: 1.8, color: Colors.white.withOpacity(0.9))
              ),
            ],
          ],
        ),
      ),
    );
  }
}