import 'package:flutter/material.dart';
import 'package:payper/widget/app_background.dart';
import 'package:payper/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:payper/screens/login_screen.dart';
import 'package:payper/screens/transaction_screen.dart';
import 'package:payper/screens/contacts_screen.dart';
import 'package:payper/screens/history_screen.dart';

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
    setState(() => isLoading = true);
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
      //make features to be in homescreen rather than drawer. Do: fix homescreen
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Payper",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Offline UPI Simulator",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: Icon(Icons.info),
              title: Text("About App"),
              subtitle: Text("Flutter + Firebase UPI simulation"),
            ),

            ListTile(
              leading: Icon(Icons.person),
              title: Text("Developed by"),
              subtitle: Text("Syntax"),
            ),

            ListTile(
              leading: Icon(Icons.lightbulb),
              title: Text("Future Scope"),
              subtitle: Text("QR, Bank Linking, Real-time sync"),
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
            icon: const Icon(Icons.refresh),
            onPressed: () {
              fetchUserData();
            },
          ),

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
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(_authService.getCurrentUser()?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;

            final name = data['name'] ?? "No Name";
            final balance = data['balance'] ?? 0;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, $name! 👋",
                    style: const TextStyle(fontSize: 22, color: Colors.white),
                  ),

                  const SizedBox(height: 10),

                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Balance",
                              style: TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "₹ $balance",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildFeature(Icons.send, "Send", () async {
                                  final selectedUser = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ContactsScreen(),
                                    ),
                                  );

                                  if (selectedUser != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TransactionScreen(
                                          receiverId:
                                              selectedUser['receiverId'],
                                          receiverName:
                                              selectedUser['receiverName'],
                                        ),
                                      ),
                                    );
                                  }
                                }),

                                _buildFeature(Icons.history, "History", () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => HistoryScreen(),
                                    ),
                                  );
                                }),

                                _buildFeature(
                                  Icons.contacts,
                                  "Contacts",
                                  () async {
                                    final selectedUser = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ContactsScreen(),
                                      ),
                                    );

                                    if (selectedUser != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => TransactionScreen(
                                            receiverId:
                                                selectedUser['receiverId'],
                                            receiverName:
                                                selectedUser['receiverName'],
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 150),

                  Center(
                    child: Image.asset(
                      'assets/images/blupprnobg.png',
                      height: 200,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget _buildFeature(IconData icon, String title, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        const SizedBox(height: 6),
        Text(title),
      ],
    ),
  );
}
