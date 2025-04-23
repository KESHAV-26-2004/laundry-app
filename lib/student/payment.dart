import 'package:flutter/material.dart';
import 'student_dash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  Future<double> _getPendingAmount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0.0;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('dryCleanOrders')
        .where('userId', isEqualTo: user.uid)
        .where('payment_status', isEqualTo: 'pending')
        .get();

    double total = 0.0;
    for (var doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('totalAmount')) {
        total += (data['totalAmount'] as num).toDouble();
      }
    }
    return total;
  }

  Future<QuerySnapshot> _getPaymentHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return FirebaseFirestore.instance.collection('payments').limit(0).get();
    }

    return FirebaseFirestore.instance
        .collection('payments')
        .where('userId', isEqualTo: user.uid)
        .orderBy('paymentTime', descending: true)
        .get();
  }

  void _showReceiptDialog(BuildContext context, {
    required String receiver,
    required DateTime time,
    required double amount,
    required String txnId,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Payment Receipt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _receiptRow('Paid to:', receiver),
            _receiptRow('Amount:', '₹${amount.toStringAsFixed(2)}'),
            _receiptRow('Date:', DateFormat('dd MMM yyyy, hh:mm a').format(time)),
            _receiptRow('Txn ID:', txnId),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Flexible(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StudentScaffold(
      title: "Payments",
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
                return Text(
                  'Pending Amount: ₹${snapshot.data!.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20),
                );
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
            const SizedBox(height: 10),
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

                  final history = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final paymentData = history[index].data() as Map<String, dynamic>;
                      final receiver = paymentData['receiverName'] ?? 'User';
                      final paymentTime = (paymentData['paymentTime'] as Timestamp).toDate();
                      final amount = paymentData['amount'] ?? 0.0;
                      final transactionId = paymentData['transactionId'] ?? 'TXN00000';

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            receiver[0].toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(receiver, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(DateFormat('dd MMM yyyy, hh:mm a').format(paymentTime)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.account_balance_wallet, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              '- ₹${amount.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        onTap: () => _showReceiptDialog(
                          context,
                          receiver: receiver,
                          time: paymentTime,
                          amount: amount,
                          txnId: transactionId,
                        ),
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
}