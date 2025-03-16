import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}
class AdminScaffold extends StatelessWidget {
  final AppBar? appBar;
  final Widget body;

  const AdminScaffold({super.key, this.appBar, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 130,
              child: const DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.deepPurpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Text(
                  'Admin Menu',
                  style: TextStyle(
                    color: Colors.white,fontWeight: FontWeight.w500,
                    fontSize: 26,
                  ),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text('Add User'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminDashboard()),
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
      body: body,
    );
  }
}
class _AdminDashboardState extends State<AdminDashboard> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _role = 'student'; // Default role

  Future<void> _createUser() async {
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());

      Map<String, dynamic> userData = {
        'role': _role,
        'email': _emailController.text.trim(),
      };

      if (_role == 'student') {
        final email = _emailController.text.trim();
        final enrollment = email.substring(0, email.indexOf('@'));
        userData['enrollment'] = enrollment;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User created successfully!')),
      );
      _emailController.clear();
      _passwordController.clear();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Admin Dashboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 50,),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 20,),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 30,),
            Container(
              width: 300,
              child: DropdownButtonFormField<String>(
                value: _role,
                decoration: InputDecoration(
                    filled: true, // Background color
                    fillColor: Colors.white, // Change this color as needed
                    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10), // Increase padding
                    border: OutlineInputBorder( // Add a border
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                  dropdownColor: Colors.white, // Background color of dropdown items
                  icon: Icon(Icons.arrow_drop_down, color: Colors.blue), // Custom dropdown icon color
                  style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w500),
                onChanged: (String? newValue) {
                  setState(() {
                    _role = newValue!;
                  });
                },
                items: <String>['student', 'staff']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,style: TextStyle(fontSize: 18)),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 30,),
            ElevatedButton(
              onPressed: _createUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(300, 50),
              ),
              child: FittedBox(
                child: const Text('Create User',style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500,fontSize: 18),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}