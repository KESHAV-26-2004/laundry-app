import 'package:flutter/material.dart';
import 'student_dash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DryCleanPage extends StatefulWidget {
  const DryCleanPage({super.key});

  @override
  State<DryCleanPage> createState() => _DryCleanPageState();
}

class _DryCleanPageState extends State<DryCleanPage> {
  final List<String> clotheTypes = [
    'Kurta', 'Pajama', 'Shirt', 'T-Shirt', 'Pant', 'Lower', 'Shorts',
    'Bedsheet', 'Pillow Cover', 'Towel', 'Duppata'
  ];
  final Map<String, int> clotheQuantities = {};
  final Map<String, double> clothePrices = {
    'Kurta': 50.0, 'Pajama': 30.0, 'Shirt': 40.0, 'T-Shirt': 30.0, 'Pant': 45.0,
    'Lower': 35.0, 'Shorts': 25.0, 'Bedsheet': 60.0, 'Pillow Cover': 20.0,
    'Towel': 25.0, 'Duppata': 35.0
  };
  final List<Map<String, dynamic>> dryCleanItems = [];

  @override
  void initState() {
    super.initState();
    for (var type in clotheTypes) {
      clotheQuantities[type] = 0;
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

  void _addItemToDryClean() {
    setState(() {
      for (var type in clotheTypes) {
        if (clotheQuantities[type]! > 0) {
          dryCleanItems.add({
            'type': type,
            'quantity': clotheQuantities[type],
            'price': clothePrices[type]! * clotheQuantities[type]!
          });
          clotheQuantities[type] = 0;
        }
      }
    });
  }

  double _calculateTotalAmount() {
    double total = 0;
    for (var item in dryCleanItems) {
      total += item['price'] as double;
    }
    return total;
  }

  Future<void> _placeDryCleanOrder() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final orderData = {
        'userId': user.uid,
        'dryCleanItems': dryCleanItems,
        'orderTime': DateTime.now(),
        'status': 'pending',
        'totalAmount': _calculateTotalAmount(),
      };

      await FirebaseFirestore.instance.collection('dryCleanOrders').add(orderData);

      setState(() {
        dryCleanItems.clear();
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
      appBar: AppBar(title: const Text('Dry Clean')),
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
              onPressed: _addItemToDryClean,
              child: const Text('Add Item'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: dryCleanItems.length,
                itemBuilder: (context, index) {
                  final item = dryCleanItems[index];
                  return ListTile(
                    title: Text('${item['type']} x ${item['quantity']}'),
                    trailing: Text('₹${item['price'].toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text('Total Amount: ₹${_calculateTotalAmount().toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18)),
            ElevatedButton(
              onPressed: _placeDryCleanOrder,
              child: const Text('Place Dry Clean Order'),
            ),
          ],
        ),
      ),
    );
  }
}