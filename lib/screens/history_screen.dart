import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:payper/services/auth_service.dart';

class HistoryScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = _authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction History"),
      ),
      body: user == null
          ? const Center(child: Text("User not logged in"))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .where('senderId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Failed to load history: ${snapshot.error}"),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No transactions yet"));
          }

          final transactions = [...snapshot.data!.docs]
            ..sort((a, b) {
              final aData = a.data() as Map<String, dynamic>;
              final bData = b.data() as Map<String, dynamic>;
              final aTimestamp = aData['timestamp'];
              final bTimestamp = bData['timestamp'];

              if (aTimestamp is! Timestamp && bTimestamp is! Timestamp) {
                return 0;
              }
              if (aTimestamp is! Timestamp) return 1;
              if (bTimestamp is! Timestamp) return -1;

              return bTimestamp.compareTo(aTimestamp);
            });

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final data =
              transactions[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(
                    Icons.arrow_upward,
                    color: Colors.red,
                  ),
                  title: Text("To: ${data['receiverName']}"),
                  subtitle: Text(_formatTime(data['timestamp'])),
                  trailing: Text(
                    "- ₹${data['amount']}",
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year}";
  }
}
