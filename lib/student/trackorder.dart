import 'package:flutter/material.dart';
import 'student_dash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TrackOrderPage extends StatefulWidget {
  const TrackOrderPage({super.key});

  @override
  State<TrackOrderPage> createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends State<TrackOrderPage> {
  DocumentSnapshot? _currentOrder;

  @override
  void initState() {
    super.initState();
    _loadCurrentOrder();
  }

  Future<void> _loadCurrentOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final orders = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .where('status', whereNotIn: ['Taken', 'Deleted'])
        .orderBy('orderTime', descending: true)
        .limit(1)
        .get();
    if (orders.docs.isNotEmpty) {
      setState(() {
        _currentOrder = orders.docs.first;
      });
    } else {
      setState(() {
        _currentOrder = null;
      });
    }
  }

  Future<void> _deleteOrder() async {
    if (_currentOrder == null || _currentOrder!['status'] != 'Order Placed') {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(_currentOrder!.id)
          .update({'status': 'Deleted'});
      _loadCurrentOrder(); // Refresh the current order
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order deleted successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete order: $e')),
        );
      }
    }
  }

  double _calculateProgress(Map<String, dynamic>? orderData) {
    if (orderData == null || orderData['status'] != 'Ongoing' || orderData['expectedCompletion'] == null || orderData['orderTime'] == null) {
      return 0.0;
    }

    final now = DateTime.now();
    final orderTime = (_currentOrder!['orderTime'] as Timestamp).toDate();
    final expectedCompletion = (_currentOrder!['expectedCompletion'] as Timestamp).toDate();

    if (now.isAfter(expectedCompletion)) {
      return 0.9; // Nearing completion
    }

    final totalDuration = expectedCompletion.difference(orderTime).inDays;
    final elapsedDuration = now.difference(orderTime).inDays;

    if (totalDuration <= 0) {
      return 0.9;
    }

    final progress = (elapsedDuration / totalDuration).clamp(0.0, 0.9);
    return progress;
  }

  @override
  Widget build(BuildContext context) {
    return StudentScaffold(
      title: "Track Order",
      body: RefreshIndicator(
        onRefresh: _loadCurrentOrder,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: _currentOrder == null
              ? const Center(child: Text('No active order found.'))
              : Stack(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                width: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Placed on: ${DateFormat('MMM d, hh:mm a').format((_currentOrder!['orderTime'] as Timestamp).toDate())}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8.0),
                    Text('Status: ${_currentOrder!['status']}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8.0),
                    Text(
                      'Number of Items: ${_currentOrder!['clotheCount'] ?? 0}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12.0),
                    if (_currentOrder!['status'] == 'Ongoing')
                      LinearProgressIndicator(
                        value: _calculateProgress(_currentOrder!.data() as Map<String, dynamic>),
                        minHeight: 8.0,
                        borderRadius: BorderRadius.circular(4.0),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                        backgroundColor: Colors.grey[300],
                      )
                    else if (_currentOrder!['status'] == 'Completed')
                      LinearProgressIndicator(
                        value: 1.0,
                        minHeight: 8.0,
                        borderRadius: BorderRadius.circular(4.0),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        backgroundColor: Colors.grey[300],
                      )
                    else
                      const SizedBox.shrink(),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Order Items:', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                          Table(
                            border: TableBorder.all(width: 0.5),
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FixedColumnWidth(50),
                            },
                            children: [
                              const TableRow(children: [
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Item'))),
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Qty'))),
                              ]),
                              ...(_currentOrder!['clothes'] as Map<String, dynamic>)
                                  .entries
                                  .where((entry) {
                                final value = entry.value;
                                return value is num && value > 0;
                              })
                                  .map((entry) => TableRow(children: [
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(entry.key))),
                                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('${entry.value}'))),
                              ]))
                                  .toList(),
                            ],
                          ),
                          const SizedBox(height: 18), // Added spacing below the table
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_currentOrder != null && _currentOrder!['status'] == 'Order Placed')
                Positioned(
                  bottom: 10, // Adjust vertical position relative to the bottom of the Stack
                  right: 10, // Adjust horizontal position relative to the right of the Stack
                  child: InkWell(
                    onTap: _deleteOrder,
                    child: const Icon(Icons.delete_outline, size: 26),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}