import 'package:flutter/material.dart';
import 'student_dash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StudentScaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: FutureBuilder<QuerySnapshot>(
        future: _getCompletedOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No completed orders found.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final orderData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final orderTime = orderData['orderTime'].toDate();
              return Card(
                child: ListTile(
                  title: Text('Order placed on: ${orderTime.toString()}'),
                  onTap: () {
                    _showOrderDetails(context, orderData);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<QuerySnapshot> _getCompletedOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return FirebaseFirestore.instance.collection('payments').limit(0).get();
    }

    return FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'completed')
        .orderBy('orderTime', descending: true)
        .get();
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> orderData) {
    final clothes = orderData['clothes'] as Map<String, dynamic>;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Order Details'),
          content: SingleChildScrollView(
            child: Table(
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
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}