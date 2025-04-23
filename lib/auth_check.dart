import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'student/student_landing.dart';
import 'staff/staff_dash.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  Future<Widget> handleAuth() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const HomePage();
    }

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (!doc.exists) {
      await FirebaseAuth.instance.signOut();
      return const HomePage();
    }

    final role = doc['role'];

    if (role == 'admin') {
      // Force admin logout every time
      await FirebaseAuth.instance.signOut();
      return const HomePage();
    }

    if (role == 'student') return const StudentLandingPage();
    if (role == 'staff') return const StaffDashboard();

    return const HomePage(); // fallback
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: handleAuth(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Something went wrong")),
          );
        } else {
          return snapshot.data as Widget;
        }
      },
    );
  }
}