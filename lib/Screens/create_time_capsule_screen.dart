import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:reminder_application/services/capsule_service.dart';
import 'main_dashboard.dart';

class CreateTimeCapsuleScreen extends StatefulWidget {
  const CreateTimeCapsuleScreen({super.key});

  @override
  State<CreateTimeCapsuleScreen> createState() => _CreateTimeCapsuleScreenState();
}

class _CreateTimeCapsuleScreenState extends State<CreateTimeCapsuleScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDate;
  final List<File> _selectedMedia = [];

  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();
  final CapsuleService _capsuleService = CapsuleService();

  /// Logic to pick Date then Time, ensuring it's in the future
  Future<void> _pickDateTime(BuildContext context) async {
    // 1. Pick Date
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF9DA8C3)),
        ),
        child: child!,
      ),
    );

    if (date == null) return;

    // 2. Pick Time
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedDate != null
          ? TimeOfDay.fromDateTime(_selectedDate!)
          : TimeOfDay.now(),
    );

    if (time == null) return;

    // 3. Combine
    final DateTime finalDateTime = DateTime(
      date.year, date.month, date.day, time.hour, time.minute,
    );

    // 4. Strict Validation
    if (finalDateTime.isBefore(DateTime.now())) {
      _showError("That time is already gone! Please pick a future moment.");
      return;
    }

    setState(() => _selectedDate = finalDateTime);
  }

  void _nextStep() {
    if (_currentStep == 0 && _titleController.text.trim().isEmpty) {
      _showError('Please give your capsule a title');
      return;
    }
    if (_currentStep == 2 && _selectedDate == null) {
      _showError('Please set an unlock date and time');
      return;
    }

    if (_currentStep < 2) {
      FocusScope.of(context).unfocus();
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut
      );
    } else {
      _finishAndUpload();
    }
  }

  Future<void> _pickMedia(bool isVideo) async {
    final XFile? file = isVideo
        ? await _picker.pickVideo(source: ImageSource.gallery)
        : await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _selectedMedia.add(File(file.path)));
  }

  Future<void> _finishAndUpload() async {
    if (_selectedDate == null) return;

    // Double check just in case they sat on the screen too long
    if (_selectedDate!.isBefore(DateTime.now())) {
      _showError("The selected time has now passed. Please update it.");
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
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainDashboard()),
                (route) => false
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Upload failed. Please check your connection.');
        setState(() => _isUploading = false);
      }
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent)
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("New Time Capsule", style: TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFFEDF1FA),
          elevation: 0,
          foregroundColor: Colors.black
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFFEDF1FA), Color(0xFFFDE8D7)])
        ),
        child: Column(
          children: [
            // Progress Indicator
            Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                    children: List.generate(3, (index) => Expanded(
                      child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                              color: index <= _currentStep ? const Color(0xFF9DA8C3) : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10)
                          )
                      ),
                    ))
                )
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentStep = i),
                children: [
                  _buildStep(
                      title: "The Story",
                      subtitle: "Give your capsule a name and a message for your future self.",
                      content: Column(children: [
                        _buildField("Capsule Title", _titleController, "e.g., Graduation Day 2024"),
                        _buildField("Personal Message", _descController, "What do you want to remember?", maxLines: 5),
                      ])
                  ),
                  _buildStep(
                      title: "The Memories",
                      subtitle: "Attach photos or videos that capture this moment.",
                      content: Column(children: [
                        Row(children: [
                          Expanded(child: _actionBtn("Photo", () => _pickMedia(false), Icons.camera_alt_rounded)),
                          const SizedBox(width: 16),
                          Expanded(child: _actionBtn("Video", () => _pickMedia(true), Icons.videocam_rounded)),
                        ]),
                        const SizedBox(height: 30),
                        if (_selectedMedia.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            children: _selectedMedia.map((f) => Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(f, width: 70, height: 70, fit: BoxFit.cover),
                                ),
                                Positioned(
                                  right: -10, top: -10,
                                  child: IconButton(
                                    icon: const Icon(Icons.cancel, color: Colors.red),
                                    onPressed: () => setState(() => _selectedMedia.remove(f)),
                                  ),
                                )
                              ],
                            )).toList(),
                          )
                        else
                          const Text("No files attached yet", style: TextStyle(color: Colors.grey)),
                      ])
                  ),
                  _buildStep(
                      title: "The Seal",
                      subtitle: "Set the exact date and time this capsule should reappear.",
                      content: Column(children: [
                        const Icon(Icons.history, size: 80, color: Color(0xFF9DA8C3)),
                        const SizedBox(height: 32),

                        // IMPROVED INTERACTIVE DATE CARD
                        InkWell(
                          onTap: () => _pickDateTime(context),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                                ],
                                border: Border.all(
                                    color: _selectedDate == null ? Colors.transparent : const Color(0xFF9DA8C3),
                                    width: 2
                                )
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _selectedDate == null ? "Set Unlock Date" : "Unlock Date & Time",
                                  style: const TextStyle(color: Color(0xFF7A869A), fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _selectedDate == null
                                      ? "Tap to select..."
                                      : DateFormat('EEEE, MMM d, yyyy').format(_selectedDate!),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                if (_selectedDate != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('hh:mm a').format(_selectedDate!),
                                    style: const TextStyle(fontSize: 16, color: Color(0xFF9DA8C3), fontWeight: FontWeight.w600),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "🔒 Once sealed, this cannot be opened early.",
                          style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      ])
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({required String title, required String subtitle, required Widget content}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(children: [
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
        const SizedBox(height: 8),
        Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Color(0xFF7A869A))),
        const SizedBox(height: 32),
        content,
        const SizedBox(height: 40),
        SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9DA8C3),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
                onPressed: _isUploading ? null : _nextStep,
                child: _isUploading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_currentStep == 2 ? "Seal & Save" : "Continue", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
            )
        )
      ]),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
              const SizedBox(height: 10),
              TextField(
                  controller: controller,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: const TextStyle(color: Color(0xFFB3B9C9)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.all(18)
                  )
              )
            ]
        )
    );
  }

  Widget _actionBtn(String label, VoidCallback onTap, IconData icon) {
    return ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9DA8C3),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
        )
    );
  }
}