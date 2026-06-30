import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_management/screens/dashboard_screen.dart';
import 'package:gym_management/services/auth_service.dart';
import 'signup_screen.dart';
import 'forget_password.dart';
import 'gender_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  bool _obscurePassword = true;
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const SizedBox(height: 50),

                //////////////////////////////////////////////////////
                /// LOGO
                //////////////////////////////////////////////////////
                Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),

                const SizedBox(height: 20),

                //////////////////////////////////////////////////////
                /// APP NAME
                //////////////////////////////////////////////////////
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "FUSION",
                        style: TextStyle(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white
                              : const Color(0xFF1A1A1A), // softer dark
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      TextSpan(
                        text: "GYM",
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Be an Inspiration",
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 50),

                //////////////////////////////////////////////////////
                /// USERNAME FIELD
                //////////////////////////////////////////////////////
                _buildTextField(
                  controller: _emailController,
                  hint: "Email",
                  icon: Icons.email,
                  obscure: false,
                ),

                const SizedBox(height: 20),

                //////////////////////////////////////////////////////
                /// PASSWORD FIELD
                //////////////////////////////////////////////////////
                _buildTextField(
                  controller: _passwordController,
                  hint: "Password",
                  icon: Icons.lock,
                  obscure: _obscurePassword,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 40),

                //////////////////////////////////////////////////////
                /// LOGIN BUTTON
                //////////////////////////////////////////////////////
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_emailController.text.isEmpty ||
                          _passwordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter email and password"),
                          ),
                        );
                        return;
                      }

                      setState(() => _isLoading = true);

                      try {
                        await _authService.login(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                        );

                        if (!mounted) return;

                        final user = FirebaseAuth.instance.currentUser;

                        if (user == null) {
                          throw Exception("Login failed");
                        }

                        final userDoc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .get();

                        if (!userDoc.exists) {
                          throw Exception("User data not found in Firestore");
                        }

                        final data = userDoc.data();

                        if (data?['gender'] == null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const GenderSelectionScreen(),
                            ),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DashboardScreen(),
                            ),
                          );
                        }
                      } catch (e) {
                        print("LOGIN ERROR: $e");

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Login failed: ${e.toString()}"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }

                      if (mounted) {
                        setState(() => _isLoading = false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                //////////////////////////////////////////////////////
                /// FORGOT PASSWORD
                //////////////////////////////////////////////////////
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                //////////////////////////////////////////////////////
                /// SIGN UP OPTION
                //////////////////////////////////////////////////////
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "No account? ",
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                //////////////////////////////////////////////////////
                /// LOGIN WITH
                //////////////////////////////////////////////////////
                Text(
                  "Login with",
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),

                const SizedBox(height: 20),

                //////////////////////////////////////////////////////
                /// SOCIAL ICONS
                //////////////////////////////////////////////////////
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SocialIcon(icon: Icons.facebook),
                    const SizedBox(width: 20),
                    _SocialIcon(icon: Icons.g_mobiledata),
                    const SizedBox(width: 20),
                    _SocialIcon(icon: Icons.alternate_email),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////
  /// TEXT FIELD
  //////////////////////////////////////////////////////

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool obscure,
    Widget? suffix,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        prefixIcon: Icon(
          icon,
          color: theme.colorScheme.primary,
        ),
        suffixIcon: suffix,
        filled: true,
        fillColor: theme.cardColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// SOCIAL ICON WIDGET
////////////////////////////////////////////////////////////

class _SocialIcon extends StatelessWidget {
  final IconData icon;

  const _SocialIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CircleAvatar(
      radius: 22,
      backgroundColor: theme.cardColor,
      child: Icon(icon, color: theme.colorScheme.primary),
    );
  }
}