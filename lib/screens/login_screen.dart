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
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
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
                const Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: Color(0xFFFFD700),
                ),

                const SizedBox(height: 20),

                //////////////////////////////////////////////////////
                /// APP NAME
                //////////////////////////////////////////////////////
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: "FUSION",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      TextSpan(
                        text: "GYM",
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Be an Inspiration",
                  style: TextStyle(
                    color: Colors.grey,
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
                  obscure: true,
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
                          // ✅ IMPORTANT: Add your Dashboard here
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const DashboardScreen(), // temporary
                              // change to DashboardScreen later
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
                      backgroundColor: const Color(0xFFFFD700),
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
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Color(0xFFFFD700),
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
                    const Text(
                      "No account? ",
                      style: TextStyle(color: Colors.grey),
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
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Color(0xFFFFD700),
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
                const Text("Login with", style: TextStyle(color: Colors.grey)),

                const SizedBox(height: 20),

                //////////////////////////////////////////////////////
                /// SOCIAL ICONS
                //////////////////////////////////////////////////////
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    _SocialIcon(icon: Icons.facebook),
                    SizedBox(width: 20),
                    _SocialIcon(icon: Icons.g_mobiledata),
                    SizedBox(width: 20),
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
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: const Color(0xFFFFD700)),
        filled: true,
        fillColor: const Color(0xFF1C1F26),
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
    return CircleAvatar(
      radius: 22,
      backgroundColor: const Color(0xFF1C1F26),
      child: Icon(icon, color: const Color(0xFFFFD700)),
    );
  }
}
