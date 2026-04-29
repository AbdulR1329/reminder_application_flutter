import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../services/capsule_service.dart';
import 'main_dashboard.dart';

class CreateCapsuleScreen extends StatefulWidget {
  const CreateCapsuleScreen({super.key});

  @override
  State<CreateCapsuleScreen> createState() => _CreateCapsuleScreenState();
}

class _CreateCapsuleScreenState extends State<CreateCapsuleScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDate;
  final List<File> _selectedMedia = [];
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();
  final CapsuleService _capsuleService = CapsuleService();

  Future<void> _pickDateTime() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF9DA8C3)),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 12, minute: 0),
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> _pickMedia(bool isVideo) async {
    try {
      final XFile? file = isVideo
          ? await _picker.pickVideo(source: ImageSource.gallery)
          : await _picker.pickImage(source: ImageSource.gallery);

      if (file != null) {
        setState(() => _selectedMedia.add(File(file.path)));
      }
    } catch (e) {
      _showError('Failed to pick media.');
    }
  }

  Future<void> _finishAndUpload() async {
    if (_titleController.text.trim().isEmpty) {
      _showError('Please enter a title');
      return;
    }
    if (_selectedDate == null) {
      _showError('Please select a release date');
      return;
    }

    setState(() => _isUploading = true);

    try {
      await _capsuleService.createFullCapsule(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          type: 'Capsule',
          openDate: _selectedDate!,
          mediaFiles: _selectedMedia
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainDashboard()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Upload failed. Please check your connection.');
        setState(() => _isUploading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating)
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
        title: const Text("New Capsule", style: TextStyle(color: Color(0xFF2C3E50), fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Serif')),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEDF1FA), Color(0xFFFDE8D7)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAnimatedItem(0, const Text("Preserve a Moment", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50), fontFamily: 'Serif'))),
                const SizedBox(height: 8),
                _buildAnimatedItem(1, const Text("Fill in the details and add your precious memories.", style: TextStyle(color: Color(0xFF7A869A)))),
                const SizedBox(height: 32),

                // SECTION 1: DETAILS
                _buildAnimatedItem(2, _buildInputField("Capsule Title", _titleController, "e.g., Summer Trip 2024", Icons.title_rounded)),
                const SizedBox(height: 24),
                _buildAnimatedItem(3, _buildInputField("A Note to the Future", _descController, "Write a heartfelt message...", Icons.edit_note_rounded, maxLines: 4)),
                const SizedBox(height: 24),

                // SECTION 2: DATE
                _buildAnimatedItem(4, _buildSectionLabel("When to Reveal?")),
                const SizedBox(height: 8),
                _buildAnimatedItem(4, GestureDetector(
                  onTap: _pickDateTime,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, color: Color(0xFF9DA8C3), size: 22),
                        const SizedBox(width: 16),
                        Text(
                          _selectedDate == null ? "Select Date & Time" : DateFormat('MMMM d, yyyy • h:mm a').format(_selectedDate!),
                          style: TextStyle(
                            color: _selectedDate == null ? const Color(0xFFB0B7C3) : const Color(0xFF2C3E50),
                            fontSize: 16,
                            fontWeight: _selectedDate == null ? FontWeight.normal : FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
                const SizedBox(height: 32),

                // SECTION 3: MEDIA
                _buildAnimatedItem(5, _buildSectionLabel("Add Memories")),
                const SizedBox(height: 12),
                _buildAnimatedItem(5, Row(
                  children: [
                    Expanded(child: _buildMediaPickerButton(Icons.image_rounded, "Photos", () => _pickMedia(false))),
                    const SizedBox(width: 16),
                    Expanded(child: _buildMediaPickerButton(Icons.videocam_rounded, "Videos", () => _pickMedia(true))),
                  ],
                )),
                const SizedBox(height: 16),
                _buildAnimatedItem(6, _buildMediaPreviewGrid()),
                const SizedBox(height: 48),

                // ACTION BUTTON
                _buildAnimatedItem(7, _buildActionButton(_isUploading ? "Sealing Capsule..." : "Seal & Lock", _finishAndUpload)),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaPreviewGrid() {
    if (_selectedMedia.isEmpty) return const SizedBox.shrink();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _selectedMedia.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemBuilder: (context, index) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(image: FileImage(_selectedMedia[index]), fit: BoxFit.cover),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
              ),
            ),
            Positioned(
              top: 4, right: 4,
              child: GestureDetector(
                onTap: () => setState(() => _selectedMedia.removeAt(index)),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 14, color: Colors.redAccent),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint, IconData icon, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(label),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFFB0B7C3), fontSize: 14),
              prefixIcon: Icon(icon, color: const Color(0xFF9DA8C3), size: 22),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) => Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50), fontSize: 14, letterSpacing: 0.5));

  Widget _buildMediaPickerButton(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: [
              Icon(icon, size: 28, color: const Color(0xFF9DA8C3)),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50), fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9DA8C3),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          padding: const EdgeInsets.all(20),
          elevation: 8,
          shadowColor: const Color(0xFF9DA8C3).withValues(alpha: 0.4),
        ),
        onPressed: _isUploading ? null : onTap,
        child: _isUploading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
            : Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
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
