import 'package:flutter/material.dart';
import 'staff_profile.dart';

class StaffLandingPage extends StatelessWidget {
  const StaffLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaffProfilePage(); // No Scaffold wrapper here
  }
}
