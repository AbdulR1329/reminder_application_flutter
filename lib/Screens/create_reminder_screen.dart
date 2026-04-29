import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reminder_application/services/capsule_service.dart';
import 'package:reminder_application/services/notification_service.dart';

class CreateReminderScreen extends StatefulWidget {
  const CreateReminderScreen({super.key});

  @override
  State<CreateReminderScreen> createState() => _CreateReminderScreenState();
}

class _CreateReminderScreenState extends State<CreateReminderScreen> {
  final _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(minutes: 5));
  bool _vibrateEnabled = true;
  bool _isUploading = false;

  final List<String> _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final Set<int> _selectedDays = {DateTime.now().weekday - 1};

  final CapsuleService _capsuleService = CapsuleService();

  Future<void> _pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );

    if (time != null) {
      setState(() {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, time.hour, time.minute);
      });
    }
  }

  Future<void> _pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        _selectedDate = DateTime(date.year, date.month, date.day, _selectedDate.hour, _selectedDate.minute);
      });
    }
  }

  Future<void> _saveReminder() async {
    if (_titleController.text.trim().isEmpty) return _showError('Please enter a label');
    if (_selectedDate.isBefore(DateTime.now())) return _showError('Time must be in the future');

    setState(() => _isUploading = true);

    try {
      String selectedDaysStr = _selectedDays.isEmpty ? "Once" : _selectedDays.map((i) => _days[i]).join(", ");
      String finalDescription = "🔄 Repeat: $selectedDaysStr";
      if (_vibrateEnabled) finalDescription += '\n📳 Vibration: Enabled';

      await _capsuleService.createFullCapsule(
        title: _titleController.text.trim(),
        description: finalDescription,
        type: 'Reminder',
        openDate: _selectedDate,
        mediaFiles: [], 
      );

      await NotificationService.scheduleReminder(
        id: _selectedDate.millisecondsSinceEpoch.remainder(100000),
        title: "Alarm: ${_titleController.text.trim()}",
        body: "Tap to view details.",
        scheduledTime: _selectedDate,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        _showError('Failed to save alarm.');
        setState(() => _isUploading = false);
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
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
          icon: const Icon(Icons.close, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isUploading ? null : _saveReminder,
            child: const Text("Save", style: TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(width: 16),
        ],
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
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: GestureDetector(
                          onTap: _pickTime,
                          child: Text(
                            DateFormat('h:mm').format(_selectedDate),
                            style: const TextStyle(fontSize: 88, fontWeight: FontWeight.w300, color: Color(0xFF2C3E50), letterSpacing: -2),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          DateFormat('a').format(_selectedDate),
                          style: const TextStyle(fontSize: 22, color: Color(0xFF7A869A), fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 48),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(_days.length, (index) {
                          bool isSelected = _selectedDays.contains(index);
                          return GestureDetector(
                            onTap: () => setState(() => isSelected ? _selectedDays.remove(index) : _selectedDays.add(index)),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 42, height: 42,
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF2C3E50) : Colors.white.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                                boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))] : [],
                              ),
                              child: Center(
                                child: Text(
                                  _days[index],
                                  style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF2C3E50), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 48),

                      _buildPixelTile(
                        icon: Icons.calendar_today_rounded,
                        title: "Date",
                        value: DateFormat('EEEE, MMM d').format(_selectedDate),
                        onTap: _pickDate,
                      ),
                      _buildPixelTile(
                        icon: Icons.label_outline_rounded,
                        title: "Label",
                        value: _titleController.text.isEmpty ? "Add label" : _titleController.text,
                        onTap: _showLabelDialog,
                      ),
                      _buildPixelTile(
                        icon: Icons.vibration_rounded,
                        title: "Vibrate",
                        trailing: Switch.adaptive(
                          value: _vibrateEnabled,
                          activeColor: const Color(0xFF9DA8C3),
                          onChanged: (val) => setState(() => _vibrateEnabled = val),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPixelTile({required IconData icon, required String title, String? value, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: const Color(0xFF2C3E50), size: 22),
      ),
      title: Text(title, style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 16, fontWeight: FontWeight.bold)),
      subtitle: value != null ? Text(value, style: const TextStyle(color: Color(0xFF7A869A), fontSize: 14)) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: Color(0xFFB0B7C3), size: 20),
    );
  }

  void _showLabelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Label", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _titleController,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Enter label"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
