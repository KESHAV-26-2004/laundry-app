import 'package:flutter/material.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showAdminPinDialog(BuildContext context) {
    TextEditingController pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter Admin PIN"),
          content: TextField(
            controller: pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Enter 6-digit PIN"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (pinController.text == "302684") { // Change PIN as needed
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginPage(userType: "admin")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Incorrect PIN!")),
                  );
                }
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('L.A.U.N.D.R.Y',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 24),),
      ),
      body:
      Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onLongPress: () {
                  _showAdminPinDialog(context);
                },
                child: Container(
                  height: 150,
                  width: 150,
                  child: Image.asset('assets/images/bennett_logo.webp'),
                ),
              ),

              const SizedBox(height: 70),

                    // Student Login Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage(userType: "student")),
                        );
                      },
                      child: Column(
                        children: const [
                          Icon(Icons.school, size: 80, color: Colors.blue),
                          SizedBox(height: 10),
                          Text("Student Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Staff Login Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage(userType: "staff")),
                        );
                      },
                      child: Column(
                        children: const [
                          Icon(Icons.business_center, size: 80, color: Colors.green),
                          SizedBox(height: 10),
                          Text("Staff Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
              ),
              SizedBox(height: 80,)
            ],
          ),
        ),
      ),
    );
  }
}
