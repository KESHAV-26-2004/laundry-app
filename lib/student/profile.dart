import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'student_dash.dart';
import 'edit_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
        _fetchProfileData(); // Only refresh if profile was updated
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return StudentScaffold(
      title: 'Profile',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container 1 - Profile Picture + Name + University
            Container(
              constraints: const BoxConstraints(minHeight: 110), // or adjust based on your layout
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
                    child: userData?['profileImageUrl'] != null && userData!['profileImageUrl'].toString().isNotEmpty
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

            // Edit Button - aligned to left
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
                onPressed: () {
                  _openEditProfile();
                },
                child: const Text('Edit Profile'),
              ),
            ),

            const SizedBox(height: 16),

            // Container 2 - Profile Info (without color)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoTile("Enrollment", userData?['enrollment'] ?? 'empty'),
                  _infoTile("Email", userData?['email'] ?? 'empty'),
                  _infoTile("Phone", userData?['phone'] ?? 'empty'),
                  _infoTile("Date of Birth", userData?['dob'] ?? 'empty'),
                  _infoTile("Address", userData?['address'] ?? 'empty'),
                  _infoTile("Role", userData?['role'] ?? 'empty'),
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
