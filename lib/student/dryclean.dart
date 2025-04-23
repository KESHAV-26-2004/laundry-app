import 'package:flutter/material.dart';
import 'student_dash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DryCleanPage extends StatefulWidget {
  const DryCleanPage({super.key});

  @override
  State<DryCleanPage> createState() => _DryCleanPageState();
}

class _DryCleanPageState extends State<DryCleanPage> {
  final List<String> clotheTypes = [
    'T-Shirt', 'Pant', 'Bedsheet', 'Towel', 'Shirt', 'Pajama', 'Blanket', 'Jacket'
  ];
  final Map<String, int> clotheQuantities = {};
  final Map<String, double> clothePrices = {
    'T-Shirt': 50.0,
    'Pant': 50.0,
    'Bedsheet': 50.0,
    'Towel': 50.0,
    'Shirt': 50.0,
    'Pajama': 50.0,
    'Blanket': 150.0,
    'Jacket': 100.0,
  };
  final List<String> orderStatusPhases = ['Order Placed', 'Ongoing', 'Completed', 'Taken'];
  String _currentOrderStatus = 'Order Placed';
  DocumentSnapshot? _activeDryCleanOrder;

  @override
  void initState() {
    super.initState();
    for (var type in clotheTypes) {
      clotheQuantities[type] = 0;
    }
    _loadActiveDryCleanOrder();
  }

