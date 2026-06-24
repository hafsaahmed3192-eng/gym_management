import 'package:flutter/material.dart';
import 'gender_selection_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  //////////////////////////////////////////////////////
  /// PASSWORD VALIDATION
  //////////////////////////////////////////////////////

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 8) {
      return "Password must be at least 8 characters";
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return "Must contain at least one uppercase letter";
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return "Must contain at least one number";
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return "Must contain at least one special character";
    }
    return null;
  }

  //////////////////////////////////////////////////////
  /// BUILD UI
  //////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0F14),
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),

                //////////////////////////////////////////////////////
                /// TITLE
                //////////////////////////////////////////////////////
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
                const Text(
                  "SIGN UP",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),


                const SizedBox(height: 40),

                //////////////////////////////////////////////////////
                /// FULL NAME
                //////////////////////////////////////////////////////

                _buildTextField(
                  controller: _nameController,
                  hint: "Full Name",
                  icon: Icons.person,
                  validator: (value) =>
                  value!.isEmpty ? "Full Name is required" : null,
                ),

                const SizedBox(height: 20),

                //////////////////////////////////////////////////////
                /// EMAIL OR MOBILE
                //////////////////////////////////////////////////////

                _buildTextField(
                  controller: _emailPhoneController,
                  hint: "Email or Mobile Number",
                  icon: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "This field is required";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                //////////////////////////////////////////////////////
                /// PASSWORD
                //////////////////////////////////////////////////////

                _buildTextField(
                  controller: _passwordController,
                  hint: "Password",
                  icon: Icons.lock,
                  obscure: _obscurePassword,
                  validator: _validatePassword,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: const Color(0xFFFFD700),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 20),

                //////////////////////////////////////////////////////
                /// CONFIRM PASSWORD
                //////////////////////////////////////////////////////

                _buildTextField(
                  controller: _confirmPasswordController,
                  hint: "Confirm Password",
                  icon: Icons.lock_outline,
                  obscure: _obscureConfirmPassword,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                  suffix: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: const Color(0xFFFFD700),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword =
                        !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 40),

                //////////////////////////////////////////////////////
                /// SIGN UP BUTTON
                //////////////////////////////////////////////////////

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GenderSelectionScreen(),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                //////////////////////////////////////////////////////
                /// ALREADY HAVE ACCOUNT? LOGIN
//////////////////////////////////////////////////////

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Goes back to Login screen
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
  /// REUSABLE TEXTFIELD
  //////////////////////////////////////////////////////

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: const Color(0xFFFFD700)),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFF1C1F26),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}