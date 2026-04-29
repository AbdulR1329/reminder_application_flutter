import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  String? _existingImageUrl;
  File? _newImageFile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (currentUser != null) {
      _emailController.text = currentUser!.email ?? "";
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser!.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _nameController.text = data['fullName'] ?? currentUser!.displayName ?? "";
            _phoneController.text = data['phoneNumber'] ?? "";
            _existingImageUrl = data['profileImageUrl'];
          });
        } else {
          _nameController.text = currentUser!.displayName ?? "";
        }
      } catch (e) {
        debugPrint("Error loading profile: $e");
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile != null) {
      setState(() {
        _newImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (currentUser == null) return;
    setState(() => _isSaving = true);

    try {
      String? finalImageUrl = _existingImageUrl;
      if (_newImageFile != null) {
        final ref = _storage.ref().child('profile_pics/${currentUser!.uid}.jpg');
        await ref.putFile(_newImageFile!);
        finalImageUrl = await ref.getDownloadURL();
      }

      await _firestore.collection('users').doc(currentUser!.uid).set({
        'fullName': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        if (finalImageUrl != null) 'profileImageUrl': finalImageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Profile updated!"), backgroundColor: Color(0xFF4CAF50), behavior: SnackBarBehavior.floating),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving profile: $e"), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String get _initials {
    String name = _nameController.text.trim();
    if (name.isEmpty) return "Me";
    List<String> parts = name.split(" ");
    if (parts.length > 1) return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    return name.substring(0, 1).toUpperCase();
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
        title: const Text("Profile", style: TextStyle(color: Color(0xFF2C3E50), fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFF4F3F8), Color(0xFFFDE8D7)]),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF9DA8C3)))
              : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAnimatedItem(0, const Text("Edit Profile", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50), fontFamily: 'Serif'))),
                const SizedBox(height: 32),

                // PROFILE PHOTO
                _buildAnimatedItem(1, Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          height: 120, width: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 10))],
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: ClipOval(
                            child: _newImageFile != null
                                ? Image.file(_newImageFile!, fit: BoxFit.cover)
                                : _existingImageUrl != null
                                ? Image.network(_existingImageUrl!, fit: BoxFit.cover)
                                : Container(
                                    color: const Color(0xFFE8EAF6),
                                    child: Center(child: Text(_initials, style: const TextStyle(color: Color(0xFF9DA8C3), fontSize: 32, fontWeight: FontWeight.bold))),
                                  ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFF9DA8C3), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ),
                )),
                const SizedBox(height: 40),

                // FORM FIELDS
                _buildAnimatedItem(2, Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 8))]),
                  child: Column(
                    children: [
                      _buildTextField("Full Name", Icons.person_outline_rounded, _nameController, false),
                      const SizedBox(height: 24),
                      _buildTextField("Email Address", Icons.email_outlined, _emailController, true),
                      const SizedBox(height: 24),
                      _buildTextField("Phone Number", Icons.phone_outlined, _phoneController, false, isPhone: true),
                    ],
                  ),
                )),
                const SizedBox(height: 40),

                // SAVE BUTTON
                _buildAnimatedItem(3, SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9DA8C3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    child: _isSaving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Save Profile", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                )),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, bool isReadOnly, {bool isPhone = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2C3E50))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: isReadOnly,
          keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
          style: TextStyle(fontWeight: FontWeight.w600, color: isReadOnly ? Colors.grey.shade500 : const Color(0xFF2C3E50)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF9DA8C3), size: 22),
            filled: true,
            fillColor: isReadOnly ? const Color(0xFFF1F3F4) : const Color(0xFFF8F9FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedItem(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) => Opacity(opacity: value, child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child)),
      child: child,
    );
  }
}
