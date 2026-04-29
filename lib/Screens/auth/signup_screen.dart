import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'verify_email_screen.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _handleSignUp() async {
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty || _confirmController.text.trim().isEmpty) {
      _showErrorSnackBar('Please fill in all fields'); return;
    }
    if (_passwordController.text != _confirmController.text) {
      _showErrorSnackBar('Passwords do not match'); return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signUp(_nameController.text.trim(), _emailController.text.trim(), _passwordController.text.trim());
      if (mounted) {
        await _authService.sendEmailVerification();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const VerifyEmailScreen()));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to create account.';
      if (e.code == 'weak-password') errorMessage = 'The password is too weak.';
      else if (e.code == 'email-already-in-use') errorMessage = 'An account already exists for that email.';
      else if (e.code == 'invalid-email') errorMessage = 'The email address is badly formatted.';
      if (mounted) _showErrorSnackBar(errorMessage);
    } catch (e) {
      if (mounted) _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, 
            end: Alignment.bottomCenter, 
            colors: [Color(0xFFEDF1FA), Color(0xFFFDE8D7)]
          )
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAnimatedItem(0, const Column(
                    children: [
                      Text('Create Account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Serif', color: Color(0xFF2C3E50))),
                      SizedBox(height: 8),
                      Text('Start preserving your precious memories', style: TextStyle(fontSize: 14, color: Color(0xFF7A869A))),
                    ],
                  )),
                  const SizedBox(height: 32),
                  _buildAnimatedItem(1, Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(24), 
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Full Name'), 
                        _buildTextField(controller: _nameController, hint: 'John Doe', icon: Icons.person_outline), 
                        const SizedBox(height: 16),
                        _buildLabel('Email'), 
                        _buildTextField(controller: _emailController, hint: 'your@email.com', icon: Icons.email_outlined), 
                        const SizedBox(height: 16),
                        _buildLabel('Password'), 
                        _buildTextField(controller: _passwordController, hint: 'Create a password', icon: Icons.lock_outline, isPassword: true, obscureText: _obscurePassword, onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword)), 
                        const SizedBox(height: 16),
                        _buildLabel('Confirm Password'), 
                        _buildTextField(controller: _confirmController, hint: 'Confirm your password', icon: Icons.lock_outline, isPassword: true, obscureText: _obscurePassword, onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword)), 
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity, 
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSignUp, 
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9DA8C3), 
                              padding: const EdgeInsets.symmetric(vertical: 16), 
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                            ), 
                            child: _isLoading 
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                              : const Text("Create Account", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
                          )
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 24),
                  _buildAnimatedItem(2, Row(
                    mainAxisAlignment: MainAxisAlignment.center, 
                    children: [
                      const Text("Already have an account? ", style: TextStyle(color: Color(0xFF7A869A))), 
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())), 
                        child: const Text("Sign In", style: TextStyle(color: Color(0xFF9DA8C3), fontWeight: FontWeight.bold))
                      )
                    ]
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedItem(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))));
  
  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false, bool obscureText = false, VoidCallback? onToggleVisibility}) {
    return TextField(
      controller: controller, 
      obscureText: obscureText, 
      decoration: InputDecoration(
        hintText: hint, 
        hintStyle: const TextStyle(color: Color(0xFFB3B9C9), fontSize: 14), 
        prefixIcon: Icon(icon, color: const Color(0xFFB3B9C9), size: 20), 
        suffixIcon: isPassword ? IconButton(icon: Icon(obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFFB3B9C9), size: 20), onPressed: onToggleVisibility) : null, 
        filled: true, 
        fillColor: const Color(0xFFF5F7FA), 
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      )
    );
  }
}
