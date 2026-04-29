import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reminder_application/Models/capsule_model.dart';
import 'package:reminder_application/services/capsule_service.dart';

class EditCapsuleScreen extends StatefulWidget {
  final CapsuleModel capsule;
  const EditCapsuleScreen({super.key, required this.capsule});

  @override
  State<EditCapsuleScreen> createState() => _EditCapsuleScreenState();
}

class _EditCapsuleScreenState extends State<EditCapsuleScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late DateTime _selectedDate;
  bool _isSaving = false;
  final CapsuleService _capsuleService = CapsuleService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.capsule.title);
    _descController = TextEditingController(text: widget.capsule.description);
    _selectedDate = widget.capsule.openDate;
  }

  Future<void> _pickDateTime() async {
    // FIX: Ensure firstDate is never after initialDate
    DateTime now = DateTime.now();
    DateTime firstDate = _selectedDate.isBefore(now) ? _selectedDate : now;

    DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: firstDate,
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
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> _handleUpdate() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Title cannot be empty")));
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _capsuleService.updateCapsule(
        id: widget.capsule.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        openDate: _selectedDate,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Updated successfully")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Update failed: $e")));
        setState(() => _isSaving = false);
      }
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Edit Capsule", style: TextStyle(color: Color(0xFF2C3E50), fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEDF1FA), Color(0xFFFDE8D7)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Modify your Memory", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50), fontFamily: 'Serif')),
                const SizedBox(height: 32),
                _buildInputField("Title", _titleController, Icons.title_rounded),
                const SizedBox(height: 20),
                _buildInputField("Description", _descController, Icons.edit_note_rounded, maxLines: 4),
                const SizedBox(height: 20),
                const Text("Reveal Date", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDateTime,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))]),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, color: Color(0xFF9DA8C3), size: 22),
                        const SizedBox(width: 16),
                        Text(
                          DateFormat('MMMM d, yyyy • h:mm a').format(_selectedDate),
                          style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9DA8C3), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.all(18)),
                    onPressed: _isSaving ? null : _handleUpdate,
                    child: _isSaving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))]),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(prefixIcon: Icon(icon, color: const Color(0xFF9DA8C3)), border: InputBorder.none, contentPadding: const EdgeInsets.all(20)),
          ),
        ),
      ],
    );
  }
}
