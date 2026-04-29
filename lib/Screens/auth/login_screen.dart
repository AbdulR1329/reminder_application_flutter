import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
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
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      bool canCheck = await _localAuth.canCheckBiometrics;
      bool isSupported = await _localAuth.isDeviceSupported();
      setState(() {
        _canCheckBiometrics = canCheck && isSupported;
      });
    } catch (e) {
      debugPrint("Biometric check error: $e");
    }
  }

  Future<void> _handleBiometricLogin() async {
    try {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to log in',
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
      );

      if (authenticated) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context, 
              MaterialPageRoute(builder: (context) => const MainDashboard()),
              (route) => false,
            );
          }
        } else {
          _showErrorSnackBar("Please log in with email/password first to enable biometric access.");
        }
      }
    } catch (e) {
      _showErrorSnackBar("Biometric authentication failed.");
    }
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showErrorSnackBar('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCred = await _authService.signIn(_emailController.text.trim(), _passwordController.text.trim());
      
      if (mounted) {
        if (userCred.user?.emailVerified ?? false) {
          Navigator.pushAndRemoveUntil(
            context, 
            MaterialPageRoute(builder: (context) => const MainDashboard()),
            (route) => false,
          );
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const VerifyEmailScreen()));
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An unexpected error occurred.';
      if (e.code == 'user-not-found')
      {errorMessage = 'No user found for that email.';}

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
                      Text('Welcome Back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Serif', color: Color(0xFF2C3E50))),
                      SizedBox(height: 8),
                      Text('Sign in to access your time capsules', style: TextStyle(fontSize: 14, color: Color(0xFF7A869A))),
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
                        _buildLabel('Email'),
                        _buildTextField(controller: _emailController, hint: 'your@email.com', icon: Icons.email_outlined),
                        const SizedBox(height: 16),
                        _buildLabel('Password'),
                        _buildTextField(
                          controller: _passwordController, 
                          hint: 'Enter your password', 
                          icon: Icons.lock_outline, 
                          isPassword: true, 
                          obscureText: _obscurePassword, 
                          onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword)
                        ),
                        Align(
                          alignment: Alignment.centerRight, 
                          child: TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())), 
                            child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFF9DA8C3), fontSize: 12))
                          )
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin, 
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF9DA8C3), 
                                  padding: const EdgeInsets.symmetric(vertical: 16), 
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 2,
                                ), 
                                child: _isLoading 
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                                  : const Text("Sign In", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
                              ),
                            ),
                            if (_canCheckBiometrics) ...[
                              const SizedBox(width: 12),
                              InkWell(
                                onTap: _handleBiometricLogin,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F7FA),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF9DA8C3).withValues(alpha: 0.3)),
                                  ),
                                  child: const Icon(Icons.fingerprint, color: Color(0xFF9DA8C3), size: 32),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 24),
                  _buildAnimatedItem(2, Row(
                    mainAxisAlignment: MainAxisAlignment.center, 
                    children: [
                      const Text("Don't have an account? ", style: TextStyle(color: Color(0xFF7A869A))), 
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignupScreen())), 
                        child: const Text("Sign Up", style: TextStyle(color: Color(0xFF9DA8C3), fontWeight: FontWeight.bold))
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
