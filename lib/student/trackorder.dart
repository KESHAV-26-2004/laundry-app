import 'package:flutter/material.dart';
import 'student_dash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrackOrderPage extends StatelessWidget {
  const TrackOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StudentScaffold(
      appBar: AppBar(title: const Text('Track Order')),
      body: FutureBuilder<DocumentSnapshot?>(
        future: _getCurrentOrder(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No order found.'));
          }
          final orderData = snapshot.data!.data() as Map<String, dynamic>;
          final clothes = orderData['clothes'] as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Order Details', style: TextStyle(fontSize: 20)),
                Table(
                  border: TableBorder.all(),
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1),
                  },
                  children: [
                    const TableRow(children: [
                      TableCell(child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Item'),
                      )),
                      TableCell(child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Quantity'),
                      )),
                    ]),
                    ...clothes.entries.where((entry) => entry.value > 0).map((entry) =>
                        TableRow(children: [
                          TableCell(child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(entry.key),
                          )),
                          TableCell(child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('${entry.value}'),
                          )),
                        ]),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Status: ${orderData['status']}',
                    style: const TextStyle(fontSize: 18)),
                Text(
                  orderData['status'] == 'ongoing'
                      ? 'Expected Completion: ${orderData['expectedCompletion'].toDate()}'
                      : 'Completed on: ${orderData['orderTime'].toDate()}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<DocumentSnapshot?> _getCurrentOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final orders = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .orderBy('orderTime', descending: true)
        .limit(1)
        .get();

    if (orders.docs.isNotEmpty) {
      return orders.docs.first;
    }
    return null;
  }
}