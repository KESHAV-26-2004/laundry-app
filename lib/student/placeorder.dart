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
          const SnackBar(content: Text('Maximum 10 items allowed.')),
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

  Future<void> _placeOrder() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final orderData = {
        'userId': user.uid,
        'clothes': clotheQuantities,
        'orderTime': DateTime.now(),
        'status': 'ongoing',
        'expectedCompletion': DateTime.now().add(const Duration(days: 4)),
      };

      await FirebaseFirestore.instance.collection('orders').add(orderData);

      setState(() {
        for (var type in clotheTypes) {
          clotheQuantities[type] = 0;
        }
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
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
      appBar: AppBar(title: const Text('Place Order')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: clotheTypes.length,
                itemBuilder: (context, index) {
                  final type = clotheTypes[index];
                  return ListTile(
                    title: Text(type),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => _decreaseQuantity(type),
                        ),
                        Text('${clotheQuantities[type]}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _increaseQuantity(type),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _placeOrder,
              child: const Text('Place Order'),
            ),
          ],
        ),
      ),
    );
  }
}