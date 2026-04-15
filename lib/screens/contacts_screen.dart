import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:payper/services/auth_service.dart';

class ContactsScreen extends StatelessWidget {
  ContactsScreen({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Contacts"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final data = user.data() as Map<String, dynamic>;

              // ❌ Skip current user
              if (user.id == currentUser?.uid) {
                return const SizedBox.shrink();
              }

              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(data['name'] ?? "No Name"),
                subtitle: Text(data['email'] ?? ""),
                trailing: const Icon(Icons.arrow_forward_ios),

                onTap: () {
                  // 👇 Navigate to Send Money (next step)
                  Navigator.pop(context, {
                    'receiverId': user.id,
                    'receiverName': data['name'],
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}