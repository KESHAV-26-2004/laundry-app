import 'package:flutter/material.dart';
import 'student_dash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlaceOrderPage extends StatefulWidget {
  const PlaceOrderPage({super.key});

  @override
  State<PlaceOrderPage> createState() => _PlaceOrderPageState();
}

class _PlaceOrderPageState extends State<PlaceOrderPage> {
  final List<String> clotheTypes = [
    'Kurta', 'Pajama', 'Shirt', 'T-Shirt', 'Pant', 'Lower', 'Shorts',
    'Bedsheet', 'Pillow Cover', 'Towel', 'Duppata'
  ];
  final Map<String, int> clotheQuantities = {};

  @override
  void initState() {
    super.initState();
    for (var type in clotheTypes) {
      clotheQuantities[type] = 0;
    }
  }

  void _increaseQuantity(String type) {
    setState(() {
      if (clotheQuantities.values.reduce((a, b) => a + b) < 10) {
        clotheQuantities[type] = (clotheQuantities[type] ?? 0) + 1;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum 10 items allowed.'),
          duration: Duration(seconds: 1),),
        );
      }
    });
  }

  void _decreaseQuantity(String type) {
    setState(() {
      if (clotheQuantities[type]! > 0) {
        clotheQuantities[type] = (clotheQuantities[type] ?? 0) - 1;
      }
    });
  }

  Future<bool> _hasActiveOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return true; // Treat as having active orders if not logged in

    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .where('status', whereIn: ['Order Placed', 'Ongoing', 'Completed'])
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> _placeOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final currentClotheCount = clotheQuantities.values.reduce((a, b) => a + b);
    if (currentClotheCount == 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one item to place an order.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (await _hasActiveOrders()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot place a new order until your previous orders are taken.'),
          duration: Duration(milliseconds: 1000),
        ),
      );
      return;
    }
    try {
      final currentClotheCount = clotheQuantities.values.reduce((a, b) => a + b); // Calculate total clothes count

      final orderData = {
        'userId': user.uid,
        'clothes': clotheQuantities.map((key, value) => MapEntry(key, value)),
        'clotheCount': currentClotheCount, // Added clotheCount
        'orderTime': DateTime.now(),
        'status': 'Order Placed',
        'expectedCompletion': DateTime.now().add(const Duration(days: 5)),
      };

      await FirebaseFirestore.instance.collection('orders').add(orderData);

      setState(() {
        for (var type in clotheTypes) {
          clotheQuantities[type] = 0;
        }
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StudentScaffold(
      title: "Place Order",
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0), // Increased border radius (approx. line 140)
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3), // Slightly darker shadow (approx. line 142)
                    spreadRadius: 1,
                    blurRadius: 5, // Increased blur radius (approx. line 144)
                    offset: const Offset(0, 3), // Increased offset (approx. line 145)
                  ),
                ],
              ),
              margin: const EdgeInsets.symmetric(vertical: 10.0), // Increased vertical margin (approx. line 148)
              padding: const EdgeInsets.all(12.0), // Increased padding (approx. line 149)
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FixedColumnWidth(100), // Increased Qty column width (approx. line 153)
                  2: FixedColumnWidth(90), // Increased buttons column width (approx. line 154)
                },
                children: [
                  TableRow(
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0), // Increased padding (approx. line 161)
                          child: const Text('Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)), // Increased font size (approx. line 162)
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0), // Increased padding (approx. line 167)
                          child: Center(child: const Text('Qty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0))), // Increased font size (approx. line 168)
                        ),
                      ),
                      const TableCell(child: SizedBox.shrink()),
                    ],
                  ),
                  ...clotheTypes.map((type) {
                    return TableRow(
                      children: [
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0), // Increased padding (approx. line 179)
                            child: Text(type, style: const TextStyle(fontSize: 17.0)), // Increased font size (approx. line 180)
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text('${clotheQuantities[type]}', style: const TextStyle(fontSize: 20.0)), // Increased font size (approx. line 185)
                          ),
                        ),
                        TableCell(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () => _decreaseQuantity(type),
                                child: const Icon(Icons.remove_circle_outline, size: 24.0,), // Increased icon size (approx. line 194)
                              ),
                              //const SizedBox(width: 8.0), // Increased spacing (approx. line 196)
                              //Text('${clotheQuantities[type]}', style: const TextStyle(fontSize: 20.0)), // Increased font size again (approx. line 197)
                              //const SizedBox(width: 8.0), // Increased spacing (approx. line 199)
                              InkWell(
                                onTap: () => _increaseQuantity(type),
                                child: const Icon(Icons.add_circle_outline, size: 24.0,), // Increased icon size (approx. line 202)
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 30.0), // Increased spacing before button (approx. line 215)
            ElevatedButton(
              onPressed: _placeOrder,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                textStyle: const TextStyle(fontSize: 20),
                backgroundColor: Colors.white, // Solid background for better contrast// Text color
                shadowColor: Colors.black,
                elevation: 10, // Adjust elevation for desired "coming out" effect
                shape: RoundedRectangleBorder( // Optional: Add rounded corners
                  borderRadius: BorderRadius.circular(35.0),
                ),
              ),
              child: const Text('Place Order'),
            ),
          ],
        ),
      ),
    );
  }
}