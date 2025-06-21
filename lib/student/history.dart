import 'package:flutter/material.dart';
import 'student_dash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  Future<void>? _loadDataFuture;
  List<Map<String, dynamic>> _allOrders = [];

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadOrderHistory();
  }

  Future<void> _loadOrderHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ordersSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .where('status', whereNotIn: ['Order Placed', 'Ongoing'])
        .orderBy('orderTime', descending: true)
        .get();

    final dryCleanSnapshot = await FirebaseFirestore.instance
        .collection('dryCleanOrders')
        .where('userId', isEqualTo: user.uid)
        .where('status', whereNotIn: ['Order Placed', 'Ongoing'])
        .orderBy('orderTime', descending: true)
        .get();

    _allOrders = [
      ...ordersSnapshot.docs.map((doc) => {
        'id': doc.id,
        'type': 'regular',
        'data': doc.data() as Map<String, dynamic>,
      }),
      ...dryCleanSnapshot.docs.map((doc) => {
        'id': doc.id,
        'type': 'dry',
        'data': doc.data() as Map<String, dynamic>,
      }),
    ];

    _allOrders.sort((a, b) {
      final timeA = (a['data']['orderTime'] as Timestamp).toDate();
      final timeB = (b['data']['orderTime'] as Timestamp).toDate();
      return timeB.compareTo(timeA);
    });
  }

  Future<void> _showOrderDetails(BuildContext context, Map<String, dynamic> order) async {
    final Map<String, dynamic> orderData = order['data'];
    final bool isDry = order['type'] == 'dry';

    final Map<String, dynamic> clothes = isDry
        ? Map<String, dynamic>.from(orderData['dryCleanItems'] ?? {})
        : Map<String, dynamic>.from(orderData['clothes'] ?? {});

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isDry ? 'Dry Clean Order Details' : 'Order Details'),
          content: SingleChildScrollView(
            child: Table(
              border: TableBorder.all(width: 0.5),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FixedColumnWidth(50),
              },
              children: [
                const TableRow(children: [
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ]),
                ...clothes.entries.where((e) => e.value > 0).map((entry) {
                  return TableRow(children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(entry.key),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(child: Text('${entry.value}')),
                      ),
                    ),
                  ]);
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StudentScaffold(
      title: "Order History",
      body: FutureBuilder<void>(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_allOrders.isEmpty) {
            return const Center(child: Text('No order history found.'));
          }

          return ListView.builder(
            itemCount: _allOrders.length,
            itemBuilder: (context, index) {
              final order = _allOrders[index];
              final orderData = order['data'] as Map<String, dynamic>;
              final DateTime orderTime = (orderData['orderTime'] as Timestamp).toDate();
              final String status = orderData['status'];
              final int itemCount = order['type'] == 'dry'
                  ? (orderData['totalQty'] ?? 0)
                  : (orderData['clotheCount'] ?? 0);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: InkWell(
                  onTap: () => _showOrderDetails(context, order),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Placed on: ${DateFormat('MMM d, hh:mm a').format(orderTime)}${order['type'] == 'dry' ? ' (Dry Clean)' : ''}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8.0),
                        Text('Status: $status', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8.0),
                        Text('Number of Items: $itemCount', style: const TextStyle(fontSize: 16)),
                      ],
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
}
