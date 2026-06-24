import 'package:flutter/material.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                  hint: "Username",
                  icon: Icons.person,
                  obscure: false,
                ),

                const SizedBox(height: 20),

                //////////////////////////////////////////////////////
                /// PASSWORD FIELD
                //////////////////////////////////////////////////////

                _buildTextField(
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
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
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
                  onPressed: () {},
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

                const Text(
                  "Login with",
                  style: TextStyle(color: Colors.grey),
                ),

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
    required String hint,
    required IconData icon,
    required bool obscure,
  }) {
    return TextField(
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
      child: Icon(
        icon,
        color: const Color(0xFFFFD700),
      ),
    );
  }
}