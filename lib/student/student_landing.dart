import 'package:flutter/material.dart';
import 'profile.dart';

class StudentLandingPage extends StatelessWidget {
  const StudentLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfilePage(); // No Scaffold wrapper here
  }
}
