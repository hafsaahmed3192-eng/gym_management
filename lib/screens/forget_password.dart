import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController =
  TextEditingController();

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
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0F14),
        iconTheme:
        const IconThemeData(color: Color(0xFFFFD700)),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 30),
          child: _isSubmitted
              ? _buildSuccessUI()
              : _buildFormUI(),
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////
  /// FORM UI
  //////////////////////////////////////////////////////

  Widget _buildFormUI() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),

          const Text(
            "Forgot Password?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Enter your registered email and we will send you a password reset link.",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 40),

          TextFormField(
            controller: _emailController,
            validator: _validateEmail,
            style:
            const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Email Address",
              hintStyle:
              const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(
                Icons.email,
                color: Color(0xFFFFD700),
              ),
              filled: true,
              fillColor:
              const Color(0xFF1C1F26),
              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(30),
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
                if (_formKey.currentState!
                    .validate()) {
                  setState(() {
                    _isSubmitted = true;
                  });
                }
              },
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFFFFD700),
                foregroundColor:
                Colors.black,
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                      30),
                ),
              ),
              child: const Text(
                "Send Reset Link",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                  FontWeight.bold,
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

  Widget _buildSuccessUI() {
    return Column(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle,
          size: 90,
          color: Color(0xFFFFD700),
        ),
        const SizedBox(height: 30),
        const Text(
          "Reset Link Sent!",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight:
            FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Check your email to reset your password.",
          textAlign: TextAlign.center,
          style:
          TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style:
            ElevatedButton.styleFrom(
              backgroundColor:
              const Color(0xFFFFD700),
              foregroundColor:
              Colors.black,
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(
                    30),
              ),
            ),
            child: const Text(
              "Back to Login",
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}