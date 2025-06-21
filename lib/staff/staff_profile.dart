import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'staff_dash.dart'; // 📌 Staff Scaffold instead of Student Scaffold
import 'edit_profile.dart'; // You can reuse same edit page

class StaffProfilePage extends StatefulWidget {
  const StaffProfilePage({super.key});

  @override
  State<StaffProfilePage> createState() => _StaffProfilePageState();
}

class _StaffProfilePageState extends State<StaffProfilePage> {
  Map<String, dynamic>? userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          userData = doc.data();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching profile data: $e");
    }
  }

  void _openEditProfile() {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return const EditProfilePage();
        },
      ),
    ).then((result) {
      if (result == true) {
        _fetchProfileData(); // Refresh if updated
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StaffScaffold(
      title: 'Profile',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Container (Image + Name + University)
            Container(
              constraints: const BoxConstraints(minHeight: 110),
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                color: Colors.white,
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: userData?['profileImageUrl'] != null &&
                        userData!['profileImageUrl'].toString().isNotEmpty
                        ? Image.network(
                      userData!['profileImageUrl'],
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    )
                        : Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey.shade300,
                      alignment: Alignment.center,
                      child: Text(
                        _getInitials(userData?['name'] ?? 'U'),
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userData?['name'] ?? 'empty',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Bennett University",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Edit Profile Button
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: _openEditProfile,
                child: const Text('Edit Profile'),
              ),
            ),

            const SizedBox(height: 16),

            // Lower Container (Profile Details)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoTile("Email", userData?['email'] ?? 'empty'),
                  _infoTile("Phone", userData?['phone'] ?? 'empty'),
                  _infoTile("Date of Birth", userData?['dob'] ?? 'empty'),
                  _infoTile("Address", userData?['address'] ?? 'empty'),
                  _infoTile("Role", userData?['role'] ?? 'Staff'), // Default to "Staff"
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return "U";
    List<String> parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Widget _infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
