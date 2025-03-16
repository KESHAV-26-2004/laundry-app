import 'package:flutter/material.dart';
import 'student_dash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StudentScaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<double>(
              future: _getPendingAmount(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Text('Pending Amount: ₹0.00');
                }
                return Text('Pending Amount: ₹${snapshot.data!.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20));
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement Paytm payment
                  },
                  child: const Text('Paytm'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement UPI payment
                  },
                  child: const Text('UPI'),
                ),
              ],
            ),
            const Divider(height: 40),
            const Text('Payment History', style: TextStyle(fontSize: 18)),
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: _getPaymentHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No payment history found.'));
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final paymentData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      final paymentTime = paymentData['paymentTime'].toDate();
                      final amount = paymentData['amount'];
                      return ListTile(
                        title: Text('₹${amount.toStringAsFixed(2)} - ${paymentTime.toString()}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<double> _getPendingAmount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0.0;

    // TODO: Implement logic to calculate pending amount from Firestore data
    // For now, returning a dummy value
    return 100.0;
  }

  Future<QuerySnapshot> _getPaymentHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return FirebaseFirestore.instance.collection('payments').limit(0).get();
    }

    // TODO: Implement logic to fetch payment history from Firestore
    // For now, returning an empty query snapshot
    return FirebaseFirestore.instance
        .collection('payments')
        .where('userId', isEqualTo: user.uid)
        .orderBy('paymentTime', descending: true)
        .get();
  }
}