  Future<void> _loadActiveDryCleanOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final orders = await FirebaseFirestore.instance
        .collection('dryCleanOrders')
        .where('userId', isEqualTo: user.uid)
        .where('status', whereNotIn: ['Taken','Deleted'])
        .orderBy('orderTime', descending: true)
        .limit(1)
        .get();
    if (orders.docs.isNotEmpty) {
      setState(() {
        _activeDryCleanOrder = orders.docs.first;
      });
    } else {
      setState(() {
        _activeDryCleanOrder = null;
      });
    }
  }

  void _increaseQuantity(String type) {
    setState(() {
      clotheQuantities[type] = (clotheQuantities[type] ?? 0) + 1;
    });
  }

  void _decreaseQuantity(String type) {
    setState(() {
      if (clotheQuantities[type]! > 0) {
        clotheQuantities[type] = (clotheQuantities[type] ?? 0) - 1;
      }
    });
  }

  double _calculateTotalAmount() {
    double total = 0;
    for (var type in clotheTypes) {
      total += (clotheQuantities[type] ?? 0) * (clothePrices[type] ?? 0);
    }
    return total;
  }

  Future<bool> _hasActiveDryCleanOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return true;
    final snapshot = await FirebaseFirestore.instance
        .collection('dryCleanOrders')
        .where('userId', isEqualTo: user.uid)
        .where('status', whereIn: ['Order Placed', 'Ongoing'])
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<void> _deleteOrder() async {

    try {
      await FirebaseFirestore.instance
          .collection('dryCleanOrders')
          .doc(_activeDryCleanOrder!.id)
          .update({'status': 'Deleted','payment_status':'Completed'});
      _loadActiveDryCleanOrder(); // Refresh the current order
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dry clean order deleted successfully.'),
          duration: Duration(milliseconds: 500),),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete dry clean order: $e')),
        );
      }
    }
  }

  Future<void> _placeDryCleanOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final totalQty = clotheQuantities.values.fold(0, (a, b) => a + b);
    if (totalQty == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one item.'), duration: Duration(seconds: 1)));
      return;
    }

    if (await _hasActiveDryCleanOrders()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot place a new dry clean order until your previous orders are being processed.'),
          duration: Duration(milliseconds: 1500),
        ),
      );
      return;
    }

    try {
      final orderData = {
        'userId': user.uid,
        'dryCleanItems': clotheQuantities.map((key, value) => MapEntry(key, value)),
        'orderTime': DateTime.now(),
        'payment_status': 'pending',
        'status': _currentOrderStatus,
        'totalQty': totalQty,
        'totalAmount': _calculateTotalAmount(),
        'expectedCompletion': DateTime.now().add(const Duration(days: 5)),
      };

      await FirebaseFirestore.instance.collection('dryCleanOrders').add(orderData);
      await _loadActiveDryCleanOrder();

      setState(() {
        for (var type in clotheTypes) {
          clotheQuantities[type] = 0;
        }
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dry clean order placed successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place dry clean order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StudentScaffold(
      title: "Dry Clean",
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      padding: const EdgeInsets.all(12.0),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FixedColumnWidth(100),
                          2: FixedColumnWidth(90),
                        },
                        children: [
                          const TableRow(
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Center(child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0))),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Center(child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0))),
                              ),
                            ],
                          ),
                          ...clotheTypes.map((type) {
                            return TableRow(
                              key: ValueKey(type),
                              children: [
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(type, style: const TextStyle(fontSize: 17.0)),
                                  ),
                                ),
                                TableCell(
                                  child: Center(
                                    child: Text('${clotheQuantities[type]}', style: const TextStyle(fontSize: 20.0)),
                                  ),
                                ),
                                TableCell(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () => _decreaseQuantity(type),
                                        child: const Icon(Icons.remove_circle_outline, size: 24.0),
                                      ),
                                      Text('₹${clothePrices[type]?.toStringAsFixed(0) ?? '0'}', style: const TextStyle(fontSize: 16.0)),
                                      InkWell(
                                        onTap: () => _increaseQuantity(type),
                                        child: const Icon(Icons.add_circle_outline, size: 24.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 20.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: _activeDryCleanOrder != null
                              ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('ACTIVE ORDER', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8.0),
                              Text(
                                'Order Placed on: ${DateFormat('MMM d, hh:mm a').format((_activeDryCleanOrder!['orderTime'] as Timestamp).toDate())}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8.0),
                              Text('Status: ${_activeDryCleanOrder!['status']}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8.0),
                              Text('Payment: ${_activeDryCleanOrder!['payment_status']}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8.0),
                              Text('Number of Items: ${_activeDryCleanOrder!['totalQty'] ?? 0}',
                                  style: const TextStyle(fontSize: 16)),
                              const SizedBox(height: 8.0),
                              Text('Total Price: ₹${(_activeDryCleanOrder!['totalAmount'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12.0),
                              const Text('Order Items:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              Table(
                                border: TableBorder.all(width: 0.5),
                                columnWidths: const {
                                  0: FlexColumnWidth(2),
                                  1: FixedColumnWidth(50),
                                  2: FixedColumnWidth(80),
                                },
                                children: [
                                  const TableRow(children: [
                                    TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Item'))),
                                    TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Qty'))),
                                    TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Price'))),
                                  ]),
                                  ...(_activeDryCleanOrder!['dryCleanItems'] as Map<String, dynamic>)
                                      .entries
                                      .where((entry) => (entry.value as int) > 0)
                                      .map((entry) {
                                    final type = entry.key;
                                    final qty = entry.value;
                                    final price = (clothePrices[type] ?? 0) * qty;
                                    return TableRow(children: [
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text(type))),
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('$qty'))),
                                      TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('₹${price.toStringAsFixed(2)}'))),
                                    ]);
                                  }),
                                ],
                              ),
                            ],
                          )
                              : const Center(child: Text('No active dry clean order.')),
                        ),
                        if (_activeDryCleanOrder != null && _activeDryCleanOrder!['status'] == 'Order Placed')
                          Positioned(
                            top: 30,
                            right: 16,
                            child: InkWell(
                              onTap: _deleteOrder,
                              child: const Icon(Icons.delete_outline, size: 26),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 30,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Total Amount: ₹${_calculateTotalAmount().toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.center, // or Alignment.centerLeft, etc.
                      child: SizedBox(
                        width: 180, // This will now take effect!
                        child: ElevatedButton(
                          onPressed: _placeDryCleanOrder,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            textStyle: const TextStyle(fontSize: 18),
                            backgroundColor: Colors.white,
                            shadowColor: Colors.black,
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35.0),
                            ),
                          ),
                          child: const Text('Place Order'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}