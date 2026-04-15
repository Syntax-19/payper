import 'package:flutter/material.dart';
import 'package:payper/screens/home_screen.dart';
import 'package:payper/widget/app_background.dart';
import 'package:payper/services/auth_service.dart';
import 'package:payper/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreen_State();
}

class LoginScreen_State extends State<LoginScreen> {
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
            top: 100,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Center(
                child: Image.asset(
                  'assets/images/whLogoNoBG.png',
                  height: 100,
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                "Welcome Back",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

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

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final user = await _authService.signIn(
                        email: emailController.text,
                        password: passwordController.text,
                      );

                      if (user != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Login Successful")),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    );

                    if (!mounted) return;

                    if (result == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Signup Successful")),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Don't have an account? Sign up",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
