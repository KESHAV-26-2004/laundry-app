import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'staff_dash.dart';

class LaundryOrdersPage extends StatefulWidget {
  const LaundryOrdersPage({super.key});

  @override
  State<LaundryOrdersPage> createState() => _LaundryOrdersPageState();
}

class _LaundryOrdersPageState extends State<LaundryOrdersPage> {
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _filteredOrders = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('status', whereIn: ['Order Placed', 'Completed'])
        .orderBy('orderTime', descending: true)
        .get();

    final orders = querySnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'data': doc.data(),
      };
    }).toList();

    setState(() {
      _orders = orders;
      _filterOrders();
    });
  }

  void _filterOrders() {
    if (_searchQuery.isEmpty) {
      _filteredOrders = _orders;
    } else {
      _filteredOrders = _orders.where((order) {
        final data = order['data'] as Map<String, dynamic>;
        final enrollment = data['enrollment'] ?? '';
        return enrollment.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    setState(() {});
  }

  Future<void> _updateOrderStatus(String orderId, String currentStatus) async {
    String newStatus = '';
    if (currentStatus == 'Order Placed') {
      newStatus = 'Ongoing';
    } else if (currentStatus == 'Completed') {
      newStatus = 'Taken';
    }

    if (newStatus.isNotEmpty) {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': newStatus,
      });
      _fetchOrders();
    }
  }

  Future<void> _rejectOrder(String orderId) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': 'Rejected',
    });
    _fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return StaffScaffold(
        title: 'Laundry Orders',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by Enrollment No.',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _searchQuery = value;
                _filterOrders();
              },
            ),
          ),
          Expanded(
            child: _filteredOrders.isEmpty
                ? const Center(child: Text('No orders found.'))
                : ListView.builder(
              itemCount: _filteredOrders.length,
              itemBuilder: (context, index) {
                final order = _filteredOrders[index];
                final data = order['data'] as Map<String, dynamic>;
                final DateTime orderTime = (data['orderTime'] as Timestamp).toDate();
                final String enrollment = data['enrollment'] ?? 'Unknown';
                final String status = data['status'] ?? 'Unknown';
                final int itemCount = data['clotheCount'] ?? 0;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Enrollment: $enrollment', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8.0),
                        Text('Order Placed On: ${DateFormat('MMM d, hh:mm a').format(orderTime)}',
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8.0),
                        Text('Status: $status',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8.0),
                        Text('Number of Items: $itemCount', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 12.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () => _updateOrderStatus(order['id'], status),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.black,
                              ),
                              child: const Text('Accept'),
                            ),
                            const SizedBox(width: 10),
                            if (status == 'Order Placed')
                              ElevatedButton(
                                onPressed: () => _rejectOrder(order['id']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.black,
                                ),
                                child: const Text('Reject'),
                              ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
