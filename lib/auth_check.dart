import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:laundary/student/profile.dart';
import 'home_page.dart';
import 'student/student_dash.dart';
import 'staff_dash.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  Future<Map<String, dynamic>?> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        String role = userDoc["role"];

        // If user is admin, log them out immediately
        if (role == "admin") {
          await FirebaseAuth.instance.signOut();
          return null; // Prevent auto-login for admin
        }
        return {
          "role": userDoc["role"],
          "email": userDoc["email"],
          "enrollment": userDoc["role"] == "student" ? userDoc["enrollment"] : null,
        };
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return FutureBuilder<Map<String, dynamic>?>(
            future: getUserData(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (userSnapshot.hasData) {
                String role = userSnapshot.data!["role"];
                return role == "student" ? const StudentDashboard() : const StaffDashboard();
              }
              return const HomePage();
            },
          );
        }
        return const HomePage();
      },
    );
  }
}
