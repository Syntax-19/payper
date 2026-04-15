import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:payper/services/auth_service.dart';

class TransactionScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const TransactionScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController amountController = TextEditingController();

  bool isLoading = false;

  Future<void> sendMoney() async {
    final user = _authService.getCurrentUser();

    if (user == null) return;

    final amount = int.tryParse(amountController.text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid amount")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final firestore = FirebaseFirestore.instance;

      await firestore.runTransaction((transaction) async {
        final senderRef = firestore.collection('users').doc(user.uid);
        final receiverRef = firestore.collection('users').doc(widget.receiverId);

        final senderSnap = await transaction.get(senderRef);
        final receiverSnap = await transaction.get(receiverRef);

        final senderBalance = senderSnap['balance'];
        final receiverBalance = receiverSnap['balance'];

        // ❌ insufficient balance
        if (senderBalance < amount) {
          throw Exception("Insufficient balance");
        }

        // ✅ update balances
        transaction.update(senderRef, {
          'balance': senderBalance - amount,
        });

        transaction.update(receiverRef, {
          'balance': receiverBalance + amount,
        });

        // ✅ add transaction record
        final txnRef = firestore.collection('transactions').doc();

        transaction.set(txnRef, {
          'senderId': user.uid,
          'receiverId': widget.receiverId,
          'receiverName': widget.receiverName,
          'amount': amount,
          'timestamp': Timestamp.now(),
        });
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Successful")),
      );

      Navigator.pop(context); // go back

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Send Money"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Sending to: ${widget.receiverName}",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter amount",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: isLoading ? null : sendMoney,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Send Money"),
            ),
          ],
        ),
      ),
    );
  }
}