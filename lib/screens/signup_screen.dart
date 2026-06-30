import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
  TextEditingController();
  final TextEditingController _emailController =
  TextEditingController();
  final TextEditingController _passwordController =
  TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  //////////////////////////////////////////////////////
  /// PASSWORD VALIDATION
  //////////////////////////////////////////////////////

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 8) {
      return "Must be at least 8 characters";
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return "Must contain one uppercase letter";
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return "Must contain one number";
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]')
        .hasMatch(value)) {
      return "Must contain one special character";
    }
    return null;
  }

  //////////////////////////////////////////////////////
  /// BUILD UI
  //////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: theme.colorScheme.primary,
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),

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
                          color: Theme.of(context).brightness == Brightness.dark
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
                          color: Theme.of(context).colorScheme.primary,
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
                    color: theme.colorScheme.onSurface
                        .withOpacity(0.6),
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  "SIGN UP",
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),

                //////////////////////////////////////////////////////
                /// FULL NAME
                //////////////////////////////////////////////////////

                _buildTextField(
                  controller: _nameController,
                  hint: "Full Name",
                  icon: Icons.person,
                  validator: (value) =>
                  value == null || value.isEmpty
                      ? "Full Name is required"
                      : null,
                ),

                const SizedBox(height: 20),

                //////////////////////////////////////////////////////
                /// EMAIL
                //////////////////////////////////////////////////////

                _buildTextField(
                  controller: _emailController,
                  hint: "Email",
                  icon: Icons.email,
                  validator: (value) =>
                  value == null || value.isEmpty
                      ? "Email is required"
                      : null,
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
                      color:
                      theme.colorScheme.primary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword =
                        !_obscurePassword;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 20),

                //////////////////////////////////////////////////////
                /// CONFIRM PASSWORD
                //////////////////////////////////////////////////////

                _buildTextField(
                  controller:
                  _confirmPasswordController,
                  hint: "Confirm Password",
                  icon: Icons.lock_outline,
                  obscure: _obscureConfirmPassword,
                  validator: (value) {
                    if (value !=
                        _passwordController.text) {
                      return
                        "Passwords do not match";
                    }
                    return null;
                  },
                  suffix: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color:
                      theme.colorScheme.primary,
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
                    onPressed:
                    _isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      theme.colorScheme.primary,
                      foregroundColor:
                      Colors.black,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                            30),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                      color: Colors.black,
                    )
                        : const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                //////////////////////////////////////////////////////
                /// LOGIN OPTION
                //////////////////////////////////////////////////////

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: theme.colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: theme
                              .colorScheme.primary,
                          fontWeight:
                          FontWeight.bold,
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
  /// SIGN UP LOGIC
  //////////////////////////////////////////////////////

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate())
      return;

    setState(() => _isLoading = true);

    try {
      await AuthService().signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password:
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
          Text("Account Created Successfully ✅"),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(
          const Duration(seconds: 1));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
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
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: TextStyle(
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurface
              .withOpacity(0.6),
        ),
        prefixIcon: Icon(
          icon,
          color: theme.colorScheme.primary,
        ),
        suffixIcon: suffix,
        filled: true,
        fillColor: theme.cardColor,
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}