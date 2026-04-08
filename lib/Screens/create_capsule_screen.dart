import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/capsule_service.dart';
import 'main_dashboard.dart';

class CreateCapsuleScreen extends StatefulWidget {
  const CreateCapsuleScreen({super.key});

  @override
  State<CreateCapsuleScreen> createState() => _CreateCapsuleScreenState();
}

class _CreateCapsuleScreenState extends State<CreateCapsuleScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _capsuleType = 'Personal';
  final List<File> _selectedMedia = [];
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();
  final CapsuleService _capsuleService = CapsuleService();

  void _nextStep() {
    if (_titleController.text.trim().isEmpty && _currentStep == 0) {
      _showError('Please enter a title');
      return;
    }

    if (_currentStep < 2) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _finishAndUpload();
    }
  }

  // ASYNC: Try-Catch for File System Permissions
  Future<void> _pickMedia(bool isVideo) async {
    try {
      final XFile? file = isVideo
          ? await _picker.pickVideo(source: ImageSource.gallery)
          : await _picker.pickImage(source: ImageSource.gallery);

      if (file != null) {
        setState(() => _selectedMedia.add(File(file.path)));
      }
    } catch (e) {
      _showError('Failed to pick media. Check gallery permissions.');
    }
  }

  // ASYNC: Try-Catch for Network/Firebase Uploads
  Future<void> _finishAndUpload() async {
    if (_selectedMedia.isEmpty) {
      _showError('Please add at least one photo or video');
      return;
    }

    setState(() => _isUploading = true);

    try {
      await _capsuleService.createFullCapsule(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          type: _capsuleType,
          mediaFiles: _selectedMedia
      );

      if (mounted) {
        // Success! Reload the dashboard to show the new capsule
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainDashboard()),
        );
      }
    } catch (e) {
      if (mounted) {

        _showError('Upload failed: Ensure you have an active internet connection.');
        setState(() => _isUploading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFEDF1FA), Color(0xFFFDE8D7)])),
        child: SafeArea(
          child: Column(
            children: [
              _buildProgressIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // Force using the Next button
                  onPageChanged: (i) => setState(() => _currentStep = i),
                  children: [_buildStep1(), _buildStep2(), _buildStep3()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Text("Create Time Capsule", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildCardField("Capsule Title", _titleController, "My Special Moments"),
          _buildCardField("Description", _descController, "Tell us about this capsule...", maxLines: 3),
          const SizedBox(height: 20),
          Row(
            children: [
              _typeButton("Personal", Icons.lock_outline),
              const SizedBox(width: 12),
              _typeButton("Group", Icons.people_outline),
            ],
          ),
          const Spacer(),
          _actionButton("Next →", _nextStep),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Text("Add Content", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _mediaOption(Icons.image_outlined, "Add Photos", () => _pickMedia(false)),
              _mediaOption(Icons.videocam_outlined, "Add Videos", () => _pickMedia(true)),
            ],
          ),
          const SizedBox(height: 20),
          Text("${_selectedMedia.length} files selected", style: const TextStyle(color: Color(0xFF7A869A), fontWeight: FontWeight.bold)),
          const Spacer(),
          _actionButton("Next →", _nextStep),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_clock, size: 80, color: Color(0xFF9DA8C3)),
          const SizedBox(height: 24),
          const Text("Ready to Lock?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text("This capsule will be sealed securely in the cloud and synced to your devices.", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF7A869A))),
          const Spacer(),
          _actionButton(_isUploading ? "Sealing Capsule..." : "Lock & Save", _finishAndUpload),
        ],
      ),
    );
  }

  // --- UI Helpers (Same as before) ---
  Widget _buildProgressIndicator() {
    return Padding(padding: const EdgeInsets.all(20.0), child: Row(children: List.generate(3, (index) => Expanded(child: Container(height: 4, margin: const EdgeInsets.symmetric(horizontal: 4), decoration: BoxDecoration(color: index <= _currentStep ? const Color(0xFF9DA8C3) : Colors.white, borderRadius: BorderRadius.circular(2)))))));
  }
  Widget _mediaOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 32, color: const Color(0xFF9DA8C3)), const SizedBox(height: 8), Text(label)])));
  }
  Widget _actionButton(String label, VoidCallback onTap) {
    return SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9DA8C3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.all(16)), onPressed: _isUploading ? null : onTap, child: _isUploading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(label, style: const TextStyle(color: Colors.white, fontSize: 16))));
  }
  Widget _typeButton(String type, IconData icon) {
    bool selected = _capsuleType == type;
    return Expanded(child: GestureDetector(onTap: () => setState(() => _capsuleType = type), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: selected ? Colors.white : Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(16), border: selected ? Border.all(color: const Color(0xFF9DA8C3)) : null), child: Column(children: [Icon(icon, color: selected ? const Color(0xFF9DA8C3) : Colors.grey), const SizedBox(height: 4), Text(type, style: TextStyle(color: selected ? const Color(0xFF9DA8C3) : Colors.grey))]))));
  }
  Widget _buildCardField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))), const SizedBox(height: 8), TextField(controller: controller, maxLines: maxLines, decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))), const SizedBox(height: 16)]);
  }
}