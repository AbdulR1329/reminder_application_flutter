import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'verify_email_screen.dart';
import 'package:reminder_application/Screens/main_dashboard.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showErrorSnackBar('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signIn(_emailController.text.trim(), _passwordController.text.trim());

      if (mounted) {
        if (FirebaseAuth.instance.currentUser?.emailVerified ?? false) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainDashboard()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const VerifyEmailScreen()));
        }
      }
    } on FirebaseAuthException catch (e) {
      print("🔥 LOGIN ERROR CODE: ${e.code}");
      print("🔥 LOGIN ERROR MESSAGE: ${e.message}");
      String errorMessage = 'An unexpected error occurred.';
      if (e.code == 'user-not-found') errorMessage = 'No user found for that email.';
      else if (e.code == 'wrong-password' || e.code == 'invalid-credential') errorMessage = 'Incorrect password or email.';
      else if (e.code == 'invalid-email') errorMessage = 'The email address is badly formatted.';
      else if (e.code == 'user-disabled') errorMessage = 'This user account has been disabled.';

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
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFEDF1FA), Color(0xFFFDE8D7)])),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Welcome Back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, fontFamily: 'Serif', color: Color(0xFF2C3E50))),
                  const SizedBox(height: 8),
                  const Text('Sign in to access your time capsules', style: TextStyle(fontSize: 14, color: Color(0xFF7A869A))),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Email'),
                        _buildTextField(controller: _emailController, hint: 'your@email.com', icon: Icons.email_outlined),
                        const SizedBox(height: 16),
                        _buildLabel('Password'),
                        _buildTextField(controller: _passwordController, hint: 'Enter your password', icon: Icons.lock_outline, isPassword: true, obscureText: _obscurePassword, onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword)),
                        Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())), child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFF9DA8C3), fontSize: 12)))),
                        const SizedBox(height: 8),
                        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _isLoading ? null : _handleLogin, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9DA8C3), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Sign In", style: TextStyle(color: Colors.white, fontSize: 16)))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text("Don't have an account? ", style: TextStyle(color: Color(0xFF7A869A))), GestureDetector(onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignupScreen())), child: const Text("Sign Up", style: TextStyle(color: Color(0xFF9DA8C3), fontWeight: FontWeight.bold)))]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF2C3E50))));
  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false, bool obscureText = false, VoidCallback? onToggleVisibility}) {
    return TextField(controller: controller, obscureText: obscureText, decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Color(0xFFB3B9C9), fontSize: 14), prefixIcon: Icon(icon, color: const Color(0xFFB3B9C9), size: 20), suffixIcon: isPassword ? IconButton(icon: Icon(obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFFB3B9C9), size: 20), onPressed: onToggleVisibility) : null, filled: true, fillColor: const Color(0xFFF5F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)));
  }
}