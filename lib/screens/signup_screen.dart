import 'package:flutter/material.dart';
import 'package:payper/widget/app_background.dart';
import 'package:payper/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 80, // same as login
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Image.asset(
                  'assets/images/whLogoNoBG.png',
                  height: 100,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Create Account",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              // Name
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Email
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Password
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: () async {
                  try {
                    await _authService.signUp(
                      email: emailController.text,
                      password: passwordController.text,
                      name: nameController.text,
                    );
                    if (!mounted) return;
                    Navigator.pop(context, true);
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.black,
                ),
                child: const Text("Sign Up!",style: TextStyle(color: Colors.white),),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
