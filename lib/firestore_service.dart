import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to get user data
  Future<Map<String, dynamic>?> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        String role = userDoc["role"];
        String email = userDoc["email"];
        String? enrollment = role == "student" ? userDoc["enrollment"] : null;

        return {
          "role": role,
          "email": email,
          "enrollment": enrollment,
        };
      }
    }
    return null;
  }
}
