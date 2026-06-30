import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  bool _isSubmitted = false;

  //////////////////////////////////////////////////////
  /// EMAIL VALIDATION
  //////////////////////////////////////////////////////

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }

    if (!RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+\-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value)) {
      return "Enter a valid email";
    }

    return null;
  }

  //////////////////////////////////////////////////////
  /// UI
  //////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: _isSubmitted ? _buildSuccessUI(theme) : _buildFormUI(theme),
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////
  /// FORM UI
  //////////////////////////////////////////////////////

  Widget _buildFormUI(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),

          Text(
            "Forgot Password?",
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "Enter your registered email and we will send you a password reset link.",
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 40),

          TextFormField(
            controller: _emailController,
            validator: _validateEmail,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: "Email Address",
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              prefixIcon: Icon(
                Icons.email,
                color: theme.colorScheme.primary,
              ),
              filled: true,
              fillColor: theme.cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _isSubmitted = true;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Send Reset Link",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //////////////////////////////////////////////////////
  /// SUCCESS UI
  //////////////////////////////////////////////////////

  Widget _buildSuccessUI(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle,
          size: 90,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 30),
        Text(
          "Reset Link Sent!",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Check your email to reset your password.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              "Back to Login",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}