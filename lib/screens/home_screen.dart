import 'package:flutter/material.dart';
import 'package:payper/widget/app_background.dart';
import 'package:payper/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:payper/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();

  String name = "";
  int balance = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final user = _authService.getCurrentUser();

      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final data = doc.data();

        if (data != null) {
          setState(() {
            name =
                data['name'] ??
                "No Name"; // default values if page fails to load
            balance = data['balance'] ?? 0;
            isLoading = false;
          });
        } else {
          print("No user data found!");
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print("User not logged in");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(backgroundColor: Color(0xFF2D3A8C),
        child: ListView(
          children: [
            DrawerHeader(
             // decoration: BoxDecoration(color: Colors.blue),padding: EdgeInsets.all(20),
              child: Text(
                "Send Money",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),

      appBar: AppBar(

        centerTitle: true,
        title: const Text(
          "Payper",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),


        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();

              if (!mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
        elevation: 25,

      ),
      body: AppBackground(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome, $name 👋",
                      style: const TextStyle(fontSize: 22, color: Colors.white),
                    ),

                    const SizedBox(height: 30),

                    // Balance Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Balance"),
                          const SizedBox(height: 10),
                          Text(
                            "₹ $balance",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Buttons
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text("Send Money"),
                    ),

                    ElevatedButton(
                      onPressed: () {},
                      child: const Text("Transactions"),
                    ),

                    ElevatedButton(
                      onPressed: () {},
                      child: const Text("Contacts"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
