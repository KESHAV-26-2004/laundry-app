import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home_page.dart';
import 'staff_profile.dart'; // Staff Profile Page
import 'laundry_orders.dart'; // Staff Laundry Orders Page
import 'dry_clean_orders.dart'; // Staff Dry Clean Orders Page
import 'staff_payments.dart'; // Staff Payments Page

class StaffScaffold extends StatefulWidget {
  final AppBar? appBar;
  final Widget body;
  final String? title;

  const StaffScaffold({super.key, this.appBar, this.title, required this.body});

  @override
  State<StaffScaffold> createState() => _StaffScaffoldState();
}

class _StaffScaffoldState extends State<StaffScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar ??
          AppBar(
            title: Text(widget.title ?? 'Laundry App'),
            backgroundColor: Colors.deepPurpleAccent,
            actions: [
              IconButton(
                icon: const Icon(Icons.help), color: Colors.black,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("How can we help you?")),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications), color: Colors.black,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("No new notifications")),
                  );
                },
              ),
            ],
          ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 130,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.deepPurpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Staff Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 26,
                    ),
                  ),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const StaffProfilePage()),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.local_laundry_service),
                title: const Text('Laundry Orders'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LaundryOrdersPage()),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.dry_cleaning),
                title: const Text('Dry Clean Orders'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const DryCleanOrdersPage()),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.payment),
                title: const Text('Payments'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const StaffProfilePage()),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!context.mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: widget.body,
    );
  }
}
